//
//  ContentView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/02.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    enum Tab {
        case words
        case diary
    }

    @State private var selectedTab: Tab = .words
    @State private var selectedDiaryID: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            KotonohaList(onDiaryCreated: { created in
                selectedDiaryID = created.id
                selectedTab = .diary
            })
                .tabItem {
                    Label("Words", image: "kotonohaTab")
                }
                .tag(Tab.words)
            DiaryViewer(selected: $selectedDiaryID)
                .tabItem {
                    Label("Diary", image: "diaryTab")
                }
                .tag(Tab.diary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DiaryStore())
            .environmentObject(KotonohaStore())
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}
