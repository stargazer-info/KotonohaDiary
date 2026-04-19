//
//  ImageView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/06/18.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    @Environment(\.dismiss) var dismiss
    var image: UIImage
    var showDeleteButton: Bool = false
    @Binding var isDeleted: Bool
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            Spacer()
            if showDeleteButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Delete:")
                            isDeleted = true
                        }, label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        })
                    }
                }
                .padding()
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    @State static var deletedImage: ImageData? = nil
    static var previews: some View {
        if let image = UIImage(systemName: "photo") {
            ImageView(image: image, isDeleted: .constant(false))
        }
    }
}
