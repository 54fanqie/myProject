//
//  NoPartakeViewController.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/9/5.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit

class NoPartakeViewController: KYBaseViewController {

    @IBOutlet weak var titleLab: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "本年级暂未参与集中测评哦~"
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

}
