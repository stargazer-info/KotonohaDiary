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
    @Binding var selected: Set<Kotonoha>
    @State var showingImage: ImageData?
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
        .sheet(item: $showingImage, onDismiss: {
            showingImage = nil
        }) { imageData in
            ImageView(image: imageData.image, isDeleted: .constant(false))
        }
    }
}

struct KotonohaImageRow_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaImageRow(
            kotonoha: SampleData().kotonohaImage,
            selected: .constant(Set<Kotonoha>())
        )
    }
}
