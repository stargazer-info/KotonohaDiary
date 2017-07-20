//
//  KotonohaDiaryViewController.swift
//  KotonohaDiary
//
//  Created by 山口 伸行 on 2017/07/19.
//  Copyright © 2017年 Stargazer Information. All rights reserved.
//

import UIKit

class KotonohaDiaryViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = text
        // Do any additional setup after loading the view.
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
        dismiss(animated: true, completion: nil)
    }
}
