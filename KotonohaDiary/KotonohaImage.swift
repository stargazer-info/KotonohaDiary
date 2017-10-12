//
//  KotonohaImage.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/10/08.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class KotonohaImage: UIImage {

    let SHORT_SIDE_SIZE = CGFloat(640)
    //        let SHORT_SIDE_SIZE = 1242
    let JPEG_QUALITY = CGFloat(0.5)
    
    func resize() -> UIImage? {
        let size = self.size
        let shortSide = size.width > size.height ? size.height : size.width
        let scale = SHORT_SIDE_SIZE / shortSide
        if scale == 1 {
            return self
        } else {
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            self.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage
        }
    }
    
    public func getSaveData() -> Data? {
        let resizedImage = resize()
        print("resizedImage: \(String(describing: resizedImage))")
        if let imageData = UIImageJPEGRepresentation(resizedImage!, JPEG_QUALITY) {
            print("imageData: \(imageData)")
            //        saveKotonohaImage(data: imageData)
            return imageData
        } else {
            print("jpg error")
            return nil
        }
    }
}
