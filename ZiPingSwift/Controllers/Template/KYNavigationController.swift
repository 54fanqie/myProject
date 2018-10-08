//
//  KYNavigationController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/20.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import SwiftTheme

open class KYNavigationController: UINavigationController {


    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self

        //设置navBar属性
        let apprence = UINavigationBar.appearance()
        //背景图片
        apprence.theme_backgroundColor = "Nav.barTintColor"

//        bartintColor
        apprence.theme_barTintColor = "Nav.barTintColor"
//        tintColor
        apprence.theme_tintColor = "Nav.barTextColor"
        
        apprence.theme_titleTextAttributes = theme_NavTitleAttributes
        
//        apprence.isTranslucent = false
        
    }
    
    open override var shouldAutorotate: Bool{
        if let top = topViewController {
            return top.shouldAutorotate
        }
        return false
    }

    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if let top = topViewController {
            return top.supportedInterfaceOrientations
        }
        return .portrait
    }
}

extension KYNavigationController : UINavigationControllerDelegate{

    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = true; //viewController是将要被push的控制器，设置隐藏
        }
        super.pushViewController(viewController, animated: true)
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        //
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
    
    
    
}
