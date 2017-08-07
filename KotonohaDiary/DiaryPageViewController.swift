//
//  DiaryViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/24.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class DiaryPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, NSFetchedResultsControllerDelegate {

    var pageViewController: UIPageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeFetchedResults()
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self

        func getStartViewController() -> DiaryViewController {
            if let startingViewController: DiaryViewController = self.viewControllerAtIndex(0, storyboard: self.storyboard!) {
                return startingViewController
            } else {
                return self.storyboard!.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
            }
        }
        
        let viewControllers = [getStartViewController()]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParentViewController: self)
//        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
//
//        let pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier! {
        case "AddDiaryFromDiaryView":
            if let destVc = segue.destination as? DiaryEditViewController {
                destVc.editingDiary = nil
                destVc.text = "";
            }
        case "EditDiaryFromDiaryView":
            if let currentVc = self.pageViewController?.viewControllers?.last as? DiaryViewController, let destVc = segue.destination as? DiaryEditViewController {
                destVc.editingDiary = currentVc.diary
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    var pageData: [Diary] = []
    
    // MARK: - CoreData
    
    let dataContainer = AppDelegate.persistentContainer
    let dataContext = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
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
        updatePageData()
//        pageData = fetchedResultsController?.fetchedObjects as? [Diary] ?? []
    }
    
    func updatePageData() {
        pageData = fetchedResultsController?.fetchedObjects as? [Diary] ?? []
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
////        switch type {
////        case .insert:
////            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
////        case .delete:
////            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
////        case .move:
////            break
////        case .update:
////            break
////        }
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
////        switch type {
////        case .insert:
////            tableView.insertRows(at: [newIndexPath!], with: .fade)
////        case .delete:
////            tableView.deleteRows(at: [indexPath!], with: .fade)
////        case .update:
////            tableView.reloadRows(at: [indexPath!], with: .fade)
////        case .move:
////            tableView.moveRow(at: indexPath!, to: newIndexPath!)
////        }
//    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
        updatePageData()
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DiaryViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let diaryViewController = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
            diaryViewController.diary = self.pageData[index]
        return diaryViewController
    }
    
    func indexOfViewController(_ viewController: DiaryViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return pageData.index(of: viewController.diary!) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("viewControllerBefore")
        var index = self.indexOfViewController(viewController as! DiaryViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("viewControllerAfter")
        var index = self.indexOfViewController(viewController as! DiaryViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    // MARK: - UIPageViewController delegate methods
    
//    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
//        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
//            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
//            let currentViewController = self.pageViewController!.viewControllers![0]
//            let viewControllers = [currentViewController]
//            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
//            
//            self.pageViewController!.isDoubleSided = false
//            return .min
//        }
//        
//        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
//        let currentViewController = self.pageViewController!.viewControllers![0] as! DiaryViewController
//        var viewControllers: [UIViewController]
//        
//        let indexOfCurrentViewController = self.indexOfViewController(currentViewController)
//        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
//            let nextViewController = self.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
//            viewControllers = [currentViewController, nextViewController!]
//        } else {
//            let previousViewController = self.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
//            viewControllers = [previousViewController!, currentViewController]
//        }
//        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
//        
//        return .mid
//    }
    
}
