//
//  KotonohaImageRow.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaImageRow: View {
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
            Spacer()
            if let image = kotonoha.image?.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
            }
            Spacer()
            EditButton()
        }
        .padding()
    }
}

struct KotonohaImageRow_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaImageRow(kotonoha: SampleData().kotonohaImage, isSelected: true)
    }
}
