//
//  DiaryController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2018/11/17.
//  Copyright © 2018年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class DiaryController: NSObject {
    
    let dataContainer = AppDelegate.persistentContainer
    let dataContext = AppDelegate.viewContext

    var imageController = ImageController()
    
    func createDiary() -> Diary {
        return Diary(context: dataContext)
    }
    
    func delete(_ diary:Diary?) throws {
        if let target = diary {
            self.dataContext.delete(target)
            try self.dataContext.save()
        }
    }
    
    func removeAllImages(diary: Diary) {
        if let images = diary.images?.array as? [Image] {
            for image in images {
                dataContext.delete(image)
            }
        }
    }

    func save(editingDiary:Diary?, text:String?, images:[UIImage]) throws {
        func getDiary() -> Diary {
            if let diary = editingDiary {
                return diary
            } else {
                return createDiary()
            }
        }
        let diary = getDiary()
        diary.text = text
        removeAllImages(diary: diary)
        diary.addToImages(
            NSOrderedSet(array: images.map { (image) -> Image in
                return imageController.createImage(image)
            })
        )
        print("updated diary \(diary)")
        try dataContext.save()
    }
}
