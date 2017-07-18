//
//  KotonohaTableViewCell.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/16.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

protocol KotonohaTableViewCellDelegate: class {
    func kotonohaTableViewCellEdit(cell: KotonohaTableViewCell) -> ()
//    func kotonohaTableViewCellEdit(indexPath: IndexPath?) -> ()
}

class KotonohaTableViewCellButton : UIButton {
    var indexPath : IndexPath?
}

class KotonohaTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var kotonohaLabel: UILabel!
    @IBOutlet weak var editButton: KotonohaTableViewCellButton!
    
    weak var delegate: KotonohaTableViewCellDelegate! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func edit(_ sender: KotonohaTableViewCellButton) {
        self.delegate.kotonohaTableViewCellEdit(cell: self)
//        self.delegate.kotonohaTableViewCellEdit(indexPath: sender.indexPath)
    }
}
