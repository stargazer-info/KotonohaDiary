//
//  KotonohaEditView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaEditView: View {
    
    @State var text: String = ""
    @State var image: Image?
    
    var body: some View {
        HStack {
            Button {
            } label: {
                Label("Toggle Selected", image: "unselected")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            TextField("ことのは", text: $text)
                .border(.gray)
                .onSubmit {
                    
                }
            Spacer()
            Button("Save") {
                
            }
            .buttonStyle(.borderless)
        }
    }
}

struct KotonohaEditView_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaEditView()
    }
}
