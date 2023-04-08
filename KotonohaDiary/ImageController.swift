//
//  ImageController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2018/11/17.
//  Copyright © 2018年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class ImageController: NSObject {
    
    let dataContainer = CoreDataManager.shared.persistentContainer
    let dataContext = CoreDataManager.shared.viewContext
    
    func createImage(_ image:UIImage) -> Image {
        let imageEntity = Image(context: dataContext)
        imageEntity.image = image
        return imageEntity
    }
}
