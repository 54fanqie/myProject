//
//  PrefixHeader.swift
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/10.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import UIKit
import HandyJSON

import SwiftTheme

protocol CYJActionPassOnDeleagte: class {
    func actionsPass(on sender: UITableViewCell) -> Void
}

typealias CYJCompleteHandler = (Any?) -> Void

let UMAnalyseKey = "5924ebf6c895767f6d0018be"


let CYJAttachmentPrefix = "com.chnyoujiao.CYJAttachmentPrefix"
let CYJErrorDomainName = "com.chinayoujiao.eziping"

/// 系统版本key
struct CYJUserDefaultKey{
    static let leadingVersion = "CYJUSERDEFAULT_leadingVersionKey"
    static let loginLog = "CYJUSERDEFAULT_loginLogKey"
    static let answerTitle = "CYJUSERDEFAULT_answerTitle"
    static let updatedVersion = "CYJUSERDEFAULT_updatedVersion"
    static let unreadMessageCount = "CYJUSERDEFAULT_unreadMessageCount"
    /// 是否拒绝接受通知，默认 false
    static let refuseNotification = "CYJUSERDEFAULT_refuseNotification"
    static let currentTheme = "CYJUSERDEFAULT_currentTheme"
    
}

struct CYJNotificationName {
    static let playerVideoChange = NSNotification.Name("CYJNotificationNameKeyCurrentVideoPlaying")
    static let playerFinishVideo = NSNotification.Name("CYJNotificationNameKeyFinishedPlayVideo")
    static let recordChanged = NSNotification.Name("CYJNotificationNameKeyRecordChanged")
    static let videoSelectedFinish = NSNotification.Name("CYJNotificationNameKeyvideoSelectedFinish")
    static let unreadMessageCountChanged = NSNotification.Name("CYJNotificationNameKeyunreadMessageCountChanged")
    static let remoteNotification = NSNotification.Name("CYJNotificationNameKeyremoteNotification")
    
}

struct Theme {
    
    struct Measure {
        static let screenWidth: CGFloat = { return UIScreen.main.bounds.size.width}()
        static let screenHeight: CGFloat = { return UIScreen.main.bounds.size.height}()
        
        static let inputLeft: CGFloat = 54
        static let inputWidth: CGFloat = { return screenWidth - 2 * Theme.Measure.inputLeft}()
        static let inputHeight: CGFloat = 50
        
        static let buttonLeft: CGFloat = { return screenWidth * 0.25 }()
        static let buttonWidth: CGFloat = { return screenWidth * 0.5}()
        static let buttonHeight: CGFloat = 40
        
        static let cellHeight: CGFloat = 55
        
        /// 根据750*1334得到的宽高
        static func tWidth(_ width: CGFloat) -> CGFloat {
            return screenWidth * width / 375
        }
        /// 根据750*1334得到的宽高
        static func tHeight(_ height: CGFloat) -> CGFloat {
            return screenHeight * height / 667
        }
        
        
        // 屏幕宽度
        
        static let JMTWindowWidth = UIScreen.main.bounds.size.width
        
        // 屏幕高度
        
        static let JMTWindowHeight = UIScreen.main.bounds.size.height
        
        // iPhone4
        
        static let isIphone4 = JMTWindowHeight  < 568 ? true : false
        
        // iPhone 5
        
        static let isIphone5 = JMTWindowHeight  == 568 ? true : false
        
        // iPhone 6
        
        static let isIphone6 = JMTWindowHeight  == 667 ? true : false
        
        // iphone 6P
        
        static  let isIphone6P = JMTWindowHeight == 736 ? true : false
        
        // iphone X
        
        static let isIphoneX = JMTWindowHeight == 812 ? true : false
        
        // navigationBarHeight
        
        static let navigationBarHeight : CGFloat = isIphoneX ? 88 : 64
        
        //navigationStatueBarHeight
        static let navigationStatueBarHeight : CGFloat = isIphoneX ? 44 : 20
        // tabBarHeight
        
        static  let tabBarHeight : CGFloat = isIphoneX ? 49 + 34 : 49
        
    }
    
    struct Color {
        static let main: ThemeColorPicker = "Nav.barTintColor"
        static let TabMain: ThemeColorPicker = "Tab.barTintColor"
        static let ground: ThemeColorPicker = "Global.backgroundColor"
        static let textColorDark: ThemeColorPicker = "Global.textColorDark"
        static let textColor: ThemeColorPicker = "Global.textColorMid"
        static let textColorlight: ThemeColorPicker = "Global.textColorLight"
        static let textColorHint : ThemeColorPicker = "Global.textColorHint"
        static let viewLightColor: ThemeColorPicker = "Global.viewLightColor"
        static let viewLightGray : ThemeColorPicker = "Global.viewLightGray"
        static let badge: ThemeColorPicker = "Global.badgeColor"
        static let line : ThemeColorPicker = "Global.separatorColor"
        
        static func color(_ literal: String) -> UIColor {
            return ThemeManager.color(for: literal)!
        }
    }
    
    struct Font {
        static let title = UIFont.systemFont(ofSize: 16) // 36
        static let content = UIFont.systemFont(ofSize: 14) // 36
        static let min = UIFont.systemFont(ofSize: 12) // 36
    }
    
}

func DLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)],\(method):\(message)")
    #endif
}

let VideoRadio = CGFloat(16.8/30.0)
