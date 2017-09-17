//
//  KotonohaImageTableViewCell.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/09/17.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class KotonohaImageTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var imageV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            checkMark.image = #imageLiteral(resourceName: "selected")
        } else {
            checkMark.image = #imageLiteral(resourceName: "unselected")
        }
    }

}
