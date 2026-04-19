//
//  SampleData.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/09.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import UIKit
import SwiftUI

class SampleData: ObservableObject {
    var kotonoha: KotonohaDocument
    var kotonohaImage: KotonohaDocument
    var diary: DiaryDocument

    init() {
        self.kotonoha = KotonohaDocument(text: "テスト", createdAt: Date())
        self.kotonohaImage = KotonohaDocument(text: nil, createdAt: Date(), hasImage: true)
        self.diary = DiaryDocument(
            text: "日記テスト\n複数行",
            createdAt: Date(),
            imageFilenames: ["0.jpg", "1.jpg"]
        )
    }
}
