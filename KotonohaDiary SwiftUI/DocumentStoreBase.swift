//
//  DocumentStoreBase.swift
//  KotonohaDiary SwiftUI
//

import Foundation

class DocumentStoreBase {

    private static let queue = DispatchQueue(label: "com.stargazer.KotonohaDiary.DocumentStoreBase")
    nonisolated(unsafe) private static var cachedRootURL: URL?

    /// iCloud コンテナ URL の解決はメインスレッドをブロックするため、
    /// 起動時に一度だけバックグラウンドで解決してキャッシュする。
    static func prepare() async {
        if getCachedURL() != nil { return }
        let url = await Task.detached(priority: .userInitiated) {
            resolveRootURL()
        }.value
        setCachedURL(url)
    }

    /// iCloud Drive が利用可能ならその URL、なければローカル Documents を返す。
    static func rootURL() -> URL {
        if let url = getCachedURL() { return url }
        let url = resolveRootURL()
        setCachedURL(url)
        return url
    }

    static func ensureDirectory(at url: URL) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    private static func getCachedURL() -> URL? {
        queue.sync { cachedRootURL }
    }

    private static func setCachedURL(_ url: URL) {
        queue.sync { cachedRootURL = url }
    }

    private static func resolveRootURL() -> URL {
        if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            let documentsURL = iCloudURL.appendingPathComponent("Documents")
            ensureDirectory(at: documentsURL)
            return documentsURL
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
