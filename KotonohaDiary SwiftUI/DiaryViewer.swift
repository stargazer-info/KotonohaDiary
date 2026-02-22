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
    @State var editingDiary: Diary? = nil
    @State var showDeleteView: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selected) {
                    ForEach(diaries, id: \.id) { diary in
                        DiaryView(diary: diary)
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
                        showEditView(self.selected)
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
        .fullScreenCover(item: $editingDiary) { diary in
            NavigationStack {
                DiaryEditView(diary: diary)
            }
        }
        .alert("Delete", isPresented: $showDeleteView) {
            Button(role: .destructive) {
                do {
                    if let current = getSelectedDiary(selected) {
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
    
    private func showEditView(_ selected: String?) {
        if let current = getSelectedDiary(selected) {
            self.editingDiary = current
        }
    }
    
    private func getSelectedDiary(_ selectedId: String?) -> Diary? {
        if let selected = selectedId,
            let current = diaries.first(where: { diary in
            diary.id == selected
        }) {
            return current
        } else {
            return nil
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
