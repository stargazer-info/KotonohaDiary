//
//  DiaryStore.swift
//  KotonohaDiary SwiftUI
//

import Foundation
import UIKit
import Combine

class DiaryStore: ObservableObject {

    @Published var diaries: [DiaryDocument] = []

    private let diariesDirectoryName = "diaries"

    private var diariesDirectory: URL {
        let url = DocumentStoreBase.rootURL().appendingPathComponent(diariesDirectoryName)
        DocumentStoreBase.ensureDirectory(at: url)
        return url
    }

    init() {
        loadAll()
    }

    // MARK: - CRUD

    func create(text: String, images: [UIImage]) {
        let doc = DiaryDocument(text: text, createdAt: Date(), imageFilenames: images.indices.map { "\($0).jpg" })
        let dirURL = packageURL(for: doc)
        DocumentStoreBase.ensureDirectory(at: dirURL)

        // content.json
        saveContent(doc, to: dirURL)

        // images
        let imagesDir = dirURL.appendingPathComponent("images")
        DocumentStoreBase.ensureDirectory(at: imagesDir)
        for (i, image) in images.enumerated() {
            let data = ImageUtility.jpegData(from: image)
            try? data.write(to: imagesDir.appendingPathComponent("\(i).jpg"))
        }

        diaries.append(doc)
        sortDiaries()
    }

    func update(_ diary: DiaryDocument, text: String, images: [UIImage]) {
        guard let index = diaries.firstIndex(where: { $0.id == diary.id }) else { return }

        var updated = diary
        updated.text = text
        updated.imageFilenames = images.indices.map { "\($0).jpg" }

        let dirURL = packageURL(for: updated)

        // 古い images を削除
        let imagesDir = dirURL.appendingPathComponent("images")
        try? FileManager.default.removeItem(at: imagesDir)
        DocumentStoreBase.ensureDirectory(at: imagesDir)

        // 新しい images を保存
        for (i, image) in images.enumerated() {
            let data = ImageUtility.jpegData(from: image)
            try? data.write(to: imagesDir.appendingPathComponent("\(i).jpg"))
        }

        // content.json を更新
        saveContent(updated, to: dirURL)

        diaries[index] = updated
        sortDiaries()
    }

    func delete(_ diary: DiaryDocument) {
        let dirURL = packageURL(for: diary)
        try? FileManager.default.removeItem(at: dirURL)
        diaries.removeAll { $0.id == diary.id }
    }

    func loadImages(for diary: DiaryDocument) -> [UIImage] {
        let imagesDir = packageURL(for: diary).appendingPathComponent("images")
        return diary.imageFilenames.compactMap { filename in
            let fileURL = imagesDir.appendingPathComponent(filename)
            guard let data = try? Data(contentsOf: fileURL) else { return nil }
            return UIImage(data: data)
        }
    }

    // MARK: - Load

    func loadAll() {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: diariesDirectory, includingPropertiesForKeys: nil) else {
            diaries = []
            return
        }
        diaries = contents
            .filter { $0.pathExtension == "kdiary" }
            .compactMap { dirURL in
                let jsonURL = dirURL.appendingPathComponent("content.json")
                guard let data = try? Data(contentsOf: jsonURL) else { return nil }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try? decoder.decode(DiaryDocument.self, from: data)
            }
        sortDiaries()
    }

    // MARK: - Private

    private func packageURL(for diary: DiaryDocument) -> URL {
        return diariesDirectory.appendingPathComponent("\(diary.id).kdiary")
    }

    private func saveContent(_ diary: DiaryDocument, to dirURL: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(diary) {
            try? data.write(to: dirURL.appendingPathComponent("content.json"))
        }
    }

    private func sortDiaries() {
        diaries.sort { ($0.createdAt) > ($1.createdAt) }
    }

    // MARK: - Migration support

    func createFromMigration(id: String, text: String, createdAt: Date, images: [UIImage]) {
        let doc = DiaryDocument(id: id, text: text, createdAt: createdAt, imageFilenames: images.indices.map { "\($0).jpg" })
        let dirURL = packageURL(for: doc)
        DocumentStoreBase.ensureDirectory(at: dirURL)

        saveContent(doc, to: dirURL)

        let imagesDir = dirURL.appendingPathComponent("images")
        DocumentStoreBase.ensureDirectory(at: imagesDir)
        for (i, image) in images.enumerated() {
            let data = ImageUtility.jpegData(from: image)
            try? data.write(to: imagesDir.appendingPathComponent("\(i).jpg"))
        }

        diaries.append(doc)
        sortDiaries()
    }
}
