// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Foundation

/// Sends a finished screenshot or recording to the configured server. Unlike
/// the temporary link services it keeps no account of what was sent; the one
/// thing kept is the link the reply named, on the clipboard. No state of its
/// own to guard, so it is not tied to the main actor.
final class CaptureUploadService {
    static let shared = CaptureUploadService()

    enum Failure: Error, Equatable {
        case invalidArtifact
        case invalidDestination
        case unavailable
        case rejected(Int)
    }

    struct Outcome {
        let kind: CaptureUploadSupport.Kind
        let host: String
        let link: URL?
    }

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        // A recording at full quality can run to gigabytes, so the limit is on
        // silence between bytes rather than on the whole transfer.
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 6 * 60 * 60
        configuration.waitsForConnectivity = false
        session = URLSession(configuration: configuration)
    }

    var destination: CaptureUploadSupport.Destination {
        CaptureUploadSupport.Destination.decoded(
            UserDefaults.standard.string(forKey: DefaultsKey.captureUploadDestination))
    }

    /// A hidden button is not a gate on its own, so the request path asks
    /// the switch again.
    private var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: DefaultsKey.captureUploadEnabled)
    }

    func upload(pngData: Data) async throws -> Outcome {
        guard !pngData.isEmpty,
              pngData.starts(with: [137, 80, 78, 71, 13, 10, 26, 10])
        else { throw Failure.invalidArtifact }
        let destination = destination
        guard isEnabled,
              let host = CaptureUploadSupport.host(destination),
              let request = CaptureUploadSupport.request(
                  destination: destination,
                  kind: .screenshot,
                  contentLength: pngData.count,
                  fileName: ScreenshotSupport.fileName(
                      prefix: FeatureStrings.screenshot(L10n.shared.language).fileNamePrefix,
                      date: Date()))
        else { throw Failure.invalidDestination }
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.upload(for: request, from: pngData)
        } catch {
            throw Failure.unavailable
        }
        return try outcome(kind: .screenshot, host: host, data: data, response: response)
    }

    func upload(recordingAt file: URL) async throws -> Outcome {
        guard let values = try? file.resourceValues(
            forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]),
              values.isRegularFile == true,
              values.isSymbolicLink != true,
              let bytes = values.fileSize,
              bytes > 0
        else { throw Failure.invalidArtifact }
        let destination = destination
        guard isEnabled,
              let host = CaptureUploadSupport.host(destination),
              let request = CaptureUploadSupport.request(
                  destination: destination,
                  kind: .recording,
                  contentLength: bytes,
                  fileName: ScreenshotSupport.fileName(
                      prefix: FeatureStrings.recorder(L10n.shared.language).fileNamePrefix,
                      date: Date(), fileExtension: "mp4"))
        else { throw Failure.invalidDestination }
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.upload(for: request, fromFile: file)
        } catch {
            throw Failure.unavailable
        }
        return try outcome(kind: .recording, host: host, data: data, response: response)
    }

    /// The link goes to the clipboard when that kind of upload asks for it:
    /// that is what the person would do with it next anyway.
    func announce(_ outcome: Outcome) {
        if let link = outcome.link,
           UserDefaults.standard.bool(forKey: outcome.kind.copyLinkDefaultsKey) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            if pasteboard.setString(link.absoluteString, forType: .string) {
                QuickToolHUD.show(icon: "link",
                                  message: FeatureStrings.screenshot(L10n.shared.language).sharedHUD)
                return
            }
        }
        QuickToolHUD.show(icon: "icloud.and.arrow.up",
                          message: String(format: strings.uploadedFormat, outcome.host))
    }

    /// A refusal names the status, which is what the person needs to look at
    /// their server with; everything else is one plain failure.
    func announce(failure: Failure) {
        let message: String
        switch failure {
        case let .rejected(status):
            message = String(format: strings.rejectedFormat, status)
        case .invalidArtifact, .invalidDestination, .unavailable:
            message = strings.failedHUD
        }
        QuickToolHUD.show(icon: "icloud.and.arrow.up", message: message)
        NSSound.beep()
    }

    /// Owner-only, in the caches folder beside the temporary link staging. A
    /// file an interrupted upload left behind is swept once it is a day old.
    static func stagingDirectory() -> URL? {
        let manager = FileManager.default
        guard let cache = manager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = cache
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.vorssaint.utils",
                                    isDirectory: true)
            .appendingPathComponent("Custom Uploads", isDirectory: true)
        do {
            try manager.createDirectory(at: directory,
                                        withIntermediateDirectories: true,
                                        attributes: [.posixPermissions: 0o700])
            try manager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: directory.path)
        } catch {
            return nil
        }
        if let files = try? manager.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.contentModificationDateKey]) {
            let cutoff = Date().addingTimeInterval(-24 * 3600)
            for file in files where (try? file.resourceValues(
                forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantFuture < cutoff {
                try? manager.removeItem(at: file)
            }
        }
        return directory
    }

    private var strings: CaptureUploadStrings {
        FeatureStrings.captureUpload(L10n.shared.language)
    }

    private func outcome(kind: CaptureUploadSupport.Kind,
                         host: String,
                         data: Data,
                         response: URLResponse) throws -> Outcome {
        guard let http = response as? HTTPURLResponse else { throw Failure.unavailable }
        guard (200...299).contains(http.statusCode) else {
            throw Failure.rejected(http.statusCode)
        }
        return Outcome(kind: kind, host: host, link: CaptureUploadSupport.link(in: data))
    }
}
