//
//  Kotonoha.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/17.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class Kotonoha: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        id = NSUUID().uuidString
        createdAt = Date() as NSDate
        setSection()
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        setSection()
    }
    
    private func setSection() {
        section = DateFormatUtil.format(date: createdAt! as Date)
    }
}
