//
//  ContentView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/02.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            KotonohaList()
                .tabItem {
                    Label("Words", image: "kotonohaTab")
                }
            DiaryViewer()
                .tabItem {
                    Label("Diary", image: "diaryTab")
                }
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
