//
//  DiaryViewer.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryViewer: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State var selected: String?
    @State var showAddDiary: Bool = false
    @State var editingDiary: DiaryDocument? = nil
    @State var showDeleteView: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selected) {
                    ForEach(diaryStore.diaries) { diary in
                        DiaryView(diary: diary)
                            .tag(diary.id)
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
                if let current = getSelectedDiary(selected) {
                    diaryStore.delete(current)
                    selected = diaryStore.diaries.first?.id
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Delete this diary?")
        }
        .onAppear {
            selected = diaryStore.diaries.first?.id
        }
    }

    private func showEditView(_ selected: String?) {
        if let current = getSelectedDiary(selected) {
            self.editingDiary = current
        }
    }

    private func getSelectedDiary(_ selectedId: String?) -> DiaryDocument? {
        guard let selectedId = selectedId else { return nil }
        return diaryStore.diaries.first { $0.id == selectedId }
    }
}

struct DiaryViewer_Previews: PreviewProvider {
    static var previews: some View {
        DiaryViewer()
            .environmentObject(DiaryStore())
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}
