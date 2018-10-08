//
//  CYJCheckoutViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJCheckoutViewController: KYBaseTableViewController {

    var dataSource: [CYJUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "切换账号"
        
        tableView.register(UINib(nibName: "CYJUserTableViewCell", bundle: nil), forCellReuseIdentifier: "CYJUserTableViewCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.fetchDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func fetchDataSource() {
        
        
        RequestManager.POST(urlString: APIManager.Mine.listnexus, params: ["token": LocaleSetting.token]) { (data, error) in
            
            guard error == nil else {
                self.statusUpdated(success: false)

                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self.statusUpdated(success: true)

            if let users = data as? NSArray {
                //清除旧数据
                self.dataSource.removeAll()
                //遍历，并赋值
                users.forEach({ [unowned self] in
                    let user = JSONDeserializer<CYJUser>.deserializeFrom(dict: $0 as? NSDictionary)
                    
                    self.dataSource.append(user!)
                })
                
                self.tableView.reloadData()
            }
        }
    }
}

extension CYJCheckoutViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJUserTableViewCell") as! CYJUserTableViewCell
        let user = dataSource[indexPath.row]
        cell.user = user

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return .delete
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "取消绑定") {[unowned self] (action, indexpath) in
            print("cancel bounding")
            self.cancelBounding(indexPath)
        }]
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消绑定"
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 100))
        header.theme_backgroundColor = Theme.Color.ground
        if dataSource.count == 0 {
            let addButton = UIButton(type: .custom)
            addButton.frame = CGRect(x: Theme.Measure.buttonLeft, y: 35, width: Theme.Measure.buttonWidth, height: 32)
            addButton.setTitle("添加关联账号", for: .normal)
            addButton.theme_setTitleColor(Theme.Color.main, forState: .normal)
            addButton.layer.cornerRadius = 5
            addButton.layer.masksToBounds = true
            addButton.layer.theme_borderColor = "Nav.barTintColor"
            addButton.addTarget(self, action: #selector(addNewAccount), for: .touchUpInside)
            addButton.layer.borderWidth = 0.5
            
            header.addSubview(addButton)
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = dataSource[indexPath.row]
        
        RequestManager.POST(urlString: APIManager.Mine.changecount, params: ["uId" : user.uId, "token" : LocaleSetting.token] ) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                
                if error?.code == 203 {
                    //关联账号的密码已经失效
                    self.alertPassword(indexPath, title: "密码失效", message: "您的账号：\(user.username ?? "´ß∑å∑®ƒ")的密码已失效，请重新输入密码进行验证")
                }else if error?.code == 206{
                    self.alertPassword(indexPath, title: "密码验证", message: nil)
                }else
                {
                    Third.toast.message((error?.localizedDescription)!)
                }
                return
            }
            //登陆成功： 解析数据
            let user = JSONDeserializer<CYJUser>.deserializeFrom(dict: data as? NSDictionary)
            
            if user?.isVerification == 1 {
                //TODO: 去验证页面
                let verify = CYJVerifyController()
                verify.user = user
                
                self.present(verify, animated: true, completion: nil)
            }else
            {
                let _ = LocaleSetting.saveLocalUser(userInfo: user!)
                
                let inital = CYJInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = inital
            }
            
//            LocaleSetting.saveLocalUser(userInfo: user!)
//
//            DispatchQueue.main.async {
//                //回到主界面，刷新tab
//                let initialController = CYJInitialViewController()
//                UIApplication.shared.keyWindow?.rootViewController = initialController
//            }
        }
    }
    
    func addNewAccount() {
        let bound = CYJBoundUserController()
        navigationController?.pushViewController(bound, animated: true)
    }
    
    func cancelBounding(_ indexPath: IndexPath) {
        let user = dataSource[indexPath.row]

        RequestManager.POST(urlString: APIManager.Mine.delnuxus, params: ["uId": user.uId, "token": LocaleSetting.token]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            Third.toast.message("取消绑定成功")
            self.dataSource.remove(at: indexPath.row)
            self.tableView.reloadData()
            
        }
    }
    
    func alertPassword(_ indexPath: IndexPath, title: String, message: String?) {
        let user = dataSource[indexPath.row]

        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (field) in
            field.placeholder = "请输入密码"
            field.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            
            let password = alert.textFields?.first?.text
            
            guard (password?.isVaildPassword)! else {
                return
            }
            //去验证一遍密码
            RequestManager.POST(urlString: APIManager.Mine.changecount, params: ["uId" : user.uId, "password" : password! ,"token" : LocaleSetting.token]) { (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                
                //晴空所有消息
                UIApplication.shared.clearAllNotice()
                UIApplication.shared.applicationIconBadgeNumber = 1
                UIApplication.shared.applicationIconBadgeNumber = 0

                //登陆成功： 解析数据
                let user = JSONDeserializer<CYJUser>.deserializeFrom(dict: data as? NSDictionary)
                
                LocaleSetting.saveLocalUser(userInfo: user!)
                
                DispatchQueue.main.async {
                    //回到主界面，刷新tab
                    let initialController = CYJInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = initialController
                }
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
}


extension CYJCheckoutViewController {
    override func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }
    override func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }
}
