//
//  KotonohaInputToolbar.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/18.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class KotonohaInputToolbar: UIToolbar {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: Selector(("onCancelButtonClick:")))
        setItems([spacer, cancelButton], animated: true)
    }

    func onCancelButtonClick(sender: UIBarButtonItem) {
        print("Cancel")
    }
}
