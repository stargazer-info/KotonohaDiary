//
//  DocumentStoreBase.swift
//  KotonohaDiary SwiftUI
//

import Foundation

class DocumentStoreBase {

    /// iCloud Drive が利用可能ならその URL、なければローカル Documents を返す
    static func rootURL() -> URL {
        if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            let documentsURL = iCloudURL.appendingPathComponent("Documents")
            ensureDirectory(at: documentsURL)
            return documentsURL
        } else {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }

    static func ensureDirectory(at url: URL) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}
