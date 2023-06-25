//
//  ImageController.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/06/25.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import CoreData
import UIKit

class ImageController: ObservableObject {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create(_ image: UIImage) -> ImageData {
        let imageEntity = ImageData(context: context)
        imageEntity.image = image
        return imageEntity
    }
}
