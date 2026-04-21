//
//  KotonohaList.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaList: View {
    @EnvironmentObject var kotonohaStore: KotonohaStore
    @EnvironmentObject var diaryStore: DiaryStore

    @State var selected: Set<String> = []
    @State var newDiaryData: DiaryData?
    struct DiaryData: Identifiable {
        let id: UUID = UUID()
        var text: String
        var images: [UIImage]
    }
    @State private var editingKotonoha: KotonohaDocument?

    var body: some View {
        NavigationStack {
            VStack {
                KotonohaEditView(kotonoha: $editingKotonoha)
                    .padding(.horizontal)
                List {
                    ForEach(kotonohaStore.sections) { section in
                        Section(header: Text(section.section)) {
                            ForEach(section.kotonohas) { kotonoha in
                                if kotonoha.hasImage {
                                    KotonohaImageRow(
                                        kotonoha: kotonoha,
                                        selected: $selected
                                    )
                                } else {
                                    KotonohaRow(
                                        kotonoha: kotonoha,
                                        selected: $selected,
                                        editing: $editingKotonoha
                                    )
                                }
                            }
                            .onDelete { indexSet in
                                indexSet
                                    .map { section.kotonohas[$0] }
                                    .forEach { kotonohaStore.delete(kotonoha: $0) }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Words")
            .background(Image("background"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.newDiaryData = makeDiaryData(selectedIds: selected)
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .fullScreenCover(item: $newDiaryData) { data in
                NavigationStack {
                    DiaryEditView(text: data.text, images: data.images)
                }
            }
        }
    }

    private func makeDiaryData(selectedIds: Set<String>) -> DiaryData {
        var texts: [String] = []
        var images: [UIImage] = []
        for kotonoha in kotonohaStore.kotonohas where selectedIds.contains(kotonoha.id) {
            if kotonoha.hasImage {
                if let image = kotonohaStore.loadImage(for: kotonoha) {
                    images.append(image)
                }
            } else {
                if let text = kotonoha.text, !text.isEmpty {
                    texts.append(text)
                }
            }
        }
        return DiaryData(text: texts.joined(separator: "\n"), images: images)
    }
}

struct KotonohaList_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaList()
            .environmentObject(KotonohaStore())
            .environmentObject(DiaryStore())
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}
