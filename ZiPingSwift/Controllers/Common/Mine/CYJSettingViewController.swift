//
//  CYJSettingViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import Kingfisher

class CYJSettingViewController: KYBaseTableViewController {

    var examples: [KYTableExample] = []
    
    var cacheLength: UInt = 0
    
    var lastedVersion: String?
    
    var minorVersion: String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary! ["CFBundleShortVersionString"] as! String
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "设置"
        self.tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        examples.append(KYTableExample(key: "resetPassword", title: "重设密码", selector: #selector(resetPassword), image: nil))
//        examples.append(KYTableExample(key: "theme", title: "设置皮肤", selector: #selector(checkTheme), image: nil))
        examples.append(KYTableExample(key: "cache", title: "清除缓存", selector: #selector(clearCache), image: nil))
        examples.append(KYTableExample(key: "notify", title: "允许推送通知", selector: #selector(goInfo), image: nil))
        examples.append(KYTableExample(key: "version", title: "系统版本", selector: #selector(goInfo), image: nil))
        examples.append(KYTableExample(key: "logout", title: "退出", selector: #selector(logout), image: nil))
        
        //        载入缓存数据
        KingfisherManager.shared.cache.calculateDiskCacheSize { (length) in
            DLog("calculateDiskCacheSize: \(length)")
            
            self.cacheLength = length + AttachManager.default.countAttach()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUpdate()
        
        KingfisherManager.shared.cache.calculateDiskCacheSize { (length) in
            DLog("calculateDiskCacheSize: \(length)")
            self.cacheLength = length + AttachManager.default.countAttach()

            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goInfo() {
        
    }
    
}

extension CYJSettingViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MineCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "MineCell")
            cell?.textLabel?.theme_textColor = Theme.Color.textColorDark
            cell?.detailTextLabel?.theme_textColor = Theme.Color.textColorlight
        }
        let example = examples[indexPath.row]
        cell?.textLabel?.text = example.title
        
        switch (example.key)! {
        case "cache":
            cell?.detailTextLabel?.text = "\(self.cacheLength.formateFileSize())"
        case "version":
            
                let infoDictionary = Bundle.main.infoDictionary
                let minorVersion : String? = infoDictionary! ["CFBundleShortVersionString"] as? String
                if lastedVersion == nil {
                    cell?.detailTextLabel?.text = minorVersion
                }else
                {
                    let newVersion = "(\(lastedVersion!) new!)"
                    
                    let attrStr = NSMutableAttributedString(string: newVersion, attributes: [NSForegroundColorAttributeName : UIColor.red])
                    
                    attrStr.append(NSAttributedString(string: "当前：" + minorVersion!))
                    
                    cell?.detailTextLabel?.attributedText = attrStr
                }
        case "notify":
                let door = UISwitch()
//                let refuse = UserDefaults.standard.bool(forKey: CYJUserDefaultKey.refuseNotification)
                
                let notiSetting = UIApplication.shared.currentUserNotificationSettings
                if notiSetting?.types == UIUserNotificationType.init(rawValue: 0) {
                    door.isOn = false
                } else {
                    door.isOn = true
//                    door.isEnabled = false
                }
                
//                door.isOn = !refuse
                door.addTarget(self, action: #selector(alowedNotification(sender:)), for: UIControlEvents.valueChanged)
                cell?.accessoryView = door
        default:
            cell?.detailTextLabel?.text = nil
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = examples[indexPath.row]
        
        perform(example.selector)
    }
}

extension CYJSettingViewController {
    
    func applicationBecomeActive() {
        self.tableView.reloadData()
    }
    
    func alowedNotification(sender: UISwitch) {
        
//        let refuse = !(sender.isOn)
//        UserDefaults.standard.set(refuse, forKey: CYJUserDefaultKey.refuseNotification)
        
//        let appdelegate = UIApplication.shared.delegate as? AppDelegate
//        let _ = appdelegate?.actionsForRemoteNotifications()
        let urlObj = URL(string:UIApplicationOpenSettingsURLString)

        // 前往设置
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(urlObj! as URL, options: [ : ]) { (result) in
                // 如果判断是否返回成功
                if result {
                    let notiSetting = UIApplication.shared.currentUserNotificationSettings
                    if notiSetting?.types == UIUserNotificationType.init(rawValue: 0) {
                        sender.isOn = false
                        //                    self.sender.isEnabled = true
                    } else {
                        sender.isOn = true
                        //                    self.sender.isEnabled = false
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(urlObj!)
        }
        print("value cangeed : \(sender.isOn)")
    }
    
    func resetPassword() {
        let reset = CYJResetPasswordController()
        
        self.navigationController?.pushViewController(reset, animated: true)
    }
    
    func checkTheme() {
        let themeC = CYJThemeViewController()
        
        navigationController?.pushViewController(themeC, animated: true)
    }
    
    func clearCache()  {
        let alert = UIAlertController(title: "是否清除缓存", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (s1) in
            DLog("取消")
        }
        let sure = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (a) in
            //
            KingfisherManager.shared.cache.clearDiskCache()
            AttachManager.default.clearAttachmentCache()
            
            self.tableView.reloadData()
            Third.toast.message("已清除", hide: {
                //
                KingfisherManager.shared.cache.calculateDiskCacheSize { (length) in
                    DLog("calculateDiskCacheSize: \(length)")
                    self.cacheLength = length + AttachManager.default.countAttach()
                    self.tableView.reloadData()
                }
            })
        }
        alert.addAction(cancel)
        alert.addAction(sure)
        
        self.present(alert, animated: true) {
            //
        }
    }
    
    func logout() {
        
        //FIXME:  logout , relogin
        
        LocaleSetting.logout()
        
        let initialController = CYJInitialViewController()
//        let masterTab = CYJTx abBarController()
//        let masterNav = KYNavigationController(rootViewController: masterTab)
        JPUSHService.cleanTags({ (status, tags, code) in
            
        }, seq: 0 )
        JPUSHService.deleteAlias({ (status, tags, code) in
            
        }, seq: 0)
        
        UIApplication.shared.keyWindow?.rootViewController = initialController
        
    }
    
    
    func checkUpdate() {
        LocaleSetting.share.checkUpdate { (newVersion, releaseNotes) in
            self.lastedVersion = newVersion
            if (self.lastedVersion?.isNewVersion())! {
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            }
        }
    }
    
    func updateApp() {
        
        guard lastedVersion != nil else {
            return
        }
        
        if (self.lastedVersion?.isNewVersion())! {
            
            let alert = UIAlertController(title: "升级新版本\(lastedVersion ?? "000")", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                
                UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/cn/app/%E5%B9%BC%E7%A6%BE%E4%BA%91%E8%AF%BE%E5%A0%82-%E5%B9%BC%E5%84%BF%E6%95%99%E5%B8%88%E7%9A%84%E5%9C%A8%E7%BA%BF%E5%AD%A6%E4%B9%A0%E4%BA%A4%E6%B5%81%E5%B9%B3%E5%8F%B0/id1329843949?mt=8")!)
            }))
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                UIApplication.shared.keyWindow?.topMostWindowController()?.present(alert, animated: true, completion: nil)
            })
        }
    }
}



