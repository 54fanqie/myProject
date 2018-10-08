//
//  CYJNavigationController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/5.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJNavigationController: UINavigationController, UINavigationControllerDelegate   {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = true; //viewController是将要被push的控制器，设置隐藏
            DLog("\(viewController.description) appear")
        }
        super.pushViewController(viewController, animated: true)
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        //
        if navigationController.viewControllers.count > 1 {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }else
        {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
        
        //MARK: 判断是否隐藏navBar,首页，player页，我的，登录
//        if viewController is CYJIndexViewController || viewController is KYPlayerController  || viewController is CYJMineViewController || viewController is CYJLoginViewController{
//            navigationController.setNavigationBarHidden(true, animated: animated)
//            DLog("\(viewController.description) appear")
//            
//        }else
//        {
//            navigationController.setNavigationBarHidden(false, animated: animated)
//            DLog("\(viewController.description) appear")
//        }
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
