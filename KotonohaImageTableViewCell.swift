//
//  KotonohaImageTableViewCell.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/09/17.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

protocol KotonohaImageTableViewCellDelegate: class {
    func kotonohaImageTableViewCellShowImage(cell: KotonohaImageTableViewCell) -> ()
}

class KotonohaImageTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    
    weak var delegate: KotonohaImageTableViewCellDelegate! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        photo.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(KotonohaImageTableViewCell.imageTapped(_:)))
        photo.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            checkMark.image = #imageLiteral(resourceName: "selected")
        } else {
            checkMark.image = #imageLiteral(resourceName: "unselected")
        }
    }

    public func setImage(image: UIImage) {
        photo.image = image
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.kotonohaImageTableViewCellShowImage(cell: self)
    }
}
