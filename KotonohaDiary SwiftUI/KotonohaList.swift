//
//  KotonohaList.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaList: View {
    @EnvironmentObject var kotonohaController: KotonohaController
    @EnvironmentObject var diaryController: DiaryController

    @SectionedFetchRequest<String?,Kotonoha>(sectionIdentifier: \Kotonoha.section, sortDescriptors: [NSSortDescriptor(keyPath: \Kotonoha.createdAt, ascending: false)])
    private var kotonohaSections: SectionedFetchResults<String?,Kotonoha>
    @State var selected: Set<Kotonoha> = []
    @State var newDiaryData: DiaryData?
    struct DiaryData: Identifiable {
        let id: UUID = UUID()
        var text: String
        var images: [UIImage]
    }
    @State private var editing: Kotonoha?
    
    var body: some View {
        NavigationStack {
            VStack {
                KotonohaEditView(kotonoha: $editing)
                    .padding(.horizontal)
                List() {
                    ForEach(kotonohaSections) { section in
                        Section(header: Text(section.id ?? "")) {
                            ForEach(section, id: \.self) { kotonoha in
                                if let _ = kotonoha.image {
                                    KotonohaImageRow(
                                        kotonoha: kotonoha,
                                        selected: $selected
                                    )
                                } else {
                                    KotonohaRow(
                                        kotonoha: kotonoha,
                                        selected: $selected,
                                        editing: $editing)
                                }
                            }
                            .onDelete(perform: { indexSet in
                                indexSet
                                    .map({ section[$0] })
                                    .forEach({ delete(kotonoha: $0) })
                            })
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
                        print("selected: \(selected)")
                        self.newDiaryData = makeDiaryData(kotonohaList: selected)
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
    
    private func makeDiaryData(kotonohaList: Set<Kotonoha>) -> DiaryData {
        var texts: [String] = []
        var images: [UIImage] = []
        for kotonoha in kotonohaList {
            if let image = kotonoha.image {
                images.append(image.image)
            } else {
                if let text = kotonoha.text, !text.isEmpty {
                    texts.append(text)
                }
            }
        }
        return DiaryData(text: texts.joined(separator: "\n"), images: images)
    }

    private func delete(kotonoha: Kotonoha) {
        do {
            kotonohaController.delete(kotonoha: kotonoha)
            try kotonohaController.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct KotonohaList_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}
