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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DiaryViewController viewDidLoad")
        if let diary = diary {
            print("diary \(diary)")
            dateTitle.text = DateFormatUtil.format(date: diary.createdAt! as Date)
            dairyText.text = diary.text
            print("dateTitle \(String(describing: dateTitle.text))")
            print("dairyText \(dairyText.text)")
        } else {
            dateTitle.text = DateFormatUtil.format(date: Date())
            dairyText.text = NSLocalizedString("There is no diary.", comment: "The message shown when there is no diary.")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
