//
//  diaryController.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import CoreData
import UIKit

struct DiaryController {
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create(text: String?, images: [UIImage]?) {
        let newItem = Diary(context: context)
        newItem.text = text
        newItem.addToImages(createImageData(images))
    }

    func update(_ diary: Diary, text: String?, images: [UIImage]?) {
        diary.text = text
        removeAllImages(diary: diary)
        diary.addToImages(createImageData(images))
    }
    
    func delete(_ diary:Diary?) throws {
        if let target = diary {
            context.delete(target)
        }
    }
    
    private func removeAllImages(diary: Diary) {
        if let images = diary.images?.array as? [ImageData] {
            for image in images {
                context.delete(image)
            }
        }
    }
    
    private func createImageData(_ images: [UIImage]?) -> NSOrderedSet {
        return NSOrderedSet(array: images?.map({ image in
            let imageData = ImageData(context: context)
            imageData.image = image
            return imageData
        }) ?? [])
    }
}
