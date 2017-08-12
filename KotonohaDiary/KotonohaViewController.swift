//
//  KotonohaViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/16.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class KotonohaViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, KotonohaTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var kotonohaInputText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        kotonohaInputText.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        kotonohaInputText.inputAccessoryView = getInputAccessoryView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "AddDiary":
            if let destinationNavigationController = segue.destination as? UINavigationController,
                let dest = destinationNavigationController.topViewController as? DiaryEditViewController,
                let rows = self.tableView.indexPathsForSelectedRows {
                print("dest: \(dest)");
                print("indexPathsForSelectedRows: \(rows)");
                dest.text = rows.map {
                        indexPath -> String in
                        let kotonoha = self.fetchedResultsController?.object(at: indexPath) as? Kotonoha
                        return kotonoha?.text ?? ""
                    }.joined(separator: "\n")
            }
        default:
            fatalError("Something's wrong.")
        }
    }

    // MARK: - CoreData
    
    let dataContainer = AppDelegate.persistentContainer
    let dataContext = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
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
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController!.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "kotonoha") as? KotonohaTableViewCell else {
            fatalError("The dequeued cell is not an instance of KotonohaTableViewCell.")
        }
        cell.delegate = self
        cell.editButton.indexPath = indexPath
        let kotonoha = self.fetchedResultsController?.object(at: indexPath) as! Kotonoha
        print("kotonoha: \(kotonoha)");
        cell.kotonohaLabel.text = kotonoha.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionTitle = self.fetchedResultsController?.sections?[section] {
            return sectionTitle.name
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: Date())
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let kotonoha = self.fetchedResultsController?.object(at: indexPath) as! Kotonoha
            dataContext.delete(kotonoha)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        try? dataContext.save()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - UITextFieldDelegate
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        saveKotonoha()
    }
    
    var editingKotonoha: IndexPath?
    
    // MARK: - KotonohaTableViewCellDelegate
    
    func kotonohaTableViewCellEdit(cell: KotonohaTableViewCell) -> () {
        if let indexPath = tableView.indexPath(for: cell) {
            editingKotonoha = indexPath
            kotonohaInputText.text = cell.kotonohaLabel.text
            kotonohaInputText.becomeFirstResponder()
        }
    }

    // MARK: - Action
    
    @IBAction func unselectAll(_ sender: UIButton) {
        self.tableView.indexPathsForSelectedRows?
            .forEach { self.tableView.deselectRow(at: $0, animated: true) }
    }
    
    @IBAction func saveText(_ sender: UIButton) {
        saveKotonoha()
        kotonohaInputText.resignFirstResponder()
    }
    
    func cancelInput(sender: UIBarButtonItem) {
        clearInputText()
        kotonohaInputText.resignFirstResponder()
    }
    
    // MARK: - Private
    
    func saveKotonoha() {
        func getKotonoha() -> Kotonoha {
            if let indexPath = editingKotonoha {
                return self.fetchedResultsController?.object(at: indexPath) as! Kotonoha
            } else {
                return Kotonoha(context: dataContext)
            }
        }
        if let text = kotonohaInputText.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty {
            let kotonoha = getKotonoha();
            kotonoha.text = text
            try? dataContext.save()
        }
        clearInputText()
    }

    func clearInputText() {
        editingKotonoha = nil
        kotonohaInputText.text = ""
    }
    
    func getInputAccessoryView() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(KotonohaViewController.cancelInput))
        toolbar.setItems([spacer,cancelButton], animated: true)
        return toolbar
    }
}
