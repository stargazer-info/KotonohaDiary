//
//  Diary.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/23.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

public class Diary: NSManagedObject {

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = NSUUID().uuidString
        createdAt = Date() as NSDate
    }
    
}
