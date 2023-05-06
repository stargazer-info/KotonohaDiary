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
    @State var isSelected: Bool
    @Binding var editing: Kotonoha?

    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
            } label: {
                Label("Toggle Selected", image: isSelected ? "selected" : "unselected")
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
    }
}

struct KotonohaRow_Previews: PreviewProvider {
    @State static var editing: Kotonoha?

    static var previews: some View {
        KotonohaRow(kotonoha: SampleData().kotonoha, isSelected: true, editing: $editing)
    }
}
