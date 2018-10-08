//
//  CYJBasicViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/5.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJBasicViewController: KYBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.random
        
        let btn = UIButton(type: .infoDark)
        
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        view.addSubview(btn)
        
        btn.addTarget(self, action: #selector(goAway), for: .touchUpInside)
        
        
        let nineView = KYSquaredPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.width))
        
        
        view.addSubview(nineView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = "我是大标题"
    }
    
    func goAway() {
        //
        if self.presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }else
        {
            navigationController?.pushViewController(CYJBasicViewController(), animated: true)

        }
//        navigationController?.tabBarController?.navigationController?.pushViewController(UIViewController(), animated: true)

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
