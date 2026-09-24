// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Uploading a capture to a server: what the request carries, what a reply
/// may give back, and what a settings backup does with the keys to that server.
enum CaptureUploadTests {
    static func run(_ suite: TestSuite) {
        typealias Field = CaptureUploadSupport.Field
        typealias Destination = CaptureUploadSupport.Destination

        // MARK: Address

        suite.expect(CaptureUploadSupport.sanitizedEndpoint(" https://example.com/upload?dir=shots ")?
                .absoluteString == "https://example.com/upload?dir=shots",
               "an https address keeps its path and its own query")
        suite.expect(CaptureUploadSupport.sanitizedEndpoint("HTTPS://example.com")?.absoluteString
                == "https://example.com",
               "the scheme is read whatever its case")
        for rejected in ["", "example.com/upload", "http://example.com/upload",
                         "https://user:secret@example.com/upload",
                         "https://example.com/upload#part", "https:///upload",
                         "ftp://example.com"] {
            suite.expect(CaptureUploadSupport.sanitizedEndpoint(rejected) == nil,
                   "an address an upload cannot use is refused: \(rejected)")
        }
        suite.expect(CaptureUploadSupport.host(Destination(url: "https://files.example.com/api/upload"))
                == "files.example.com"
                && CaptureUploadSupport.host(Destination()) == nil,
               "the menu names the server, and nothing while no address is set")

        // MARK: Request

        let destination = Destination(
            url: "https://example.com/upload?dir=shots",
            queryItems: [Field(name: " folder ", value: "a b&c+d"),
                         Field(name: "", value: "nameless"),
                         Field(name: "flag", value: "")],
            headers: [Field(name: "Authorization", value: " Bearer token "),
                      Field(name: "Content-Length", value: "1"),
                      Field(name: "bad name", value: "x"),
                      Field(name: "X-Note", value: "line one\nline two"),
                      Field(name: "Content-Type", value: "application/octet-stream")])
        let request = CaptureUploadSupport.request(destination: destination,
                                                   kind: .screenshot,
                                                   contentLength: 12_345,
                                                   fileName: "Screenshot 2026-09-23 at 10.00.00.png")
        suite.expect(request?.url?.absoluteString
                == "https://example.com/upload?dir=shots&folder=a%20b%26c%2Bd&flag=",
               "query parameters follow the address's own, encoded so any character survives")
        suite.expect(request?.httpMethod == "POST",
               "the file is sent with a POST")
        suite.expect(request?.value(forHTTPHeaderField: "Authorization") == "Bearer token",
               "a header row is sent with its value trimmed")
        suite.expect(request?.value(forHTTPHeaderField: "Content-Length") == "12345",
               "the transport keeps its own Content-Length")
        suite.expect(request?.value(forHTTPHeaderField: "bad name") == nil,
               "a header name that is not a token is left out")
        suite.expect(request?.value(forHTTPHeaderField: "X-Note") == "line one line two",
               "a header value cannot start a new line of the request")
        suite.expect(request?.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream",
               "a header row can replace the content type a server will not accept")
        suite.expect(request?.value(forHTTPHeaderField: "X-File-Name")
                == "Screenshot 2026-09-23 at 10.00.00.png",
               "the name the file would have been saved under travels in X-File-Name")
        suite.expect(CaptureUploadSupport.headerValue(forFileName: "Bildschirmfoto Ä 1%.png")
                == "Bildschirmfoto %C3%84 1%25.png"
                && CaptureUploadSupport.headerValue(forFileName: "a\r\nb.png") == "a%0D%0Ab.png",
               "a file name keeps its ASCII and percent-encodes the rest, line breaks included")
        let renamed = Destination(url: "https://example.com/u",
                                  headers: [Field(name: "x-file-name", value: "custom.png")])
        suite.expect(CaptureUploadSupport.request(destination: renamed, kind: .screenshot,
                                                  contentLength: 1, fileName: "Screenshot.png")?
                .value(forHTTPHeaderField: "X-File-Name") == "custom.png",
               "a header row by the same name replaces the file name")
        let plain = Destination(url: "https://example.com/u")
        suite.expect(CaptureUploadSupport.request(destination: plain, kind: .screenshot,
                                                  contentLength: 1, fileName: "a.png")?
                .value(forHTTPHeaderField: "Content-Type") == "image/png"
                && CaptureUploadSupport.request(destination: plain, kind: .recording,
                                                contentLength: 1, fileName: "a.mp4")?
                .value(forHTTPHeaderField: "Content-Type") == "video/mp4",
               "a screenshot is sent as a PNG and a recording as an MP4")
        suite.expect(CaptureUploadSupport.request(destination: Destination(url: "https://example.com"),
                                                  kind: .screenshot, contentLength: 1,
                                                  fileName: "a.png")?
                .url?.absoluteString == "https://example.com",
               "an address without rows is sent as typed")
        suite.expect(CaptureUploadSupport.request(destination: Destination(url: "http://example.com/u"),
                                                  kind: .screenshot, contentLength: 1,
                                                  fileName: "a.png") == nil,
               "no request is built for an address an upload cannot use")
        let crowded = Destination(url: "https://example.com/u",
                                  queryItems: (0..<30).map { Field(name: "p\($0)", value: "\($0)") })
        suite.expect(CaptureUploadSupport.uploadURL(destination: crowded)?.query?
                .components(separatedBy: "&").count == CaptureUploadSupport.maximumFields,
               "the rows a request carries are capped")
        suite.expect(!CaptureUploadSupport.isUsableHeaderName("Host")
                && !CaptureUploadSupport.isUsableHeaderName("x y")
                && !CaptureUploadSupport.isUsableHeaderName("")
                && CaptureUploadSupport.isUsableHeaderName(" X-Api-Key "),
               "the settings page flags the header names a request would leave out")

        // MARK: Reply

        func link(_ text: String) -> String? {
            CaptureUploadSupport.link(in: Data(text.utf8))?.absoluteString
        }
        suite.expect(link(#"{"url":"https://example.com/s/abc","id":"abc"}"#)
                == "https://example.com/s/abc",
               "a JSON reply with a url is the link")
        suite.expect(link(#"{"link":"https://example.com/s/abc"}"#) == "https://example.com/s/abc",
               "a JSON reply may call it link instead")
        suite.expect(link(#""https://example.com/s/abc""#) == "https://example.com/s/abc",
               "a JSON string on its own is the link")
        suite.expect(link("https://example.com/s/abc\n") == "https://example.com/s/abc",
               "a plain text reply that is nothing but a URL is the link")
        suite.expect(link(#"{"success":true,"data":{"fileId":"x","size":1,"sha256":"y","url":"https://example.com/f/x"}}"#)
                == "https://example.com/f/x",
               "a url inside a data object is found")
        suite.expect(link(#"{"meta":{"link":"https://example.com/deep"},"url":"https://example.com/top"}"#)
                == "https://example.com/top"
                && link(#"{"a":{"b":{"url":"https://example.com/deep"}},"data":{"url":"https://example.com/near"}}"#)
                == "https://example.com/near",
               "the link nearest the top of the reply wins")
        suite.expect(link(#"{"b":{"url":"https://example.com/b"},"a":{"url":"https://example.com/a"}}"#)
                == "https://example.com/a",
               "between siblings the first by name wins, whatever order the reply lists them")
        suite.expect(link(#"{"files":[{"url":"https://example.com/first"},{"url":"https://example.com/second"}]}"#)
                == "https://example.com/first",
               "a list of files gives its first link")
        suite.expect(link(#"{"data":{"URL":"https://example.com/x"}}"#) == "https://example.com/x",
               "a field name matches whatever its case")
        suite.expect(link(#"{"data":{"url":"not a link"},"url":"https://example.com/top"}"#)
                == "https://example.com/top"
                && link(#"{"data":{"url":"not a link"}}"#) == nil,
               "a url field that holds no address is passed over")
        func nested(_ depth: Int) -> String {
            String(repeating: #"{"a":"#, count: depth) + #"{"url":"https://example.com/x"}"#
                + String(repeating: "}", count: depth)
        }
        suite.expect(link(nested(CaptureUploadSupport.maximumLinkDepth - 1)) == "https://example.com/x"
                && link(nested(CaptureUploadSupport.maximumLinkDepth)) == nil,
               "the search stops at a fixed depth")
        for none in ["", "ok", #"{"url":5}"#, #"{"data":{"fileId":"x"}}"#, #"[1,2,3]"#,
                     "ftp://example.com/s/abc", "https://example.com/a b",
                     "saved https://example.com/s/abc"] {
            suite.expect(link(none) == nil, "a reply without a usable link yields none: \(none)")
        }
        suite.expect(CaptureUploadSupport.link(in: Data(
                repeating: UInt8(ascii: "a"),
                count: CaptureUploadSupport.maximumResponseBytes + 1)) == nil,
               "an oversized reply is not searched for a link")

        // MARK: Storage

        suite.expect(Destination().encoded() == "" && Destination.decoded("") == Destination()
                && Destination.decoded("not json") == Destination(),
               "no destination stores as the empty registered default and damage reads as none")
        suite.expect(Destination.decoded(destination.encoded()) == destination,
               "a destination survives the trip through its stored form")
        let handEdited = Destination.decoded(
            #"{"url":"https://example.com/u","headers":[{"name":"X-Api-Key","value":"k"}]}"#)
        suite.expect(handEdited.url == "https://example.com/u"
                && handEdited.headers.map(\.name) == ["X-Api-Key"]
                && handEdited.queryItems.isEmpty,
               "rows without ids and missing lists still read")
        suite.expect(Defaults.registeredDefaults[DefaultsKey.captureUploadDestination] as? String == "",
               "the destination ships empty")
        suite.expect(Defaults.registeredDefaults[DefaultsKey.captureUploadEnabled] as? Bool == false
                && SettingsBackupSupport.exportKeys().contains(DefaultsKey.captureUploadEnabled),
               "uploads ship switched off, and the switch travels in backups")
        let stored = Destination(url: "https://files.example.com/u").encoded()
        suite.expect(CaptureUploadSupport.host(raw: stored, enabled: true) == "files.example.com"
                && CaptureUploadSupport.host(raw: stored, enabled: false) == nil
                && CaptureUploadSupport.host(raw: "", enabled: true) == nil,
               "a button appears only while uploads are on and the address is usable")
        suite.expect(Defaults.registeredDefaults[DefaultsKey.captureUploadCopyScreenshotLink] as? Bool == true
                && Defaults.registeredDefaults[DefaultsKey.captureUploadCopyRecordingLink] as? Bool == true,
               "an answered link is copied for both kinds until switched off")
        suite.expect(CaptureUploadSupport.Kind.screenshot.copyLinkDefaultsKey
                    == DefaultsKey.captureUploadCopyScreenshotLink
                && CaptureUploadSupport.Kind.recording.copyLinkDefaultsKey
                    == DefaultsKey.captureUploadCopyRecordingLink
                && SettingsBackupSupport.exportKeys().contains(DefaultsKey.captureUploadCopyScreenshotLink)
                && SettingsBackupSupport.exportKeys().contains(DefaultsKey.captureUploadCopyRecordingLink),
               "each kind of upload has its own copy choice, and both travel in backups")

        // MARK: Backup

        let portable = CaptureUploadSupport.portable(destination)
        suite.expect(portable.url == destination.url
                && portable.headers.map(\.name) == destination.headers.map(\.name)
                && portable.queryItems.map(\.name) == destination.queryItems.map(\.name)
                && portable.headers.allSatisfy { $0.value.isEmpty }
                && portable.queryItems.allSatisfy { $0.value.isEmpty },
               "a backup carries the address and the names, never a value")
        suite.expect(CaptureUploadSupport.restored(portable, local: destination) == destination,
               "restoring where the backup was written keeps the values already there")
        suite.expect(CaptureUploadSupport.restored(
                portable,
                local: Destination(url: "https://other.example.com/u",
                                   headers: destination.headers)) == portable,
               "a value belongs to one server and is not carried to another address")
        var edited = portable
        edited.headers[0].value = "Bearer newer"
        suite.expect(CaptureUploadSupport.restored(edited, local: destination)
                .headers[0].value == "Bearer newer",
               "a value the backup does carry wins over the local one")
        suite.expect(SettingsBackupSupport.exportKeys().contains(DefaultsKey.captureUploadDestination),
               "the upload destination travels with settings backup")
        let payload = SettingsBackupSupport.payload(appVersion: "test") { key in
            key == DefaultsKey.captureUploadDestination ? destination.encoded() : nil
        }
        let exported = (payload[SettingsBackupSupport.settingsKey] as? [String: Any])?[
            DefaultsKey.captureUploadDestination] as? String
        suite.expect(Destination.decoded(exported) == portable,
               "the exported file holds the portable destination")
        let imported = SettingsBackupSupport.sanitizedSettings(from: [
            SettingsBackupSupport.formatVersionKey: SettingsBackupSupport.formatVersion,
            SettingsBackupSupport.settingsKey: [
                DefaultsKey.captureUploadDestination: destination.encoded(),
            ],
        ])?[DefaultsKey.captureUploadDestination] as? String
        suite.expect(Destination.decoded(imported) == portable,
               "a file that does carry values is imported without them")
        suite.expect(Destination.decoded(SettingsBackupSupport.restoredUploadDestination(
                restored: portable.encoded(), local: destination.encoded())) == destination
                && SettingsBackupSupport.restoredUploadDestination(
                    restored: nil, local: destination.encoded()) == "",
               "the restore keeps local values for the same server and clears when the file has none")

        // MARK: Settings

        suite.expect(SettingsSearchSupport.screenCaptureKeywords(Strings.enUS, language: .enUS)
                .contains(FeatureStrings.captureUpload(.enUS).sectionTitle),
               "the upload section is findable through Settings search")
        suite.expect(FeatureStrings.captureUpload(.enUS).menuItemFormat.contains("%@")
                && FeatureStrings.captureUpload(.enUS).rejectedFormat.contains("%d"),
               "the menu names the server and a refusal names the status")
    }
}
