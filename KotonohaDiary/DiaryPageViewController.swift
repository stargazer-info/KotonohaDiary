//
//  DiaryViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/24.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class DiaryPageViewController: UIPageViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var curIndex = 0
    var pageData: [Diary] = []
    
    var dataController = DiaryPageDataContextController()
    
    override func viewDidLoad() {
        print("DiaryPageViewController viewDidLoad")
        super.viewDidLoad()
        
        func initBackground() {
            self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
            self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
            self.navigationController?.toolbar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
            self.tabBarController?.tabBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        }
        
        func initPageView() {
            self.dataSource = self
            self.delegate = self
            let pageControl = UIPageControl.appearance()
            pageControl.currentPageIndicatorTintColor = UIColor.darkGray
            pageControl.pageIndicatorTintColor = UIColor.lightGray
        }

        initBackground()
        initPageView()
        dataController.delegate = self
        updatePageData()
        initActionButtons()
        updateViewControllers()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier! {
        case "AddDiaryFromDiaryView":
            if let destVc = segue.destination as? DiaryEditViewController {
                destVc.editingDiary = nil
                destVc.text = "";
            }
        case "EditDiaryFromDiaryView":
            if let currentVc = self.viewControllers?.last as? DiaryViewController, let destVc = segue.destination as? DiaryEditViewController {
                print("EditDiaryFromDiaryView \(String(describing: currentVc.diary))")
                print("EditDiaryFromDiaryView.images \(String(describing: currentVc.diary?.images))")
                destVc.editingDiary = currentVc.diary
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func updatePageData() {
        pageData = dataController.getDiaries()
        print("updatePageData \(pageData)")
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DiaryViewController? {
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        
        let diaryViewController = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
            diaryViewController.diary = self.pageData[index]
        return diaryViewController
    }
    
    func indexOfViewController(_ viewController: DiaryViewController) -> Int {
        return pageData.index(of: viewController.diary!) ?? NSNotFound
    }

    @IBAction func onClickDeleteBtn(_ sender: UIBarButtonItem) {
        if let currentVc = self.viewControllers?.last as? DiaryViewController {
            print("delete: \(String(describing: currentVc.diary))")
            
            showAlert(okHandler: { [unowned self]
                (action: UIAlertAction!) -> Void in
                try? self.dataController.deleteDiary(currentVc.diary)
                },
                      cancelHandler: nil
            )
        }
    }
    
    @IBAction func onClickShareBtn(_ sender: UIBarButtonItem) {
        if let currentVc = self.viewControllers?.last as? DiaryViewController,
            let currDiary = currentVc.diary
        {
            print("current diary \(String(describing: currDiary.text))")
            var items : [Any] = []
            if let text = currDiary.text {
                items.append(text)
            }
            let images = currDiary.images?.array.flatMap { ($0 as? Image)?.image }
            if let images = images {
                items.append(contentsOf: images as [Any])
            }
            print("items: \(items)")
            let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(activityVc, animated: true, completion: nil)
        }
    }
    
    // MARK: - private
    
    func initActionButtons() {
        if pageData.isEmpty {
            editButton.isEnabled = false;
            deleteButton.isEnabled = false;
            shareButton.isEnabled = false;
        } else {
            editButton.isEnabled = true;
            deleteButton.isEnabled = true;
            shareButton.isEnabled = true;
        }
    }
    
    func updateViewControllers() {
        let viewControllers = [getCurrViewController()]
        self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
    }
    
    private func getCurrViewController() -> DiaryViewController {
        if let currViewController: DiaryViewController = self.viewControllerAtIndex(curIndex, storyboard: self.storyboard!) {
            return currViewController
        } else {
            return getEmptyViewController()
        }
    }
    
    private func getEmptyViewController() -> DiaryViewController {
        return self.storyboard!.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
    }

    private func showAlert(okHandler: ((_ action: UIAlertAction?) -> Void)?, cancelHandler: ((_ action: UIAlertAction?) -> Void)? ) {
        let alert: UIAlertController = UIAlertController(
            title: NSLocalizedString("Delete", comment: "delete"),
            message: NSLocalizedString("Delete this diary?", comment: "a message of the delete diary dialog"),
            preferredStyle:  .alert)
        let defaultAction: UIAlertAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK button"),
            style: .default,
            handler: okHandler
        )
        let cancelAction: UIAlertAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel button"),
            style: .cancel,
            handler:cancelHandler
        )
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension DiaryPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("viewControllerBefore")
        if pageData.isEmpty {
            return nil
        }
        var index = self.indexOfViewController(viewController as! DiaryViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("viewControllerAfter")
        if pageData.isEmpty {
            return nil
        }
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
    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return self.pageData.count
//    }
//    
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
    
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

// MARK: - DiaryPageDataContextControllerDelegate

extension DiaryPageViewController: DiaryPageDataContextControllerDelegate {
    func DiaryPageDataContextControllerInsertRow(newIndexPath: IndexPath) {
        curIndex = newIndexPath.row
    }
    
    func DiaryPageDataContextControllerDeleteRow(indexPath: IndexPath) {
        let prevIndex = indexPath.row - 1
        curIndex = prevIndex < 0 ? 0 : prevIndex
    }
    
    func DiaryPageDataContextControllerUpdateRow(indexPath: IndexPath) {
        curIndex = indexPath.row
    }
    
    func DiaryPageDataContextControllerMoveRow(indexPath: IndexPath, newIndexPath: IndexPath) {
        curIndex = newIndexPath.row
    }
    
    func DiaryPageDataContextControllerDidChangeContent() {
        updatePageData()
        initActionButtons()
        updateViewControllers()
    }
    
}
