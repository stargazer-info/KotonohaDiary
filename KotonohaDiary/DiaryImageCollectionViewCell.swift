//
//  DiaryImageCollectionViewCell.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/10/08.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class DiaryImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(image: UIImage) {
        print("image size \(image.size)")
        imageView.image = image
    }
}
