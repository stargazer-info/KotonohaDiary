//
//  DateFormatUtil.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/09/05.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import Foundation

class DateFormatUtil {
    static var formatter = DateFormatter()
    
    class func format(date:Date) -> String {
        DateFormatUtil.formatter.dateStyle = .long
        DateFormatUtil.formatter.timeStyle = .none
        return DateFormatUtil.formatter.string(from: date)
    }
}
