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
    @State private var isMigrating = CoreDataMigrator.isMigrationNeeded
    @State private var showMigrationError = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isMigrating {
                    ProgressView("Migrating data...")
                } else {
                    ContentView()
                        .environmentObject(diaryStore)
                        .environmentObject(kotonohaStore)
                }
            }
            .task {
                await runMigration()
            }
            .alert("Data migration failed", isPresented: $showMigrationError) {
                Button("Retry") {
                    Task { await runMigration() }
                }
                Button("Skip") {
                    isMigrating = false
                }
            } message: {
                Text("Failed to load previous data. Will retry on next launch.")
            }
        }
    }

    private func runMigration() async {
        let succeeded = await CoreDataMigrator.migrateIfNeeded(diaryStore: diaryStore, kotonohaStore: kotonohaStore)
        if succeeded {
            isMigrating = false
        } else {
            showMigrationError = true
        }
    }
}
