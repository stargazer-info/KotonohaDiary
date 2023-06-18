//
//  DiaryViewer.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryViewer: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Diary.createdAt, ascending: false)])
    private var diaries: FetchedResults<Diary>
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView {
                    ForEach(diaries) { diary in
                        DiaryView(diary: diary)
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Diary")
        }
    }
    
}

struct DiaryViewer_Previews: PreviewProvider {
    static var previews: some View {
        DiaryViewer()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}
