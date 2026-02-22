//
//  DiaryView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryView: View {
    @ObservedObject var diary: Diary
    @State var showingImage: ImageData?
    
    var body: some View {
        VStack {
            Text(diary.createdAt ?? Date(), style: .date)
                .font(.headline)
                .padding()
            ScrollView {
                Text(diary.text ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            Spacer()
            if let images = diary.images {
                ScrollView([.horizontal]) {
                    HStack {
                        ForEach(images.array as! [ImageData]) { imageData in
                            Image(uiImage: imageData.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .onTapGesture {
                                    showingImage = imageData
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
        .sheet(item: $showingImage, onDismiss: {
            showingImage = nil
        }) { imageData in
            ImageView(image: imageData.image, isDeleted: .constant(false))
        }
    }
}

struct DiaryView_Previews: PreviewProvider {
    @State static var showEditView = false
    
    static var previews: some View {
        if let diary = SampleData().diary {
            DiaryView(
                diary: diary
            )
        }
    }
}
