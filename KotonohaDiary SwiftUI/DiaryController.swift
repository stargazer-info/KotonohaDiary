//
//  diaryController.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/07.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import CoreData
import UIKit

class DiaryController: ObservableObject {
    
    let context: NSManagedObjectContext
    let imageController: ImageController
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.imageController = ImageController(context: context)
    }
    
    func create(text: String?, images: [UIImage]?) {
        let newItem = Diary(context: context)
        newItem.text = text
        newItem.addToImages(createImageData(images))
    }

    func createImageData(_ image: UIImage) -> ImageData {
        return imageController.create(image)
    }
    
    func update(_ diary: Diary, text: String?, images: [UIImage]?) {
        diary.text = text
        removeAllImages(diary: diary)
        diary.addToImages(createImageData(images))
    }
    
    func delete(_ diary: Diary?) {
        if let target = diary {
            context.delete(target)
        }
    }
    
    func save() throws {
        try context.save()
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
            return imageController.create(image)
        }) ?? [])
    }
}
