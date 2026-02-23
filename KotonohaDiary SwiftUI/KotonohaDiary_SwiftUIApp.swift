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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diaryStore)
                .environmentObject(kotonohaStore)
                .onAppear {
                    CoreDataMigrator.migrateIfNeeded(diaryStore: diaryStore, kotonohaStore: kotonohaStore)
                }
        }
    }
}
