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
                    ProgressView("データを移行中...")
                } else {
                    ContentView()
                        .environmentObject(diaryStore)
                        .environmentObject(kotonohaStore)
                }
            }
            .task {
                await runMigration()
            }
            .alert("データ移行に失敗しました", isPresented: $showMigrationError) {
                Button("再試行") {
                    Task { await runMigration() }
                }
                Button("スキップ") {
                    isMigrating = false
                }
            } message: {
                Text("過去のデータを読み込めませんでした。次回起動時に再試行します。")
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
