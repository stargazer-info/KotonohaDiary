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
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.xibViewSet()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//        self.xibViewSet()
//    }
//    
//    internal func xibViewSet() {
//        if let view = Bundle.main.loadNibNamed("DiaryImageCollectionViewCell", owner: self, options: nil)?.first as? UIView {
//            view.frame = self.bounds
//            self.addSubview(view)
//        }
//    }
    
    func setImage(image: UIImage) {
        print("imageView \(imageView)")
        print("image size \(image.size)")
        imageView.image = image
    }
}
