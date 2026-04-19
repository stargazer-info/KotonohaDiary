//
//  CoreDataMigrator.swift
//  KotonohaDiary SwiftUI
//

import Foundation
import CoreData
import UIKit

class CoreDataMigrator {

    private static let migrationKey = "CoreDataMigrationCompleted_v1"

    static var isMigrationNeeded: Bool {
        return !UserDefaults.standard.bool(forKey: migrationKey)
    }

    /// - Returns: `true` if migration succeeded (or was not needed), `false` if the CoreData store failed to load.
    @discardableResult
    static func migrateIfNeeded(diaryStore: DiaryStore, kotonohaStore: KotonohaStore) async -> Bool {
        guard isMigrationNeeded else { return true }
        guard coreDataStoreExists() else {
            markMigrationCompleted()
            return true
        }

        let container = NSPersistentContainer(name: "KotonohaDiary")
        var loadFailed = false

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            container.loadPersistentStores { _, error in
                if let error {
                    print("CoreDataMigrator: Failed to load Core Data store: \(error)")
                    loadFailed = true
                }
                continuation.resume()
            }
        }

        guard !loadFailed else { return false }

        // CoreData フェッチと画像デコードをバックグラウンドで実行
        let diaryItems = await collectDiaries(container: container)
        let kotonohaItems = await collectKotonohas(container: container)

        // ファイル書き込みと @Published 更新はメインアクターで実行
        await MainActor.run {
            for item in diaryItems {
                diaryStore.createFromMigration(id: item.id, text: item.text, createdAt: item.createdAt, images: item.images)
                print("CoreDataMigrator: Migrated diary '\(item.text.prefix(20))...' with \(item.images.count) images.")
            }
            for item in kotonohaItems {
                kotonohaStore.createFromMigration(id: item.id, text: item.text, createdAt: item.createdAt, image: item.image)
                print("CoreDataMigrator: Migrated kotonoha '\(item.text?.prefix(20) ?? "(image)")'.")
            }
            markMigrationCompleted()
            print("CoreDataMigrator: Migration completed successfully.")
        }
        return true
    }

    // MARK: - Data Collection (runs on background context)

    private struct DiaryMigrationItem {
        let id: String
        let text: String
        let createdAt: Date
        let images: [UIImage]
    }

    private struct KotononhaMigrationItem {
        let id: String
        let text: String?
        let createdAt: Date
        let image: UIImage?
    }

    private static func collectDiaries(container: NSPersistentContainer) async -> [DiaryMigrationItem] {
        let context = container.newBackgroundContext()
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Diary")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            guard let results = try? context.fetch(request) else { return [] }
            return results.map { diary in
                let id = diary.value(forKey: "id") as? String ?? UUID().uuidString
                let text = diary.value(forKey: "text") as? String ?? ""
                let createdAt = diary.value(forKey: "createdAt") as? Date ?? Date()
                var images: [UIImage] = []
                if let imageSet = diary.value(forKey: "images") as? NSOrderedSet,
                   let imageDataArray = imageSet.array as? [NSManagedObject] {
                    images = imageDataArray.compactMap { obj in
                        guard let data = obj.value(forKey: "data") as? Data else { return nil }
                        return UIImage(data: data)
                    }
                }
                return DiaryMigrationItem(id: id, text: text, createdAt: createdAt, images: images)
            }
        }
    }

    private static func collectKotonohas(container: NSPersistentContainer) async -> [KotononhaMigrationItem] {
        let context = container.newBackgroundContext()
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Kotonoha")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            guard let results = try? context.fetch(request) else { return [] }
            return results.map { kotonoha in
                let id = kotonoha.value(forKey: "id") as? String ?? UUID().uuidString
                let text = kotonoha.value(forKey: "text") as? String
                let createdAt = kotonoha.value(forKey: "createdAt") as? Date ?? Date()
                var image: UIImage? = nil
                if let imageObj = kotonoha.value(forKey: "image") as? NSManagedObject,
                   let data = imageObj.value(forKey: "data") as? Data {
                    image = UIImage(data: data)
                }
                return KotononhaMigrationItem(id: id, text: text, createdAt: createdAt, image: image)
            }
        }
    }

    // MARK: - Helpers

    private static func coreDataStoreExists() -> Bool {
        guard let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("KotonohaDiary.sqlite") else {
            return false
        }
        return FileManager.default.fileExists(atPath: storeURL.path)
    }

    private static func markMigrationCompleted() {
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
}
