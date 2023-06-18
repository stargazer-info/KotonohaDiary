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
    @State var showingImage: ImageData?
    
    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
            } label: {
                Label("Toggle Selected", image: isSelected ? "selected" : "unselected")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            Spacer()
            if let imageData = kotonoha.image {
                let image = imageData.image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .onTapGesture {
                        showingImage = imageData
                    }
            }
            Spacer()
        }
        .sheet(item: $showingImage, onDismiss: {
            showingImage = nil
        }) {imageData in
            ImageView(imageData: imageData)
        }
    }
}

struct KotonohaImageRow_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaImageRow(kotonoha: SampleData().kotonohaImage, isSelected: true)
    }
}
