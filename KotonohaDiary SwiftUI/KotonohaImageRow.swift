//
//  KotonohaImageRow.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaImageRow: View {
    @EnvironmentObject var kotonohaStore: KotonohaStore
    var kotonoha: KotonohaDocument
    @Binding var selected: Set<String>
    @State var showingImage: IdentifiableImage?
    @State private var isSelected: Bool = false
    @State private var loadedImage: UIImage?

    struct IdentifiableImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }

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
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .onTapGesture {
                        showingImage = IdentifiableImage(image: image)
                    }
            }
            Spacer()
        }
        .onAppear {
            self.isSelected = selected.contains(kotonoha.id)
            self.loadedImage = kotonohaStore.loadImage(for: kotonoha)
        }
        .onChange(of: isSelected) { oldValue, newValue in
            if newValue {
                selected.insert(kotonoha.id)
            } else {
                selected.remove(kotonoha.id)
            }
        }
        .sheet(item: $showingImage) { imageData in
            ImageView(image: imageData.image, isDeleted: .constant(false))
        }
    }
}

struct KotonohaImageRow_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaImageRow(
            kotonoha: KotonohaDocument(hasImage: true),
            selected: .constant(Set<String>())
        )
        .environmentObject(KotonohaStore())
    }
}
