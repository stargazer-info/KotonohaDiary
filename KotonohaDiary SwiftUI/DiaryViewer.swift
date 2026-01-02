//
//  DiaryViewer.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryViewer: View {
    @EnvironmentObject var diaryController: DiaryController
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Diary.createdAt, ascending: false)])
    private var diaries: FetchedResults<Diary>
    @State var selected: String?
    @State var showAddDiary: Bool = false
    @State var showEditView: Bool = false
    @State var showDeleteView: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selected) {
                    ForEach(diaries, id: \.id) { diary in
                        DiaryView(diary: diary, showEditViewCommand: $showEditView)
                    }
                }
                .tabViewStyle(.page)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Diary")
            .background(Image("background"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditView = true
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        showDeleteView = true
                    }) {
                        Image(systemName: "trash")
                    }
                    Spacer()
                    Button(action: {
                        showAddDiary = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showAddDiary) {
                NavigationStack {
                    DiaryEditView(text: "", images: [])
                }
            }
        }
        .alert("Delete", isPresented: $showDeleteView) {
            Button(role: .destructive) {
                do {
                    if let current = diaries.first(where: { diary in
                        diary.id == self.selected
                    }) {
                        self.selected = nil
                        diaryController.delete(current)
                        try diaryController.save()
                    }
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
             } label: {
                 Text("Delete")
             }
        } message: {
            Text("Delete this diary?")
        }
        .onAppear {
            selected = diaries.first?.id
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
