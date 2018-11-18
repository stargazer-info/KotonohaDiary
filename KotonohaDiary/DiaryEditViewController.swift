//
//  KotonohaDiaryViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/19.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class DiaryEditViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var text = ""
    var images : [UIImage] = []
    var editingDiary : Diary?
    var diaryController = DiaryController()
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        registerForKeyboardNotifications()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue:")
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "showEditDiaryImage":
            print("showEditDiaryImage: \(String(describing: sender))")
            if let dest = segue.destination as? ImageViewController, let image = sender as? UIImage {
                print("image: \(image)")
                dest.image = image
                dest.showDeleteBtn = true
            }
        default:
            fatalError("Something's wrong.")
        }
    }

    @IBAction func unwindToDiaryEdit(sender: UIStoryboardSegue) {
        print("selected: \(String(describing: imageCollectionView.indexPathsForSelectedItems))")
        if let index = imageCollectionView.indexPathsForSelectedItems?.first {
            images.remove(at: index.row)
            imageCollectionView.deleteItems(at: [index])
        }
    }
    
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
    
    // MARK: - Private
    
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
        if !isEmpty() {
            do {
                try diaryController.save(
                    editingDiary: editingDiary,
                    text: textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    images: images.enumerated()
                        .filter { $0.offset < images.indices.last! }
                        .map{ $0.element }
                )
            } catch {
                fatalError("Failed to save: \(error)")
            }
        }
    }
    
    func getInputAccessoryView() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelInput))
        toolbar.setItems([spacer,cancelButton], animated: true)
        return toolbar
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        print("keyboardWasShown \(notification)")
        func getContentInsets() -> UIEdgeInsets? {
            print("userInfo \(String(describing: notification.userInfo))")
            if let kbFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                print("kbFrame \(kbFrame)")
                print("textView.bounds \(textView.bounds)")
                let bottom = textView.bounds.origin.y + textView.bounds.height;
                print("textView bottom \(bottom)")
                let kbFrameInTextView = textView.convert(kbFrame, from: nil)
                print("kbFrameInTextView \(kbFrameInTextView)")
                let kbTop = kbFrameInTextView.origin.y
                print("kbTop \(kbTop)")
                let hiddenLength = bottom - kbTop
                return hiddenLength > 0 ? UIEdgeInsetsMake(0.0, 0.0, hiddenLength, 0.0) : nil
            } else {
                return nil
            }
        }
        if let contentInsets = getContentInsets() {
            print("contentInsets \(contentInsets)")
            textView.contentInset = contentInsets
            textView.scrollIndicatorInsets = contentInsets
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        print("keyboardWillBeHidden \(notification)")
        let contentInsets = UIEdgeInsets.zero;
        textView.contentInset = contentInsets;
        textView.scrollIndicatorInsets = contentInsets;
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
            let newIndexPath = IndexPath(row: images.indices.last!, section: 0)
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
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        imageCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = imageCollectionView.indexPathForItem(at: gesture.location(in: imageCollectionView)) else {
                break
            }
            imageCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            imageCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            imageCollectionView.endInteractiveMovement()
        default:
            imageCollectionView.cancelInteractiveMovement()
        }
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
        print("images.endIndex: \(String(describing: images.indices.last))")
        if indexPath.row == images.indices.last {
            pickImage()
        } else {
            let image = images[indexPath.row]
            print("image: \(image)")
            performSegue(withIdentifier: "showEditDiaryImage", sender: image)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == images.indices.last {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        images.insert(
            images.remove(at: sourceIndexPath.row),
            at: destinationIndexPath.row
        )
    }
}
