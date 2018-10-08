//
//  KYBaseViewController.swift
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/10.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import HandyJSON
import Alamofire
import Kingfisher
import SnapKit

/// 数据请求的状态
///
/// - firstLoad: 首次运行
/// - emptyDate: 数据为空
/// - netWorkBad: 网络情况差或出现其他错误
enum KYDateStatus {
    case firstLoad, emptyDate, netWorkBad
}

class KYBaseViewController: UIViewController {
    
    //把navigationController放到外面，写一个方法快速调用
    var k_navigationController: UINavigationController? {
        return tabBarController?.navigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
        view.theme_backgroundColor = "Global.backgroundColor"
        
        let backItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        navigationItem.backBarButtonItem = backItem
        
        //FIXME: 增加通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifacation(_:)), name: CYJNotificationName.remoteNotification, object: nil)
    }
    override var shouldAutorotate: Bool
    {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    deinit {
        //        DLog("\(self) deinit 📌📌📌📌")
    }
    
}

extension KYBaseViewController {
    /// 处理通知事件
    ///
    /// - Parameter userInfo: []
    func handleNotifacation(_ notify: Notification) -> Void {
        //
        if let userInfo = notify.userInfo {
            
            var type: Int = 0
            if let strType = userInfo["chnType"] as? String {
                type = Int(strType)!
            }else if let intType = userInfo["chnType"] as? Int {
                type = intType
            }
            
            
            //解析 dataType String 和 Int
            var dataType: Int = 0
            if (userInfo["dataType"] != nil) {
                if let strType = userInfo["dataType"] as? String {
                    dataType = Int(strType)!
                }else if let intType = userInfo["dataType"] as? Int {
                    dataType = intType
                }
            }
            
            //因为不知道 测评申请的chnType是 多少 所以直接判断 dataType == 3情况就是测评审批消息
            if dataType == 3 {
                let applyValuation = ApplyValuationViewController()
                applyValuation.type = 10
                self.getTopNavigationController()?.pushViewController(applyValuation, animated: true)
                return
            }
            
            
            
            
            
            
            
            switch type {
            case 0 :
                DLog("do nothing")
            case 1,2,3 :
                
                var dataId: Int = 0
                if let strId = userInfo["dataId"] as? String {
                    dataId = Int(strId)!
                }else if let intId = userInfo["dataId"] as? Int {
                    dataId = intId
                }
                
                if LocaleSetting.userInfo()?.role == .child{// 家长的话，进家长的页面
                    let detail = CYJMessageRecordDetailControllerP(.grouped)
                    detail.grId = dataId
                    detail.userId = (LocaleSetting.userInfo()?.uId)!
                    self.getTopNavigationController()?.pushViewController(detail, animated: true)
                }else {
                    let vc = CYJMessageRecordDetailControllerT()
                    vc.recordId = dataId
                    
                    self.getTopNavigationController()?.pushViewController(vc, animated: true)
                }
            case 5: //系统消息，和家长的系统消息
                if LocaleSetting.userInfo()?.role == .child {
                    
                    //解析String 和 Int
                    var dataType: Int = 0
                    if let strType = userInfo["dataType"] as? String {
                        dataType = Int(strType)!
                    }else if let intType = userInfo["dataType"] as? Int {
                        dataType = intType
                    }
                    
                    var dataId: Int = 0
                    if let strId = userInfo["dataId"] as? String {
                        dataId = Int(strId)!
                    }else if let intId = userInfo["dataId"] as? Int {
                        dataId = intId
                    }

                    if dataType == 1 {
                        let detail = CYJMessageRecordDetailControllerP(.grouped)
                        detail.grId = dataId
                        detail.userId = (LocaleSetting.userInfo()?.uId)!
                        self.getTopNavigationController()?.pushViewController(detail, animated: true)
                    }else if dataType == 2 {
                        
                        let archiveDetail = CYJMessageArchivesDetailController()
                        archiveDetail.arId = dataId
                        self.getTopNavigationController()?.pushViewController(archiveDetail, animated: true)
                    }
                }else {
                    let notice = CYJMessageSystemController()
                    
                    self.getTopNavigationController()?.pushViewController(notice, animated: true)
                }
            default:
                break
            }
        }
    }
    
    func getTopNavigationController() -> UINavigationController? {
        
        let nav = k_navigationController
        if nav?.topViewController is CYJMessageArchivesDetailController {
            DLog(" ---  CYJMessageArchivesDetailController")
            return nil
        }
        if nav?.topViewController is CYJMessageRecordDetailControllerP {
            DLog(" ---  CYJMessageRecordDetailControllerP")
            return nil
        }
        if nav?.topViewController is CYJMessageRecordDetailControllerT {
            DLog(" ---  CYJMessageRecordDetailControllerT")
            return nil
        }
        if nav?.topViewController is  CYJMessageSystemController{
            DLog(" ---  CYJMessageRecordDetailControllerT")
            return nil
        }
        DLog(" ---  prepare to go")
        
        return nav
        //        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        //
        //        guard let tabBarVC = rootVC as? CYJTabBarController else {
        //            return nil
        //        }
        //
        //        let selectedVc = tabBarVC.viewControllers![tabBarVC.selectedIndex]
        //
        //        guard let nav = selectedVc as? UINavigationController else{
        //            return nil
        //        }
        //        return nav
    }
    
    
}


