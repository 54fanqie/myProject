//
//  KYLoginViewController.swift
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/11.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON
import SwiftTheme

class CYJLoginViewController: KYBaseViewController {
    
    /// 账号
    var accountField: KYInputField!
    /// 密码
    var passwordField: KYInputField!
    /// 登陆按钮
    var loginButton: UIButton!
    
    //MARK: life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录"
        //set background
        let bg = UIImageView(frame: CGRect(x: 0 , y: Theme.Measure.screenHeight - 120, width: Theme.Measure.screenWidth, height: 120))
        bg.theme_image = "Login.backgroundImage"
        view.addSubview(bg)
        
        // set logo
//        let topY = (Theme.Measure.screenHeight - 44 * 4) * 0.3
        let icon = UIImageView(frame: CGRect(x: (Theme.Measure.screenWidth - 150) * 0.5, y: 100, width: 150, height: 150))
        icon.image = #imageLiteral(resourceName: "logo")
        view.addSubview(icon)
        
        //make main UI
        makeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    //MARK: UI
    func makeUI() {
        
        let topY = (Theme.Measure.screenHeight - 44 * 4) * 0.6
        
        let accountImage = ThemeManager.image(for: "Login.lock")
        accountField = KYInputField(image: accountImage, hint: "请输入用户名", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        
        accountField.backgroundColor = UIColor.white
        view.addSubview(accountField)
        let lockImage = ThemeManager.image(for: "Login.account")

        passwordField = KYInputField(_passwordImage: lockImage, hint: "请输入密码", frame: CGRect(x: Theme.Measure.inputLeft, y: accountField.frame.maxY + 10, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        passwordField.backgroundColor = UIColor.white
        passwordField.isSecureTextEntry = true
        view.addSubview(passwordField)
        
        
        loginButton = UIButton(frame: CGRect(x: 20, y: passwordField.frame.maxY + 30, width: Theme.Measure.screenWidth - 40, height: Theme.Measure.buttonHeight))
        loginButton.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        loginButton.setImage(#imageLiteral(resourceName: "login-btn"), for: UIControlState.normal)
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        loginButton.addTarget(self, action: #selector(login(sender:)), for: UIControlEvents.touchUpInside)
        
        view.addSubview(loginButton)
        
        let forgetButton = UIButton(frame: CGRect(x: loginButton.frame.maxX - 100, y: loginButton.frame.maxY + 20, width: 80, height: 21))
        forgetButton.setTitle("忘记密码", for: UIControlState.normal)
        forgetButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        forgetButton.theme_setTitleColor("Nav.barTintColor", forState: UIControlState.normal)
        forgetButton.addTarget(self, action: #selector(forgetPassword), for: UIControlEvents.touchUpInside)
        
        view.addSubview(forgetButton)
        
        
        //        let telButton = UIButton(frame: CGRect(x: 50, y: Theme.Measure.screenHeight - 70, width: Theme.Measure.screenWidth - 100, height: 35))
        //        telButton.setImage(#imageLiteral(resourceName: "photo_verybig_1"), for: UIControlState.normal)
        //        telButton.setTitle(" 010-6890 8368 / 6890 8168", for: UIControlState.normal)
        //        telButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //        telButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
        //        telButton.addTarget(self, action: #selector(makeCall), for: UIControlEvents.touchUpInside)
        //
        //        view.addSubview(telButton)
    }
}

//MARK: 点击事件
extension CYJLoginViewController {
    
    func makeCall() {
        let alert = UIAlertController(title: "是否拨打电话", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "010-68908368", style: UIAlertActionStyle.default, handler: { (alert) in
            //
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "telprompt://010-68908368")!, options: [:], completionHandler: { (url) in
                    //
                    DLog("\(url)")
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: "telprompt://010-68908368")!)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "010-68908168", style: UIAlertActionStyle.default, handler: { (alert) in
            //
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "telprompt://010-68908168")!, options: [:], completionHandler: { (url) in
                    //
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: "telprompt://010-68908368")!)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alert, animated: true) {
            //
        }
    }
    
    
    func validateInput(account: String,password: String) -> Bool{
        
        if (account.count) == 0 {
            DLog("用户名不能为空")
            Third.toast.message("用户名不能为空")
            return false
        }
        if !(account.isVaildPhone) {
            Third.toast.message("请检查手机号格式是否正确")
            return false
        }
        
        if password.isEmpty {
            DLog("密码长度不符")
            Third.toast.message("密码长度不符")
            
            return false
        }
        return true
    }
    
    /// 登陆
    ///
    /// - Parameter sender: <#sender description#>
    func login(sender: UIButton?) {
        //验证是否满足正则
        let account = accountField.text
        let password = passwordField.text
        
        guard validateInput(account: account!,password: password!) else {
            return
        }
        Third.toast.show {
            DLog("开始登陆")
            RequestManager.POST(urlString: APIManager.User.login, params: ["username": account!, "password": password!]) { [unowned self](data, error) in
                Third.toast.hide {
                }
                if !(error != nil){
                    if let data = data{
                        let user = JSONDeserializer<CYJUser>.deserializeFrom(dict: data as? NSDictionary)
                        if let user  = user{
                            if user.isVerification == 1 {
                                //TODO: 去验证页面
                                let verify = CYJVerifyController()
                                verify.user = user
                                
                                self.present(verify, animated: true, completion: nil)
                            }else
                            {
                                let _ = LocaleSetting.saveLocalUser(userInfo: user)

                                let inital = CYJInitialViewController()
                                UIApplication.shared.keyWindow?.rootViewController = inital
                            }
                            
                        }
                    }
                }else
                {
                    if error?.code == 201 {
                        if let toaseMessage = error?.localizedDescription{
                            Third.toast.message(toaseMessage)
                            DLog("\(toaseMessage)")
                        }
                    }else if error?.code == 202 { //失败
                        if let toaseMessage = error?.localizedDescription{
                            Third.toast.message(toaseMessage)
                            DLog("\(toaseMessage)")
                        }
                    }else if error?.code == 203 {
                        let alert = UIAlertController(title: "提示", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }else if error?.code == 403 { //禁止访问
                        if let toaseMessage = error?.localizedDescription{
                            Third.toast.message(toaseMessage)
                            DLog("\(toaseMessage)")
                        }
                    }else
                    {
                        if let toaseMessage = error?.localizedDescription{
                            Third.toast.message(toaseMessage)
                            DLog("\(toaseMessage)")
                        }
                    }
                }
            }
        }
    }
    
    /// 忘记密码
    func forgetPassword() {
        //
        navigationController?.pushViewController(CYJForgetPasswordController(), animated: true)
    }
    
}


