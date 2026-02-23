//
//  DiaryView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    var diary: DiaryDocument
    @State var showingImage: IdentifiableImage?
    @State private var loadedImages: [UIImage] = []

    struct IdentifiableImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    var body: some View {
        VStack {
            Text(diary.createdAt, style: .date)
                .font(.headline)
                .padding()
            ScrollView {
                Text(diary.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            Spacer()
            if !loadedImages.isEmpty {
                ScrollView([.horizontal]) {
                    HStack {
                        ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .onTapGesture {
                                    showingImage = IdentifiableImage(image: image)
                                }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            loadedImages = diaryStore.loadImages(for: diary)
        }
        .sheet(item: $showingImage) { imageData in
            ImageView(image: imageData.image, isDeleted: .constant(false))
        }
    }
}

struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView(diary: DiaryDocument(text: "テスト日記", createdAt: Date()))
            .environmentObject(DiaryStore())
    }
}
