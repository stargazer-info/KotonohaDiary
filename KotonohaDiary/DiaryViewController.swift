//
//  DiaryViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/24.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController {

    var diary: Diary?

    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var dairyText: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        initImageCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let diary = diary {
            dateTitle.text = DateFormatUtil.format(date: diary.createdAt! as Date)
            dairyText.text = diary.text
        } else {
            dateTitle.text = DateFormatUtil.format(date: Date())
            dairyText.text = NSLocalizedString("There is no diary.", comment: "The message shown when there is no diary.")
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "showDiaryImage":
            print("showDiaryImage: \(String(describing: sender))")
            if let dest = segue.destination as? ImageViewController, let image = sender as? Image {
                dest.image = image.image
             }
        default:
            fatalError("Something's wrong.")
        }
    }

}

extension DiaryViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func initImageCollectionView() {
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        self.imageCollectionView.register(UINib(nibName: "DiaryImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "diaryImage")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection: \(String(describing: diary))")
        if let diary = diary, let images = diary.images {
            return images.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("diaryImage: \(indexPath)")
        if let image = diary?.images?[indexPath.row] as? Image {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryImage", for: indexPath) as? DiaryImageCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of UICollectionViewCell.")
            }
            print("diaryImage image: \(image)")
            cell.setImage(image: image.image)
            return cell
        } else {
            fatalError("Invalid data")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectedItemAt: \(indexPath)")
        if let image = diary?.images?[indexPath.row] as? Image {
            print("image: \(image)")
            performSegue(withIdentifier: "showDiaryImage", sender: image)
        }
    }
}
