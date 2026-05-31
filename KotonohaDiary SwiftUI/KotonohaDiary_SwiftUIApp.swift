//
//  KotonohaDiary_SwiftUIApp.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/02.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

@main
struct KotonohaDiary_SwiftUIApp: App {
    @StateObject private var diaryStore = DiaryStore()
    @StateObject private var kotonohaStore = KotonohaStore()
    @State private var isPreparing = true
    @State private var showMigrationError = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isPreparing {
                    ProgressView("Loading...")
                } else {
                    ContentView()
                        .environmentObject(diaryStore)
                        .environmentObject(kotonohaStore)
                }
            }
            .task {
                await prepareApp()
            }
            .alert("Data migration failed", isPresented: $showMigrationError) {
                Button("Retry") {
                    Task { await runMigration() }
                }
                Button("Skip") {
                    isPreparing = false
                }
            } message: {
                Text("Failed to load previous data. Will retry on next launch.")
            }
        }
    }

    private func prepareApp() async {
        // iCloud URL 解決はメインスレッドをブロックするためバックグラウンドで行う。
        await DocumentStoreBase.prepare()
        await diaryStore.loadAll()
        await kotonohaStore.loadAll()
        await runMigration()
    }

    private func runMigration() async {
        guard CoreDataMigrator.isMigrationNeeded else {
            isPreparing = false
            return
        }
        let succeeded = await CoreDataMigrator.migrateIfNeeded(diaryStore: diaryStore, kotonohaStore: kotonohaStore)
        if succeeded {
            isPreparing = false
        } else {
            showMigrationError = true
        }
    }
}
