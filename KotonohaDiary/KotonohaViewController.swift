//
//  KotonohaViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/16.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit
import CoreData

class KotonohaViewController: UIViewController
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var kotonohaInputText: UITextField!
    
    var editingKotonoha: IndexPath?
    var imagePicker = UIImagePickerController()
    
    let dataContainer = AppDelegate.persistentContainer
    let dataContext = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        self.tabBarController?.tabBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        initializeFetchedResultsController()
        initTableView()
        initImagePicker()
        initKotonohaInput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "AddDiary":
            if let destinationNavigationController = segue.destination as? UINavigationController,
                let dest = destinationNavigationController.topViewController as? DiaryEditViewController,
                let rows = self.tableView.indexPathsForSelectedRows {
                let kotonohas = rows
                    .map {
                        self.fetchedResultsController?.object(at: $0) as? Kotonoha
                }
                dest.text = kotonohas
                    .flatMap { $0?.text }
                    .joined(separator: "\n")
                dest.images = kotonohas
                    .flatMap { $0?.image?.image }
            }
        case "showKotonohaImage":
            if let dest = segue.destination as? ImageViewController, let cell = sender as? KotonohaImageTableViewCell, let image = cell.photo.image {
                dest.image = image
            }
        default:
            fatalError("Something's wrong.")
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
            do {
                try dataContext.save()
            } catch {
                fatalError("Failed to save: \(error)")
            }
        }
        clearInputText()
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
        clearInputText()
    }
    
}

// MARK: - CoreData

extension KotonohaViewController : NSFetchedResultsControllerDelegate {
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
}

// MARK: - UITableView

extension KotonohaViewController : UITableViewDataSource, UITableViewDelegate {
    func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
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
        print("cellForRowAt \(indexPath)")
        let kotonoha = self.fetchedResultsController?.object(at: indexPath) as! Kotonoha
        print("kotonoha \(kotonoha)")
        if let image = kotonoha.image {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "kotonohaImage") as? KotonohaImageTableViewCell else {
                fatalError("The dequeued cell is not an instance of KotonohaImageTableViewCell.")
            }
            cell.delegate = self
            let uiimage = image.image
            cell.setImage(image: uiimage)
            return cell;
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "kotonoha") as? KotonohaTableViewCell else {
                fatalError("The dequeued cell is not an instance of KotonohaTableViewCell.")
            }
            cell.delegate = self
            cell.editButton.indexPath = indexPath
            cell.kotonohaLabel.text = kotonoha.text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = .clear
        label.textColor = .black
        if let sectionTitle = self.fetchedResultsController?.sections?[section] {
            label.text = sectionTitle.name
        } else {
            label.text = DateFormatUtil.format(date: Date())
        }
        return label
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        if let sectionTitle = self.fetchedResultsController?.sections?[section] {
    //            return sectionTitle.name
    //        } else {
    //            let formatter = DateFormatter()
    //            formatter.dateFormat = "yyyy年MM月dd日"
    //            return formatter.string(from: Date())
    //        }
    //    }
    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return fetchedResultsController?.sections?.map { $0.name }
//    }
    
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        guard let sections = fetchedResultsController?.sections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        let sectionInfo = sections[index]
//    }
    
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
        do {
            try dataContext.save()
        } catch {
            fatalError("Failed to save: \(error)")
        }
    }
}

// MARK: - kotonohaInputText

extension KotonohaViewController : UITextFieldDelegate {
    func initKotonohaInput() {
        kotonohaInputText.delegate = self
        kotonohaInputText.inputAccessoryView = getInputAccessoryView()
    }
    
    func getInputAccessoryView() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let imageButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(pickImage))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelInput))
        toolbar.setItems([imageButton,spacer,cancelButton], animated: true)
        return toolbar
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    internal func textFieldDidEndEditing(_ textField: UITextField) {
        saveKotonoha()
    }
    
    func cancelInput(sender: UIBarButtonItem) {
        clearInputText()
        kotonohaInputText.resignFirstResponder()
    }
    
    func clearInputText() {
        editingKotonoha = nil
        kotonohaInputText.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate

extension KotonohaViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func initImagePicker() {
        imagePicker.delegate = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("info: \(info)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("image: \(image)")
            saveKotonohaImage(image: image)
        }
        self.dismiss(animated: true, completion: nil)
    }

    func pickImage() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        if(UIImagePickerController .isSourceTypeAvailable(.camera))
        {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
        }
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

    func openGallary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

}

// MARK: - KotonohaTableViewCellDelegate

extension KotonohaViewController : KotonohaTableViewCellDelegate {
    func kotonohaTableViewCellEdit(cell: KotonohaTableViewCell) -> () {
        if let indexPath = tableView.indexPath(for: cell) {
            editingKotonoha = indexPath
            kotonohaInputText.text = cell.kotonohaLabel.text
            kotonohaInputText.becomeFirstResponder()
        }
    }
}

// MARK: - KotonohaImageTableViewCellDelegate

extension KotonohaViewController : KotonohaImageTableViewCellDelegate {
    func kotonohaImageTableViewCellShowImage(cell: KotonohaImageTableViewCell) {
        performSegue(withIdentifier: "showKotonohaImage", sender: cell)
    }
}
