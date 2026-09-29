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

        /// A fresh setup sends the file's name in an X-File-Name header, as a
        /// row that can be renamed, moved to a parameter or deleted. The id is
        /// fixed so the untouched row compares equal across launches.
        static let initial = Destination(headers: [
            Field(id: UUID(uuidString: "5F1E0000-0000-4000-8000-000000000001")!,
                  name: "X-File-Name",
                  value: CaptureUploadSupport.fileNamePlaceholder),
        ])

        /// The untouched fresh setup stores as the empty registered default.
        /// Anything else is kept as JSON, an emptied one included, so a deleted
        /// file name row stays deleted.
        func encoded() -> String {
            guard self != .initial, let data = try? JSONEncoder().encode(self) else { return "" }
            return String(data: data, encoding: .utf8) ?? ""
        }

        static func decoded(_ raw: String?) -> Destination {
            guard let raw, !raw.isEmpty,
                  let data = raw.data(using: .utf8),
                  let destination = try? JSONDecoder().decode(Destination.self, from: data)
            else { return .initial }
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
    /// Stands for the file's name in a parameter or header value, whatever
    /// its case.
    static let fileNamePlaceholder = "%filename%"
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
    /// survives the trip. The file's name goes in before encoding.
    static func uploadURL(destination: Destination, fileName: String) -> URL? {
        guard let endpoint = endpoint(destination),
              var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        else { return nil }
        let added = sanitizedFields(destination.queryItems, headers: false).map {
            "\(percentEncoded($0.name))=\(percentEncoded(expanded($0.value, fileName: fileName)))"
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

    static func expanded(_ value: String, fileName: String) -> String {
        value.replacingOccurrences(of: fileNamePlaceholder, with: fileName, options: .caseInsensitive)
    }

    /// The person's headers come after the transport's own, so a row can
    /// replace Content-Type when a server insists on another.
    static func request(destination: Destination,
                        kind: Kind,
                        contentLength: Int,
                        fileName: String) -> URLRequest? {
        guard let url = uploadURL(destination: destination, fileName: fileName) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(kind.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        request.setValue(String(contentLength), forHTTPHeaderField: "Content-Length")
        let headerFileName = headerValue(forFileName: fileName)
        for field in sanitizedFields(destination.headers, headers: true) {
            request.setValue(expanded(field.value, fileName: headerFileName),
                             forHTTPHeaderField: field.name)
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

    /// What a settings backup carries: the address, the name of every row and
    /// a value only when it is the placeholder alone. Other values are the
    /// keys to that server, and a backup is a file a person hands around.
    static func portable(_ destination: Destination) -> Destination {
        func row(_ field: Field) -> Field {
            Field(id: field.id, name: field.name,
                  value: isPlaceholderOnly(field.value) ? field.value : "")
        }
        return Destination(url: portableAddress(destination.url),
                           queryItems: destination.queryItems.map(row),
                           headers: destination.headers.map(row))
    }

    private static func isPlaceholderOnly(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty
            && expanded(trimmed, fileName: "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// The address a backup can carry: without the query or credentials it
    /// holds, since either can be a key to the server.
    static func portableAddress(_ address: String) -> String {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              components.host?.isEmpty == false
        else { return "" }
        components.percentEncodedQuery = nil
        components.user = nil
        components.password = nil
        components.fragment = nil
        return components.string ?? ""
    }

    /// A restore on the Mac that wrote the backup keeps what is already here
    /// when the address still names the same server: the address takes back
    /// the query the backup left out, and a row left blank takes the local
    /// value of the first row by the same name.
    static func restored(_ restored: Destination, local: Destination) -> Destination {
        let address = portableAddress(restored.url)
        guard endpoint(restored) != nil, address == portableAddress(local.url) else {
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
        return Destination(url: restored.url == address ? local.url : restored.url,
                           queryItems: filled(restored.queryItems, from: local.queryItems),
                           headers: filled(restored.headers, from: local.headers))
    }

    struct AddressLift {
        let destination: Destination
        let movedQuery: Bool
        let movedCredentials: Bool
    }

    /// Turns a query typed or pasted into the address into parameter rows,
    /// ahead of the rows already there, and a user name and password into an
    /// Authorization: Basic header, so either is kept out of backups like any
    /// other value. A part stays in the address when its rows would not fit,
    /// or when an Authorization header is already set. Nil when nothing moved.
    static func liftingAddressParts(_ destination: Destination) -> AddressLift? {
        let trimmed = destination.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed) else { return nil }
        var result = destination
        var movedQuery = false
        var movedCredentials = false
        if let query = components.percentEncodedQuery, !query.isEmpty {
            let lifted = query.split(separator: "&").compactMap { pair -> Field? in
                let parts = pair.split(separator: "=", maxSplits: 1,
                                       omittingEmptySubsequences: false)
                let name = formDecoded(parts[0])
                guard !name.isEmpty else { return nil }
                return Field(name: name, value: parts.count > 1 ? formDecoded(parts[1]) : "")
            }
            if !lifted.isEmpty, lifted.count + destination.queryItems.count <= maximumFields {
                components.percentEncodedQuery = nil
                result.queryItems = lifted + destination.queryItems
                movedQuery = true
            }
        }
        if let user = components.user, !user.isEmpty,
           destination.headers.count < maximumFields,
           !destination.headers.contains(where: {
               $0.name.trimmingCharacters(in: .whitespaces).lowercased() == "authorization"
           }) {
            let token = Data("\(user):\(components.password ?? "")".utf8).base64EncodedString()
            result.headers.append(Field(name: "Authorization", value: "Basic \(token)"))
            components.user = nil
            components.password = nil
            movedCredentials = true
        }
        guard movedQuery || movedCredentials else { return nil }
        result.url = components.string ?? destination.url
        return AddressLift(destination: result, movedQuery: movedQuery,
                           movedCredentials: movedCredentials)
    }

    /// A plus is a space in a query, the way servers read one.
    private static func formDecoded(_ part: Substring) -> String {
        let spaced = part.replacingOccurrences(of: "+", with: " ")
        return spaced.removingPercentEncoding ?? spaced
    }

    private static func percentEncoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreservedScalars) ?? ""
    }
}
