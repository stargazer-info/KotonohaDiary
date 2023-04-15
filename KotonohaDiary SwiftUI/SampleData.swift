//
//  SampleData.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/09.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData
import Combine

class SampleData: ObservableObject {
    let context = PersistenceController.preview.container.viewContext
    
    var kotonoha: Kotonoha
    var kotonohaImage: Kotonoha

    init() {
        let kotonoha = Kotonoha(context: context)
        kotonoha.text = "テスト"
        self.kotonoha = kotonoha

        let imageEntity = ImageData(context: context)
        imageEntity.image = UIImage(named: "AppIconDebug")!
        let kotonohaImage = Kotonoha(context: context)
        kotonohaImage.image = imageEntity
        self.kotonohaImage = kotonohaImage
    }
}
