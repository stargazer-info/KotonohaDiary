//
//  KotonohaDiaryViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/19.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class DiaryEditViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    var text = ""
    var editingDiary : Diary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let diary = editingDiary {
            textView.text = diary.text
        } else {
            textView.text = text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        close()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        saveDiary()
        close()
    }
    
    func close() {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("This ViewController is not inside a navigation controller.")
        }
    }
    
    // MARK: - CoreData
    
    let dataContainer = AppDelegate.persistentContainer
    let dataContext = AppDelegate.viewContext

    // MARK: - Private
    
    func saveDiary() {
        func getDiary() -> Diary {
            if let diary = editingDiary {
                return diary
            } else {
                return Diary(context: dataContext)
            }
        }
        if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty {
            let diary = getDiary();
            diary.text = text
            try? dataContext.save()
        }
    }
    
}
