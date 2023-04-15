//
//  KotonohaRow.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/08.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaRow: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Kotonoha.createdAt, ascending: true)],
//        animation: .default)
//    private var kotonohaList: FetchedResults<Kotonoha>
    
//    var text: String
    var kotonoha: Kotonoha
    @State var isSelected: Bool
    
    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
            } label: {
                Label("Toggle Selected", image: isSelected ? "selected" : "unselected")
                    .labelStyle(.iconOnly)
            }
            Text(kotonoha.text ?? "")
            Spacer()
            EditButton()
        }
        .padding()
    }
}

struct KotonohaRow_Previews: PreviewProvider {
//    static let context = PersistenceController.preview.container.viewContext
////    @FetchRequest(
////        sortDescriptors: [NSSortDescriptor(keyPath: \Kotonoha.createdAt, ascending: true)],
////        animation: .default)
//    private var kotonohaList: FetchedResults<Kotonoha>

    static var previews: some View {
        KotonohaRow(kotonoha: SampleData().kotonoha, isSelected: true)
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
