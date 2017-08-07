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
        print("awakeFromInsert");
        super.awakeFromInsert()
        id = NSUUID().uuidString
        createdAt = Date() as NSDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        section = formatter.string(from: createdAt! as Date)
    }
    
    override func awakeFromFetch() {
        print("awakeFromInsert");
        super.awakeFromFetch()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        section = formatter.string(from: createdAt! as Date)
    }
}
