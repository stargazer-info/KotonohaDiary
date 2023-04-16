//
//  KotonohaList.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String?,Kotonoha>(sectionIdentifier: \Kotonoha.section, sortDescriptors: [NSSortDescriptor(keyPath: \Kotonoha.createdAt, ascending: false)])
    private var kotonohaSections: SectionedFetchResults<String?,Kotonoha>

    var body: some View {
        NavigationStack {
            VStack {
                KotonohaEditView()
                    .padding(.horizontal)
                List {
                    ForEach(kotonohaSections) { section in
                        Section(header: Text(section.id ?? "")) {
                            ForEach(section) { kotonoha in
                                if let _ = kotonoha.image {
                                    KotonohaImageRow(kotonoha: kotonoha, isSelected: false)
                                } else {
                                    KotonohaRow(kotonoha: kotonoha, isSelected: false)
                                }
                            }
                        }
                    }
                }.listStyle(.plain)
            }
            .navigationTitle("ことのは")
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
