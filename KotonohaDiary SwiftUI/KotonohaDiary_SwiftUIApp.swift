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
                if isMigrating {
                    await CoreDataMigrator.migrateIfNeeded(diaryStore: diaryStore, kotonohaStore: kotonohaStore)
                    isMigrating = false
                }
            }
        }
    }
}
