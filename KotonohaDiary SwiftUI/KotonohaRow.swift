//
//  KotonohaRow.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/08.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaRow: View {
    var text: String
    @State var isSelected: Bool
    
    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
            } label: {
                Label("Toggle Selected", image: isSelected ? "selected" : "unselected")
                    .labelStyle(.iconOnly)
            }
            Text(text)
            Spacer()
            EditButton()
        }
        .padding()
    }
}

struct KotonohaRow_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaRow(text: "テキスト", isSelected: true)
    }
}
