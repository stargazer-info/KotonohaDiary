//
//  DiaryPageDataContextController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2018/11/15.
//  Copyright © 2018年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

protocol DiaryPageDataContextControllerDelegate {
//    func DiaryPageDataContextControllerWillChangeContent()
//    func DiaryPageDataContextControllerInsertSection(sectionIndex:Int)
//    func DiaryPageDataContextControllerDeleteSection(sectionIndex:Int)
    func DiaryPageDataContextControllerInsertRow(newIndexPath:IndexPath)
    func DiaryPageDataContextControllerDeleteRow(indexPath:IndexPath)
    func DiaryPageDataContextControllerUpdateRow(indexPath:IndexPath)
    func DiaryPageDataContextControllerMoveRow(indexPath:IndexPath, newIndexPath:IndexPath)
    func DiaryPageDataContextControllerDidChangeContent()
}

class DiaryPageDataContextController: NSObject, NSFetchedResultsControllerDelegate {
    
    var delegate:DiaryPageDataContextControllerDelegate? = nil

    let dataContainer = AppDelegate.persistentContainer
    let dataContext = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var diaryController = DiaryController()

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

    func deleteDiary(_ diary:Diary?) throws {
        try diaryController.delete(diary)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegate?.DiaryPageDataContextControllerInsertRow(newIndexPath: newIndexPath!)
        case .delete:
            delegate?.DiaryPageDataContextControllerDeleteRow(indexPath: indexPath!)
        case .update:
            delegate?.DiaryPageDataContextControllerUpdateRow(indexPath: indexPath!)
        case .move:
            delegate?.DiaryPageDataContextControllerMoveRow(indexPath: indexPath!, newIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.DiaryPageDataContextControllerDidChangeContent()
    }
}
