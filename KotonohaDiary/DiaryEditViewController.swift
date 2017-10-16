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
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var text = ""
    var images : [UIImage] = []
    var editingDiary : Diary?
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        if let diary = editingDiary {
            print("editingDiary \(diary)")
            text = diary.text ?? ""
            print("editingDiary.images \(String(describing: diary.images))")
            if let diaryImages = diary.images,
                let imageArr = diaryImages.array as? [Image] {
                images = imageArr.map { UIImage(data:$0.data! as Data)! }
            }
        }
        textView.text = text
        images.append(#imageLiteral(resourceName: "addImage"))
        initImageCollectionView()
        textView.inputAccessoryView = getInputAccessoryView()
        initImagePicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func getInputAccessoryView() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelInput))
        toolbar.setItems([spacer,cancelButton], animated: true)
        return toolbar
    }
    
    func cancelInput(sender: UIBarButtonItem) {
        textView.resignFirstResponder()
    }
    
    func saveDiary() {
        func isEmpty() -> Bool {
            if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !text.isEmpty {
                return false
            }
            if images.count > 1 {
                return false
            }
            return true
        }
        func getDiary() -> Diary {
            if let diary = editingDiary {
                return diary
            } else {
                return Diary(context: dataContext)
            }
        }
        func removeAllImages(diary: Diary) {
            if let images = diary.images?.array as? [Image] {
                for image in images {
                    dataContext.delete(image)
                }
            }
        }
        func createImageEntities() -> [Image] {
            return images.enumerated()
                .filter { $0.offset < images.count - 1 }
                .map { (image) -> Image in
                    let imageEntity = Image(context: dataContext)
                    imageEntity.image = image.element
                    return imageEntity
            }
        }
        if !isEmpty() {
            let diary = getDiary()
            if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                diary.text = text
            }
            if images.count > 1 {
                removeAllImages(diary: diary)
                diary.addToImages(
                    NSOrderedSet(array: createImageEntities())
                )
            }
            print("updated diary \(diary)")
            do {
                try dataContext.save()
            } catch {
                fatalError("Failed to save: \(error)")
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension DiaryEditViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func initImagePicker() {
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("info: \(info)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("image: \(image)")
            let newIndexPath = IndexPath(row: images.count-1, section: 0)
            images.insert(image, at: newIndexPath.row)
            print("images: \(images)")
            imageCollectionView.insertItems(at: [newIndexPath])
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension DiaryEditViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func initImageCollectionView() {
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
//        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
//        }
        self.imageCollectionView.register(UINib(nibName: "DiaryImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "diaryImage")
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("diaryImage: \(indexPath)")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryImage", for: indexPath) as? DiaryImageCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
        }
        print("diaryImage image: \(images[indexPath.row])")
        cell.setImage(image: images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectedItemAt: \(indexPath)")
        if indexPath.row == images.count - 1 {
            pickImage()
        }
    }
}
