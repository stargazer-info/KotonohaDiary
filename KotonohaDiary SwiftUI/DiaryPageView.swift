//
//  DiaryPageView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Diary.createdAt, ascending: false)])
    private var diaries: FetchedResults<Diary>
    
    private let testTexts = ["Hello, World!1", "Hello, World!2"]
    
    var body: some View {
        NavigationStack {
            TabView {
                ForEach(diaries) { diary in
                    DiaryView(diary: diary)
                }
            }
            .tabViewStyle(.page)
            .navigationTitle("Diary")
        }
    }
}

struct DiaryPageView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryPageView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}
