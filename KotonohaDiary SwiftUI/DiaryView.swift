//
//  DiaryView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct DiaryView: View {
    var diary: Diary
    
    var body: some View {
        VStack {
            Text(diary.createdAt!, style: .date)
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
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                .padding()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        if let diary = SampleData().diary {
            DiaryView(diary: diary)
        }
    }
}
