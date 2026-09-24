// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Uploads to a configured server: the file is the whole body of one HTTPS
/// POST, and the reply may name a link. Pure logic, so what leaves the Mac
/// can be pinned down in tests without a network.
enum CaptureUploadSupport {
    /// The id only keeps a row stable while it is edited.
    struct Field: Codable, Equatable, Identifiable {
        var id: UUID
        var name: String
        var value: String

        init(id: UUID = UUID(), name: String = "", value: String = "") {
            self.id = id
            self.name = name
            self.value = value
        }

        private enum CodingKeys: String, CodingKey {
            case id, name, value
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
            name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
            value = try values.decodeIfPresent(String.self, forKey: .value) ?? ""
        }
    }

    /// Kept as one JSON string in the defaults; an empty string is no
    /// destination at all.
    struct Destination: Codable, Equatable {
        var url: String
        var queryItems: [Field]
        var headers: [Field]

        init(url: String = "", queryItems: [Field] = [], headers: [Field] = []) {
            self.url = url
            self.queryItems = queryItems
            self.headers = headers
        }

        private enum CodingKeys: String, CodingKey {
            case url, queryItems, headers
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
            queryItems = try values.decodeIfPresent([Field].self, forKey: .queryItems) ?? []
            headers = try values.decodeIfPresent([Field].self, forKey: .headers) ?? []
        }

        var isEmpty: Bool {
            url.isEmpty && queryItems.isEmpty && headers.isEmpty
        }

        func encoded() -> String {
            guard !isEmpty, let data = try? JSONEncoder().encode(self) else { return "" }
            return String(data: data, encoding: .utf8) ?? ""
        }

        static func decoded(_ raw: String?) -> Destination {
            guard let raw, !raw.isEmpty,
                  let data = raw.data(using: .utf8),
                  let destination = try? JSONDecoder().decode(Destination.self, from: data)
            else { return Destination() }
            return destination
        }
    }

    enum Kind {
        case screenshot
        case recording

        var contentType: String {
            switch self {
            case .screenshot: "image/png"
            case .recording: "video/mp4"
            }
        }

        var copyLinkDefaultsKey: String {
            switch self {
            case .screenshot: DefaultsKey.captureUploadCopyScreenshotLink
            case .recording: DefaultsKey.captureUploadCopyRecordingLink
            }
        }
    }

    static let maximumFields = 20
    static let maximumResponseBytes = 64 * 1_024
    static let linkKeys = ["url", "link"]
    /// Levels of a JSON reply searched for a link, the root included.
    static let maximumLinkDepth = 6
    /// Set before the person's own rows, so a row by this name replaces it.
    static let fileNameHeader = "X-File-Name"
    /// Headers the transport writes itself; a row by one of these names is
    /// dropped rather than sent beside the transport's own.
    static let reservedHeaderNames: Set<String> = [
        "content-length", "host", "connection", "transfer-encoding", "expect",
    ]

    private static let headerNameScalars = CharacterSet(
        charactersIn: "!#$%&'*+-.^_`|~0123456789"
            + "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    private static let unreservedScalars = CharacterSet(
        charactersIn: "-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    /// Printable ASCII less the percent sign, so a decoded value reads back
    /// exactly and a control character can never reach the request line.
    private static let fileNameScalars = CharacterSet(
        charactersIn: Unicode.Scalar(0x20)...Unicode.Scalar(0x7E))
        .subtracting(CharacterSet(charactersIn: "%"))

    // MARK: - Address

    /// Unlike the temporary-link sanitizer, the path and any query the address
    /// carries stay: they are part of where the server listens.
    static func sanitizedEndpoint(_ value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              var components = URLComponents(string: trimmed),
              components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty,
              components.user == nil,
              components.password == nil,
              components.fragment == nil
        else { return nil }
        components.scheme = "https"
        return components.url
    }

    static func endpoint(_ destination: Destination) -> URL? {
        sanitizedEndpoint(destination.url)
    }

    static func host(_ destination: Destination) -> String? {
        endpoint(destination)?.host
    }

    /// Nil while uploads are switched off, so every button reads one rule.
    static func host(raw: String?, enabled: Bool) -> String? {
        guard enabled else { return nil }
        return host(Destination.decoded(raw))
    }

    // MARK: - Rows

    /// An RFC 7230 token.
    static func isValidHeaderName(_ name: String) -> Bool {
        !name.isEmpty && name.unicodeScalars.allSatisfy { headerNameScalars.contains($0) }
    }

    static func isUsableHeaderName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidHeaderName(trimmed) && !reservedHeaderNames.contains(trimmed.lowercased())
    }

