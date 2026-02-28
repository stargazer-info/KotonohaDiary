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

    @MainActor
    static func migrateIfNeeded(diaryStore: DiaryStore, kotonohaStore: KotonohaStore) async {
        guard isMigrationNeeded else { return }
        guard coreDataStoreExists() else {
            markMigrationCompleted()
            return
        }

        let container = NSPersistentContainer(name: "KotonohaDiary")

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("CoreDataMigrator: Failed to load Core Data store: \(error)")
                }
                continuation.resume()
            }
        }

        let context = container.viewContext

        migrateDiaries(context: context, diaryStore: diaryStore)
        migrateKotonohas(context: context, kotonohaStore: kotonohaStore)

        markMigrationCompleted()
        print("CoreDataMigrator: Migration completed successfully.")
    }

    // MARK: - Diary Migration

    private static func migrateDiaries(context: NSManagedObjectContext, diaryStore: DiaryStore) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        guard let results = try? context.fetch(request) else {
            print("CoreDataMigrator: No diaries found.")
            return
        }

        for diary in results {
            let id = diary.value(forKey: "id") as? String ?? UUID().uuidString
            let text = diary.value(forKey: "text") as? String ?? ""
            let createdAt = diary.value(forKey: "createdAt") as? Date ?? Date()

            var images: [UIImage] = []
            if let imageSet = diary.value(forKey: "images") as? NSOrderedSet,
               let imageDataArray = imageSet.array as? [NSManagedObject] {
                for imageObj in imageDataArray {
                    if let data = imageObj.value(forKey: "data") as? Data,
                       let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }

            diaryStore.createFromMigration(id: id, text: text, createdAt: createdAt, images: images)
            print("CoreDataMigrator: Migrated diary '\(text.prefix(20))...' with \(images.count) images.")
        }
    }

    // MARK: - Kotonoha Migration

    private static func migrateKotonohas(context: NSManagedObjectContext, kotonohaStore: KotonohaStore) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Kotonoha")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        guard let results = try? context.fetch(request) else {
            print("CoreDataMigrator: No kotonohas found.")
            return
        }

        for kotonoha in results {
            let id = kotonoha.value(forKey: "id") as? String ?? UUID().uuidString
            let text = kotonoha.value(forKey: "text") as? String
            let createdAt = kotonoha.value(forKey: "createdAt") as? Date ?? Date()

            var image: UIImage? = nil
            if let imageObj = kotonoha.value(forKey: "image") as? NSManagedObject,
               let data = imageObj.value(forKey: "data") as? Data {
                image = UIImage(data: data)
            }

            kotonohaStore.createFromMigration(id: id, text: text, createdAt: createdAt, image: image)
            print("CoreDataMigrator: Migrated kotonoha '\(text?.prefix(20) ?? "(image)")'.")
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
