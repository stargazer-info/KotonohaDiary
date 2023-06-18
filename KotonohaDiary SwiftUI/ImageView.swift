//
//  ImageView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/06/18.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    var imageData: ImageData?
    
    var body: some View {
        if let image = imageData?.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(imageData: SampleData().kotonohaImage.image)
    }
}