    static func sanitizedFields(_ fields: [Field], headers: Bool) -> [Field] {
        var kept: [Field] = []
        for field in fields where kept.count < maximumFields {
            let name = field.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            if headers, !isUsableHeaderName(name) { continue }
            let value = field.value
                .components(separatedBy: .newlines)
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespaces)
            kept.append(Field(id: field.id, name: name, value: value))
        }
        return kept
    }

    // MARK: - Request

    /// Encoded by hand so that an ampersand or a plus sign in a value
    /// survives the trip.
    static func uploadURL(destination: Destination) -> URL? {
        guard let endpoint = endpoint(destination),
              var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        else { return nil }
        let added = sanitizedFields(destination.queryItems, headers: false).map {
            "\(percentEncoded($0.name))=\(percentEncoded($0.value))"
        }
        guard !added.isEmpty else { return components.url }
        let existing = components.percentEncodedQuery ?? ""
        components.percentEncodedQuery = (existing.isEmpty ? added : [existing] + added)
            .joined(separator: "&")
        return components.url
    }

    static func headerValue(forFileName name: String) -> String {
        name.addingPercentEncoding(withAllowedCharacters: fileNameScalars) ?? ""
    }

    /// The person's headers come after the transport's own, so a row can
    /// replace Content-Type when a server insists on another, or the file name.
    static func request(destination: Destination,
                        kind: Kind,
                        contentLength: Int,
                        fileName: String) -> URLRequest? {
        guard let url = uploadURL(destination: destination) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(kind.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        request.setValue(String(contentLength), forHTTPHeaderField: "Content-Length")
        request.setValue(headerValue(forFileName: fileName), forHTTPHeaderField: fileNameHeader)
        for field in sanitizedFields(destination.headers, headers: true) {
            request.setValue(field.value, forHTTPHeaderField: field.name)
        }
        return request
    }

    // MARK: - Reply

    /// A `url` or `link` field anywhere in a JSON reply, a JSON string, or a
    /// body that is nothing but a web address. Anything else is a successful
    /// upload with nothing to copy.
    static func link(in body: Data) -> URL? {
        guard !body.isEmpty, body.count <= maximumResponseBytes else { return nil }
        if let json = try? JSONSerialization.jsonObject(with: body, options: .fragmentsAllowed) {
            if let text = json as? String { return webLink(text) }
            return nestedLink(in: json)
        }
        guard let text = String(data: body, encoding: .utf8) else { return nil }
        return webLink(text)
    }

    /// Breadth first, so `data.url` never loses to a deeper `meta.link`, and
    /// siblings in name order, so one reply always gives the same answer.
    /// Field names match whatever their case.
    private static func nestedLink(in root: Any) -> URL? {
        var level: [Any] = [root]
        var depth = 0
        while !level.isEmpty, depth < maximumLinkDepth {
            var next: [Any] = []
            for node in level {
                if let object = node as? [String: Any] {
                    let keys = object.keys.sorted()
                    for wanted in linkKeys {
                        for key in keys where key.lowercased() == wanted {
                            if let value = object[key] as? String, let link = webLink(value) {
                                return link
                            }
                        }
                    }
                    next += keys.compactMap { object[$0] }.filter(isContainer)
                } else if let array = node as? [Any] {
                    next += array.filter(isContainer)
                }
            }
            level = next
            depth += 1
        }
        return nil
    }

    private static func isContainer(_ node: Any) -> Bool {
        node is [String: Any] || node is [Any]
    }

    private static func webLink(_ value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !trimmed.contains(where: \.isWhitespace),
              let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http",
              let host = url.host, !host.isEmpty
        else { return nil }
        return url
    }

    // MARK: - Backup

    /// What a settings backup carries: the address and the name of every row,
    /// never a value. The values are the keys to that server, and a backup is
    /// a file a person hands around.
    static func portable(_ destination: Destination) -> Destination {
        Destination(url: destination.url,
                    queryItems: destination.queryItems.map { Field(id: $0.id, name: $0.name) },
                    headers: destination.headers.map { Field(id: $0.id, name: $0.name) })
    }

    /// A restore on the Mac that wrote the backup keeps the values already
    /// here: a row left blank by the backup takes the local value of the first
    /// row by the same name, as long as the address is still the same server.
    static func restored(_ restored: Destination, local: Destination) -> Destination {
        guard let endpoint = endpoint(restored), endpoint == self.endpoint(local) else {
            return restored
        }
        func filled(_ rows: [Field], from source: [Field]) -> [Field] {
            var remaining = source
            return rows.map { row in
                guard row.value.isEmpty,
                      let index = remaining.firstIndex(where: {
                          $0.name == row.name && !$0.value.isEmpty
                      })
                else { return row }
                return Field(id: row.id, name: row.name, value: remaining.remove(at: index).value)
            }
        }
        return Destination(url: restored.url,
                           queryItems: filled(restored.queryItems, from: local.queryItems),
                           headers: filled(restored.headers, from: local.headers))
    }

    private static func percentEncoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreservedScalars) ?? ""
    }
}
