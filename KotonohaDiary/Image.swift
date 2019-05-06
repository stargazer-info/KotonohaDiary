//
//  Image.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/10/13.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

public class Image: NSManagedObject {

    var image : UIImage {
        get {
            return UIImage(data: data! as Data)!
        }
        set {
            data = getSaveData(image: newValue)!
        }
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = NSUUID().uuidString
        createdAt = Date()
    }
    
    let SHORT_SIDE_SIZE = CGFloat(640)
    //        let SHORT_SIDE_SIZE = 1242
    let JPEG_QUALITY = CGFloat(0.5)
    
    private func resize(image: UIImage) -> UIImage? {
        let size = image.size
        let shortSide = size.width > size.height ? size.height : size.width
        let scale = SHORT_SIDE_SIZE / shortSide
        if scale == 1 {
            return image
        } else {
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage
        }
    }
    
    private func getSaveData(image: UIImage) -> Data? {
        let resizedImage = resize(image: image)
        print("resizedImage: \(String(describing: resizedImage))")
        if let imageData = resizedImage!.jpegData(compressionQuality: JPEG_QUALITY) {
            print("imageData: \(imageData)")
            return imageData
        } else {
            print("jpg error")
            return nil
        }
    }

}
