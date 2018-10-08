//
//  LocaleSetting.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/17.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON

final class LocaleSetting: NSObject {
    
    static let share =  LocaleSetting()
    
    lazy var user: CYJUser? = {
        
        return LocaleSetting.share.getLocalUser()
        
    }()

    //
    //    override init() {
    ////        unReadMessageCount =
    //        super.init()
    //    }
    //
    
    fileprivate let kLocaleUserInfoKey = "KLOCALUSERINFOKEY"
    
    var unReadMessageCount: CYJUnreadMessageCount = CYJUnreadMessageCount()
    
    /// 记录 成长记录有没有改变
    var recordChanged: Bool = false
    
    /// 获取当前用户的token
    class var token: String! {
        return LocaleSetting.userInfo()?.token ?? "token为空"
    }
    /// 你保存当前用户
    ///
    /// - Parameter userInfo: <#userInfo description#>
    /// - Returns: <#return value description#>
    class func saveLocalUser(userInfo: CYJUser) {
        LocaleSetting.share.saveLocalUser(userInfo:userInfo)
    }
    
    /// 清除当前用户
    class func clearUserInfo(){
        LocaleSetting.share.clearUserInfo()
    }
    
    /// 获取当前用户
    ///
    /// - Returns: <#return value description#>
    class func userInfo() -> CYJUser? {
        
        //        return LocaleSetting.share.getLocalUser();
        guard let user = LocaleSetting.share.user else {
            return nil
        }
        return user
    }
    
    
    /// 登出，清除用户数据
    class func logout() {
        LocaleSetting.share.clearUserInfo()
    }
    
}

extension LocaleSetting {
    
    fileprivate func saveLocalUser(userInfo: CYJUser) {
        //
        user = userInfo
        
        updateJPush()
        
        let data = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        UserDefaults.standard.set(data, forKey: kLocaleUserInfoKey)
        UserDefaults.standard.synchronize()
    }
    
    func updateJPush() {
        
        //TODO: 设置Jpush 的标签和别名
        
        if let userInfo = user {
            
            JPUSHService.setAlias("uId_\((user?.uId)!)", completion: { (int, alias, status) in
                DLog("set alias:  status-\(int), alias-\(alias ?? "??") \(status)")
            }, seq: 0)
            
            var tag: String //园长 班主任 配班教师  家长
            switch userInfo.role {
            case .master:
                tag = "园长"
            case .teacher:
                tag = "教师"
            case .teacherL:
                tag = "教师"
            case .child:
                tag = "家长"
            default:
                tag = "--"
            }
            JPUSHService.setTags([tag], completion: { (int, tags, status) in
                DLog("set tag: status-\(int), tags-\(tags ?? ["??"]) \(status)")
            }, seq: 0)
            
        }
        
    }
    
    fileprivate func clearUserInfo(){
        
        //1. 清空user
        user = nil
        //2. 清空userdefault
        UserDefaults.standard.removeObject(forKey: kLocaleUserInfoKey)
        UserDefaults.standard.synchronize()
        
    }
    fileprivate func getLocalUser() -> CYJUser? {
        user = nil
        if let exit = UserDefaults.standard.value(forKeyPath: kLocaleUserInfoKey){
            let data = exit as! Data
            user = NSKeyedUnarchiver.unarchiveObject(with: data) as? CYJUser
        }
        
        guard let user = user else {
            print("local user Non-existent")
            return nil
        }
        return user;
    }
    
    /// 检查是不是最新版本
    ///
    /// - Parameter complete: <#complete description#>
    public func checkUpdate(complete: @escaping ((_ newVersion: String, _ releaseNote: String?)->Void)) {
        
        Alamofire.request(URL(string: "https://itunes.apple.com/lookup?id=1315876057")!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (responds) in
            switch responds.result {
            case .success(let value):
                //根据返回值判断custom 错误
                if let infos = value as? NSDictionary {
                    if let results = infos["results"] as? NSArray {
                        if let infoDict = results.firstObject as? NSDictionary {
                            print("当前版本为：\(String(describing: infoDict["version"]))")
                            let onlineVersion = (infoDict["version"] as? String)!
                            let releaseNote = infoDict["releaseNotes"] as? String
                            complete(onlineVersion, releaseNote)
                        }
                    }
                }else {
                    //未发布暂时
                    complete("1.0", "新版本发布")
                }
            case .failure(_):
                break
            }
        }
    }
    
    func fetchUnreadMessageCount() {
        
        RequestManager.POST(urlString: APIManager.Message.info, params: ["token": LocaleSetting.token])  {[unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                print((error?.localizedDescription)!)
                return
            }
            //解析数据
            let model = JSONDeserializer<CYJUnreadMessageCount>.deserializeFrom(dict: data as? NSDictionary)
            DispatchQueue.main.async {
                self.unReadMessageCount = model!
                
                NotificationCenter.default.post(name: CYJNotificationName.unreadMessageCountChanged, object: nil)
            }
        }
    }
}
