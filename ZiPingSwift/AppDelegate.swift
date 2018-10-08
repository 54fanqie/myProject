//
//  AppDelegate.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/29.
//  Copyright © 2017年 Rmyh. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

//#if NSFoundationVersionNumber_iOS_9_x_Max
//    import UserNotifications
//#endif

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //TODO: 默认打开 IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        
        //TODO: 使用已选中的主题
        let themeRawValue = UserDefaults.standard.integer(forKey: CYJUserDefaultKey.currentTheme)
        CYJThemes.switchTo( CYJThemes(rawValue: themeRawValue)!)
        
//        if self.actionsForRemoteNotifications() {
        
            //TODO: 如果没注册通知实体--通知注册实体类
            let entity = JPUSHRegisterEntity()
            entity.types = Int(JPAuthorizationOptions.alert.rawValue) |  Int(JPAuthorizationOptions.sound.rawValue) |  Int(JPAuthorizationOptions.badge.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
            //TODO: 注册极光推送
            JPUSHService.setup(withOption: launchOptions, appKey: "7352d4bdd5a84f99e2b44658", channel:"Publish channel" , apsForProduction: false);
            
            // 获取推送消息
            let remote = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? Dictionary<String,Any>;
            // 如果remote不为空，就代表应用在未打开的时候收到了推送消息
            if remote != nil {
                // 收到推送消息实现的方法
                self.perform(#selector(receivePush(_:)), with: remote, afterDelay: 1.0);
            }
        
        //每次打开app，检查版本更新
        checkVersion()
//        }

        return true
    }

    /// 推送操作
    func actionsForRemoteNotifications() -> Bool{
        let refuse = UserDefaults.standard.bool(forKey: CYJUserDefaultKey.refuseNotification)
        
        //不允许发送通知，
        guard !refuse else {
            //如果已经加了推送的话，那么停止推送
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
            return false
        }
        
        //允许发送通知
        if !(UIApplication.shared.isRegisteredForRemoteNotifications) {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        if (UIApplication.shared.isRegisteredForRemoteNotifications) {
            //TODO: 如果没注册通知实体--通知注册实体类
            let entity = JPUSHRegisterEntity();
            entity.types = Int(JPAuthorizationOptions.alert.rawValue) |  Int(JPAuthorizationOptions.sound.rawValue) |  Int(JPAuthorizationOptions.badge.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        }
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DLog("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //MARK: 到前台时,并且在一登陆状态下，更新未读消息数目
//        if let _ = LocaleSetting.userInfo() {
//            LocaleSetting.share.fetchUnreadMessageCount()
//        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //MARK: 到前台时,并且在一登陆状态下，更新未读消息数目
        if let _ = LocaleSetting.userInfo() {
            
            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "alert", message: "\(LocaleSetting.userInfo()?.token ?? "token??")", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "quxiao", style: .cancel, handler: nil))
//                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                LocaleSetting.share.fetchUnreadMessageCount()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: -JPUSHRegisterDelegate
    // iOS 10.x 需要
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //MARK: 收到消息之后，默认执行了这个方法
        JPUSHService.handleRemoteNotification(userInfo);
        completionHandler(UIBackgroundFetchResult.newData);
        
        if application.applicationState == .active {
            JPUSHService.setBadge(0)
        }else if application.applicationState == .inactive{
            _handleNotifacation(userInfo: userInfo)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        JPUSHService.handleRemoteNotification(userInfo);
    }
    
    // 接收到推送实现的方法
    func receivePush(_ userInfo : Dictionary<String,Any>) {
        // 角标变0
        UIApplication.shared.applicationIconBadgeNumber = 1;
        UIApplication.shared.applicationIconBadgeNumber = 0;
        // 剩下的根据需要自定义
        _handleNotifacation(userInfo: userInfo)
    }
    
    /// 处理通知事件
    ///
    /// - Parameter userInfo: []
    func _handleNotifacation(userInfo: [AnyHashable: Any]) -> Void {
        //
        NotificationCenter.default.post(name: CYJNotificationName.remoteNotification, object: nil, userInfo: userInfo)
//        if let type = userInfo["chnType"] as? String {
//            DLog("chnType: \(type)")
//
//            switch type {
//            case "0" :
//                DLog("do nothing")
//            case "1","2","3" :
//
//                if let dataId = userInfo["dataId"] as? String {
//                    if LocaleSetting.userInfo()?.role == .child{// 家长的话，进家长的页面
//                        let detail = CYJRECControllerViewByParent(.grouped)
//                        detail.grId = Int(dataId)!
//                        self.getTopNavigationController()?.pushViewController(detail, animated: true)
//                    }else {
//                        let vc = CYJRECDetailViewController()
//                        vc.recordId = Int(dataId)!
//
//                        self.getTopNavigationController()?.pushViewController(vc, animated: true)
//                    }
//                }
//            case "5": //系统消息，和家长的系统消息
//                if LocaleSetting.userInfo()?.role == .child {
//                    if let dataType = userInfo["dataType"] as? String {
//                        if let dataId = userInfo["dataId"] as? String {
//                            if dataType == "1" {
//                                let detail = CYJRECControllerViewByParent(.grouped)
//                                detail.grId = Int(dataId)!
//                                self.getTopNavigationController()?.pushViewController(detail, animated: true)
//                            }else {
//
//                                let archiveDetail = CYJArchiveDetailController()
//                                archiveDetail.arId = Int(dataId)!
//                                self.getTopNavigationController()?.pushViewController(archiveDetail, animated: true)
//                            }
//                        }
//                    }
//                }else {
//                    let notice = CYJMessageSystemController()
//
//                    self.getTopNavigationController()?.pushViewController(notice, animated: true)
//                }
//            default:
//                break
//            }
//        }
    }
    
    func getTopNavigationController() -> UINavigationController? {
        
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        
        guard let tabBarVC = rootVC as? CYJTabBarController else {
            return nil
        }
        
        let selectedVc = tabBarVC.viewControllers![tabBarVC.selectedIndex]
            
        guard let nav = selectedVc as? UINavigationController else{
                return nil
            }
        return nav
    }
}

extension AppDelegate : JPUSHRegisterDelegate{
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        print(">JPUSHRegisterDelegate jpushNotificationCenter willPresent");
        //MARK: 本地收到消息
        let userInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
//        completionHandler(Int(UNAuthorizationOptions.badge.rawValue))
//        completionHandler(Int(UNAuthorizationOptions.sound.rawValue))
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        //MARK: 点击消息之后，进入这个方法
        print(">JPUSHRegisterDelegate jpushNotificationCenter didReceive");
        let userInfo = response.notification.request.content.userInfo
        print("userInfo: \(userInfo)")
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
            //去处理本地消息
            _handleNotifacation(userInfo: userInfo)
        }else
        {
            //前台运行时收到推送 转的本地通知，如果没有查看，而是退到后台 或杀死程序，点击了推送到前台push处理==============
            //前台运行时 转的本地通知 直接点击也走这个方法
            _handleNotifacation(userInfo: userInfo)
        }
        UIApplication.shared.applicationIconBadgeNumber = 1;
        UIApplication.shared.applicationIconBadgeNumber = 0;
        JPUSHService.setBadge(0)

        completionHandler()
    }
    
    
    func checkVersion() {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) {
            LocaleSetting.share.checkUpdate(complete: { (newVersion, releaseNotes) in
                
                if newVersion.isNewVersion() {
                    //版本有变动
                    let alert = UIAlertController(title: "发现新版本\(newVersion)", message: releaseNotes, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                        
                        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/cn/app/%E5%B9%BC%E7%A6%BE%E4%BA%91%E8%AF%BE%E5%A0%82-%E5%B9%BC%E5%84%BF%E6%95%99%E5%B8%88%E7%9A%84%E5%9C%A8%E7%BA%BF%E5%AD%A6%E4%B9%A0%E4%BA%A4%E6%B5%81%E5%B9%B3%E5%8F%B0/id1329843949?mt=8")!)
                    }))
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        let vc = UIApplication.shared.keyWindow?.topMostWindowController()
                        vc?.present(alert, animated: true, completion: {})
                    })
                }
            })
        }

    }
}


