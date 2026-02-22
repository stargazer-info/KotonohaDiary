//
//  KotonohaRow.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/08.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaRow: View {
    @ObservedObject var kotonoha: Kotonoha
    @Binding var selected: Set<Kotonoha>
    @Binding var editing: Kotonoha?
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
            self.isSelected = selected.contains(where: { $0.id == kotonoha.id })
        }
        .onChange(of: isSelected) { oldValue, newValue in
            if newValue {
                if !selected.contains(kotonoha) {
                    selected.insert(kotonoha)
                }
            } else {
                if selected.contains(kotonoha) {
                    selected.remove(kotonoha)
                }
            }
        }
    }
}

struct KotonohaRow_Previews: PreviewProvider {
    @State static var editing: Kotonoha?

    static var previews: some View {
        KotonohaRow(
            kotonoha: SampleData().kotonoha,
            selected: .constant(Set<Kotonoha>()),
            editing: $editing
        )
    }
}
