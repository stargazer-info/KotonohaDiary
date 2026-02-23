//
//  KotonohaStore.swift
//  KotonohaDiary SwiftUI
//

import Foundation
import UIKit
import Combine

class KotonohaStore: ObservableObject {

    @Published var kotonohas: [KotonohaDocument] = []

    private let kotonohasDirectoryName = "kotonohas"

    private var kotonohasDirectory: URL {
        let url = DocumentStoreBase.rootURL().appendingPathComponent(kotonohasDirectoryName)
        DocumentStoreBase.ensureDirectory(at: url)
        return url
    }

    init() {
        loadAll()
    }

    // MARK: - CRUD

    func create(text: String) {
        let doc = KotonohaDocument(text: text, createdAt: Date(), hasImage: false)
        saveDocument(doc)
        kotonohas.append(doc)
        sortKotonohas()
    }

    func create(image: UIImage) {
        let doc = KotonohaDocument(text: nil, createdAt: Date(), hasImage: true)
        saveDocument(doc)
        saveImage(image, for: doc)
        kotonohas.append(doc)
        sortKotonohas()
    }

    func update(text: String, kotonoha: KotonohaDocument) {
        guard let index = kotonohas.firstIndex(where: { $0.id == kotonoha.id }) else { return }
        var updated = kotonoha
        updated.text = text
        updated.hasImage = false
        // 画像があれば削除
        removeImage(for: kotonoha)
        saveDocument(updated)
        kotonohas[index] = updated
        sortKotonohas()
    }

    func delete(kotonoha: KotonohaDocument) {
        let fileURL = documentURL(for: kotonoha)
        try? FileManager.default.removeItem(at: fileURL)
        removeImage(for: kotonoha)
        kotonohas.removeAll { $0.id == kotonoha.id }
    }

    func loadImage(for kotonoha: KotonohaDocument) -> UIImage? {
        let imageURL = imageURL(for: kotonoha)
        guard let data = try? Data(contentsOf: imageURL) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Load

    func loadAll() {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: kotonohasDirectory, includingPropertiesForKeys: nil) else {
            kotonohas = []
            return
        }
        kotonohas = contents
            .filter { $0.pathExtension == "kotonoha" }
            .compactMap { fileURL in
                guard let data = try? Data(contentsOf: fileURL) else { return nil }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try? decoder.decode(KotonohaDocument.self, from: data)
            }
        sortKotonohas()
    }

    // MARK: - Sections (for UI compatibility)

    struct KotonohaSection: Identifiable {
        var id: String { section }
        var section: String
        var kotonohas: [KotonohaDocument]
    }

    var sections: [KotonohaSection] {
        let grouped = Dictionary(grouping: kotonohas) { $0.section }
        return grouped
            .map { KotonohaSection(section: $0.key, kotonohas: $0.value) }
            .sorted { $0.kotonohas.first?.createdAt ?? .distantPast > $1.kotonohas.first?.createdAt ?? .distantPast }
    }

    // MARK: - Private

    private func documentURL(for kotonoha: KotonohaDocument) -> URL {
        return kotonohasDirectory.appendingPathComponent("\(kotonoha.id).kotonoha")
    }

    private func imageURL(for kotonoha: KotonohaDocument) -> URL {
        return kotonohasDirectory.appendingPathComponent("\(kotonoha.id).jpg")
    }

    private func saveDocument(_ kotonoha: KotonohaDocument) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(kotonoha) {
            try? data.write(to: documentURL(for: kotonoha))
        }
    }

    private func saveImage(_ image: UIImage, for kotonoha: KotonohaDocument) {
        let data = ImageUtility.jpegData(from: image)
        try? data.write(to: imageURL(for: kotonoha))
    }

    private func removeImage(for kotonoha: KotonohaDocument) {
        try? FileManager.default.removeItem(at: imageURL(for: kotonoha))
    }

    private func sortKotonohas() {
        kotonohas.sort { $0.createdAt > $1.createdAt }
    }

    // MARK: - Migration support

    func createFromMigration(id: String, text: String?, createdAt: Date, image: UIImage?) {
        let hasImage = image != nil
        let doc = KotonohaDocument(id: id, text: text, createdAt: createdAt, hasImage: hasImage)
        saveDocument(doc)
        if let image = image {
            saveImage(image, for: doc)
        }
        kotonohas.append(doc)
        sortKotonohas()
    }
}
