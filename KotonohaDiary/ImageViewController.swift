//
//  ImageViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/10/03.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = image {
            photo.image = image
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

    @IBAction func swiped() {
        dismiss(animated: true, completion: nil)
    }
}
