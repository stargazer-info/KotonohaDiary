//
//  DiaryViewer.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryViewer: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Diary.createdAt, ascending: false)])
    private var diaries: FetchedResults<Diary>
    @State var showAddDiary: Bool = false
    @State var showEditView: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                TabView {
                    ForEach(diaries) { diary in
                        DiaryView(diary: diary, showEditViewCommand: $showEditView)
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Diary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditView = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        print("new diary")
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showAddDiary) {
//                NavigationStack {
//                    DiaryEditView(diary: Binding(nil))
//                }
            }
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
