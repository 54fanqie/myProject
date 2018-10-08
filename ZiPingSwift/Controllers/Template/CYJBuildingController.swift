//
//  CYJBuildingController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/14.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import SwiftTheme

class CYJBuildingController: KYBaseViewController {

    var desc: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "pic_house"))
//        imageView.theme_tintColor = Theme.Color.main
        imageView.theme_image = "Global.buildingImage"
        imageView.center = view.center
        
        view.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + 20, width: view.frame.width, height: 21))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.theme_textColor = Theme.Color.main
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        label.text = "建设中..."
        view.addSubview(label)
        
        
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
