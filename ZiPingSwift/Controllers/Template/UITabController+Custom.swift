//
//  KYTabController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/25.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    open override var shouldAutorotate: Bool
    {
        if let vc = selectedViewController {
            return vc.shouldAutorotate
        }
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if let vc = selectedViewController {
            return vc.supportedInterfaceOrientations
        }
        return .portrait
    }
    
    /**
     tabbar显示小红点
     
     @param index 第几个控制器显示，从0开始算起
     */
    func showBadgeOnItem(at index: Int) {
        removeBadge(at: index)
        
        let red = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
        red.theme_backgroundColor = Theme.Color.badge
        red.layer.cornerRadius = 3.5
        red.layer.masksToBounds = true
        red.tag = 666 + index
        //计算小红点的X值，根据第index控制器，小红点在每个tabbar按钮的中部偏移0.1，即是每个按钮宽度的0.6倍
        
        let itemFrame = tabBar.itemFrame(index)
        
        let x = itemFrame.midX + 13 ;
        let y = 0.1 * itemFrame.height
        
        
        red.frame = CGRect(x: x, y: y, width: 7, height: 7)
        self.tabBar.addSubview(red)
        self.tabBar.bringSubview(toFront: red)
        
    }
    /// 移除红点
    ///
    /// - Parameter index: <#index description#>
    func removeBadge(at index: Int) {
        
        for sub in self.tabBar.subviews {
            if sub.tag == 666 + index {
                sub.removeFromSuperview()
            }
        }
    }
    
    /// 隐藏红点
    ///
    /// - Parameter index: <#index description#>
    func hideBadge(at index: Int) {
        self .removeBadge(at: index)
    }

}
