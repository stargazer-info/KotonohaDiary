//
//  KotonohaDataContextController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2018/11/12.
//  Copyright © 2018年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

protocol KotonohaDataContextControllerDelegate {
    func KotonohaDataContextControllerWillChangeContent()
    func KotonohaDataContextControllerInsertSection(sectionIndex:Int)
    func KotonohaDataContextControllerDeleteSection(sectionIndex:Int)
    func KotonohaDataContextControllerInsertRow(newIndexPath:IndexPath)
    func KotonohaDataContextControllerDeleteRow(indexPath:IndexPath)
    func KotonohaDataContextControllerUpdateRow(indexPath:IndexPath)
    func KotonohaDataContextControllerMoveRow(indexPath:IndexPath, newIndexPath:IndexPath)
    func KotonohaDataContextControllerDidChangeContent()
}

class KotonohaDataContextController: NSObject, NSFetchedResultsControllerDelegate
{
    var delegate:KotonohaDataContextControllerDelegate? = nil
    
    let dataContext = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override init() {
        super.init()
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Kotonoha")
        let createtimeSort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [createtimeSort]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: dataContext,
            sectionNameKeyPath: "section",
            cacheName: nil
        )
        fetchedResultsController?.delegate = (self as NSFetchedResultsControllerDelegate)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func getKotonoha(_ indexPath: IndexPath) -> Kotonoha? {
        return self.fetchedResultsController?.object(at: indexPath) as? Kotonoha
    }
    
    func deleteKotonoha(_ indexPath: IndexPath) throws {
        if let kotonoha = getKotonoha(indexPath) {
            dataContext.delete(kotonoha)
            try dataContext.save()
        }
    }
    
    func getSection(_ section: Int) -> NSFetchedResultsSectionInfo? {
        return self.fetchedResultsController?.sections?[section]
    }
    
    func numberOfSection() -> Int {
        return fetchedResultsController!.sections!.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate!.KotonohaDataContextControllerWillChangeContent()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegate?.KotonohaDataContextControllerInsertSection(sectionIndex: sectionIndex)
        case .delete:
            delegate?.KotonohaDataContextControllerDeleteSection(sectionIndex: sectionIndex)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegate?.KotonohaDataContextControllerInsertRow(newIndexPath: newIndexPath!)
        case .delete:
            delegate?.KotonohaDataContextControllerDeleteRow(indexPath: indexPath!)
        case .update:
            delegate?.KotonohaDataContextControllerUpdateRow(indexPath: indexPath!)
        case .move:
            delegate?.KotonohaDataContextControllerMoveRow(indexPath: indexPath!, newIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.KotonohaDataContextControllerDidChangeContent()
    }
    func saveKotonoha(inputText:String?, editingKotonoha:IndexPath?) {
        func getKotonoha() -> Kotonoha {
            if let indexPath = editingKotonoha {
                return self.fetchedResultsController?.object(at: indexPath) as! Kotonoha
            } else {
                return Kotonoha(context: dataContext)
            }
        }
        if let text = inputText,
            !text.isEmpty {
            let kotonoha = getKotonoha();
            kotonoha.text = text
            do {
                try dataContext.save()
            } catch {
                fatalError("Failed to save: \(error)")
            }
        }
    }
    
    func saveKotonohaImage(image: UIImage) {
        let kotonohaEntity = Kotonoha(context: dataContext)
        let imageEntity = Image(context: dataContext)
        imageEntity.image = image
        kotonohaEntity.image = imageEntity
        do {
            try dataContext.save()
        } catch {
            fatalError("Failed to save: \(error)")
        }
    }

}

