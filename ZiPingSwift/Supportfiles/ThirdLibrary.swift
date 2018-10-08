//
//  ThirdLibrary.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class Third: NSObject {

    static let toast = Third()
    
    func show(_ block: @escaping ()-> Void)  {

        SwiftNotice.showIndicator(complete: block)
        
    }
    func hide(_ block: @escaping () -> Void) {
//        ARSLineProgress.hideWithCompletionBlock(block)
        SwiftNotice.hideIndicator(hide: block)
    }
    func message(_ message: String) {
        SwiftNotice.showText(message, autoClear: true, autoClearTime: Int(1.5))
    }
    func message(_ message: String, hide: @escaping ToastHideClosure) {
        let _ = SwiftNotice.showText(message, hide: hide)
        
    }
    
}
