//
//  DiaryPageDataContextController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2018/11/15.
//  Copyright © 2018年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

protocol DiaryControllerDelegate {
//    func DiaryPageDataContextControllerWillChangeContent()
//    func DiaryPageDataContextControllerInsertSection(sectionIndex:Int)
//    func DiaryPageDataContextControllerDeleteSection(sectionIndex:Int)
    func diaryControllerInsertRow(newIndexPath:IndexPath)
    func diaryControllerDeleteRow(indexPath:IndexPath)
    func diaryControllerUpdateRow(indexPath:IndexPath)
    func diaryControllerMoveRow(indexPath:IndexPath, newIndexPath:IndexPath)
    func diaryControllerDidChangeContent()
}

extension DiaryControllerDelegate {
    func diaryControllerInsertRow(newIndexPath:IndexPath) {}
    func diaryControllerDeleteRow(indexPath:IndexPath) {}
    func diaryControllerUpdateRow(indexPath:IndexPath) {}
    func diaryControllerMoveRow(indexPath:IndexPath, newIndexPath:IndexPath) {}
    func diaryControllerDidChangeContent() {}
}

class DiaryController: NSObject, NSFetchedResultsControllerDelegate {
    
    var delegate:DiaryControllerDelegate? = nil

    let dataContainer = CoreDataManager.shared.persistentContainer
    let dataContext = CoreDataManager.shared.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
//    var diaryController = DiaryController()
    var imageController = ImageController()
    
    override init() {
        super.init()
        initializeFetchedResults()
    }
    
    func initializeFetchedResults() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
        let createtimeSort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [createtimeSort]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: dataContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = (self as NSFetchedResultsControllerDelegate)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func getDiaries() -> [Diary] {
        return fetchedResultsController?.fetchedObjects as? [Diary] ?? []
    }

    func create() -> Diary {
        return Diary(context: dataContext)
    }
    
    func delete(_ diary:Diary?) throws {
        if let target = diary {
            self.dataContext.delete(target)
            try self.dataContext.save()
        }
    }
    
//    func deleteDiary(_ diary:Diary?) throws {
//        try diaryController.delete(diary)
//    }
    
    func removeAllImages(diary: Diary) {
        if let images = diary.images?.array as? [ImageData] {
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
                return create()
            }
        }
        let diary = getDiary()
        diary.text = text
        removeAllImages(diary: diary)
        diary.addToImages(
            NSOrderedSet(array: images.map { (image) -> ImageData in
                return imageController.createImage(image)
            })
        )
        print("updated diary \(diary)")
        try dataContext.save()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegate?.diaryControllerInsertRow(newIndexPath: newIndexPath!)
        case .delete:
            delegate?.diaryControllerDeleteRow(indexPath: indexPath!)
        case .update:
            delegate?.diaryControllerUpdateRow(indexPath: indexPath!)
        case .move:
            delegate?.diaryControllerMoveRow(indexPath: indexPath!, newIndexPath: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.diaryControllerDidChangeContent()
    }
}
