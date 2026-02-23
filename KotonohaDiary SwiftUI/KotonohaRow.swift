//
//  KotonohaRow.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/08.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaRow: View {
    var kotonoha: KotonohaDocument
    @Binding var selected: Set<String>
    @Binding var editing: KotonohaDocument?
    @State private var isSelected: Bool = false

    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
            } label: {
                Label(String(""), image: isSelected ? "selected" : "unselected")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            Text(kotonoha.text ?? "")
            Spacer()
            Button {
                editing = kotonoha
            } label: {
                Text("Edit")
            }
            .buttonStyle(.borderless)
        }
        .onAppear {
            self.isSelected = selected.contains(kotonoha.id)
        }
        .onChange(of: isSelected) { oldValue, newValue in
            if newValue {
                selected.insert(kotonoha.id)
            } else {
                selected.remove(kotonoha.id)
            }
        }
    }
}

struct KotonohaRow_Previews: PreviewProvider {
    @State static var editing: KotonohaDocument?

    static var previews: some View {
        KotonohaRow(
            kotonoha: KotonohaDocument(text: "テスト", createdAt: Date()),
            selected: .constant(Set<String>()),
            editing: $editing
        )
    }
}
