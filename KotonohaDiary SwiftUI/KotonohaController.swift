//
//  KotonohaHandler.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/05.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import CoreData
import UIKit

struct KotonohaController {

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create(text: String) {
        let newItem = Kotonoha(context: context)
        newItem.text = text
    }
    
    func create(image: UIImage) {
        let newItem = Kotonoha(context: context)
        let imageEntity = ImageData(context: context)
        imageEntity.image = image
        newItem.image = imageEntity
    }
    
    func delete(kotonoha: Kotonoha) {
        context.delete(kotonoha)
    }
    
    func save() throws {
        try context.save()
    }
}
