//
//  File.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/29.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

class CYJVerifyController: KYBaseViewController  {
    
    var toastLabel: UILabel!
    var phoneLabel: UILabel!
    
    var verifyField: KYInputField!
    
    var cancelButton: UIButton!
    var uploadButton: UIButton!
    
    var user: CYJUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //input code here
        
        toastLabel = UILabel(frame: CGRect(x: 48, y: 110, width: Theme.Measure.screenWidth - 2 * 48, height: 75))
        toastLabel.font = UIFont.systemFont(ofSize: 15)
        toastLabel.theme_textColor = Theme.Color.textColorlight
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        
        
        
        toastLabel.text = "您好，\(user.sName ?? "异常") 已将您加入到该园的教师，如果确认加入该园，请获取验证码并进行验证，否者点击不加入，拒绝加入该园。"
        
        view.addSubview(toastLabel)
        
        phoneLabel = UILabel(frame: CGRect(x: 48, y: toastLabel.frame.maxY + 30, width: Theme.Measure.screenWidth - 2 * 48, height: 16))
        phoneLabel.font = UIFont.systemFont(ofSize: 15)
        phoneLabel.theme_textColor = Theme.Color.textColorDark
        phoneLabel.numberOfLines = 1
        
        phoneLabel.text = "您的手机号：\(self.user.username ?? "异常")"
        
        view.addSubview(phoneLabel)
        
        verifyField = KYInputField(_verifierImage: nil, hint: "请输入验证码", frame: CGRect(x: 48, y: phoneLabel.frame.maxY + 15, width: Theme.Measure.screenWidth - 2 * 48, height: 50))
        
        verifyField.aButton?.addTarget(self, action: #selector(getCode), for: .touchUpInside)
        
        view.addSubview(verifyField)
        
        cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 80, y: verifyField.frame.maxY + 40, width: 85, height: 32)
        cancelButton.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.theme_borderColor = "Global.separatorColor"
        cancelButton.setTitle("不加入", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        uploadButton = UIButton(type: .custom)
        uploadButton.frame = CGRect(x: view.frame.width - 100 - 80, y: verifyField.frame.maxY + 40, width: 100, height: 32)
        uploadButton.setTitle("加入", for: .normal)

        uploadButton.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        uploadButton.theme_backgroundColor = Theme.Color.main
        uploadButton.layer.cornerRadius = 5
        uploadButton.layer.masksToBounds = true
        uploadButton.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
        view.addSubview(uploadButton)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //input code here
    }
}

//MARK: make UI
extension CYJVerifyController {
    
}
//MARK: click method
extension CYJVerifyController {
    
    
    /// 获取验证码
    func getCode() {
        
        self.verifyField.aButton?.isEnabled = false
        RequestManager.POST(urlString: APIManager.Mine.getCode, params: ["token": (user.token)!]) {(data, error) in
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                self.verifyField.aButton?.isEnabled = true
                self.verifyField.aButton?.endCount()
                return
            }
            self.verifyField.aButton?.isEnabled = false
            self.verifyField.aButton?.beginCount()

            Third.toast.message("验证码发送成功！")
        }
    }
    func cancelAction() {
        
        RequestManager.POST(urlString: APIManager.Mine.validno, params: ["token": user.token ?? "token 为空"]) {[unowned self] (data, error) in
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if self.user.role == .teacher || self.user.role == .teacherL {
                if self.user.nId != 0 {
                    //证明，已经有园，并且已经是老师
                    // 保存用户信息
                    LocaleSetting.saveLocalUser(userInfo: self.user)
                    //要去主页面了
                    UIApplication.shared.keyWindow?.rootViewController = CYJInitialViewController()
                }else
                {
                    self.dismiss(animated: true, completion: nil)
                }
            }else if self.user.role == .child{
                if self.user.nId != 0 {
                    //证明，已经有园，并且已经是老师
                    // 保存用户信息
                    LocaleSetting.saveLocalUser(userInfo: self.user)
                    //要去主页面了
                    UIApplication.shared.keyWindow?.rootViewController = CYJInitialViewController()
                }else
                {
                    self.dismiss(animated: true, completion: nil)
                }
            }else if self.user.role == .master {
                if self.user.nId != 0 {
                    //证明，已经有园，并且已经是老师
                    // 保存用户信息
                    LocaleSetting.saveLocalUser(userInfo: self.user)
                    //要去主页面了
                    UIApplication.shared.keyWindow?.rootViewController = CYJInitialViewController()
                }else
                {
                    self.dismiss(animated: true, completion: nil)
                }
            }else  if self.user.role == .noClass {
                //当， 进界面
                LocaleSetting.saveLocalUser(userInfo: self.user)
                //要去主页面了
                UIApplication.shared.keyWindow?.rootViewController = CYJInitialViewController()
                
            }else  if self.user.role == .noGarden {
                //当， 什么也不是的时候，去登陆
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func uploadAction() {
        let code = verifyField.text
        verifyField.endEditing(true)
        guard (code?.isVaildCode)! else {
            Third.toast.message("验证码不合法")
            return
        }
        
        RequestManager.POST(urlString: APIManager.Mine.valid, params: ["token": user.token ?? "token 为空", "validcode" : code! ]) { (data, error) in
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            if let dict = data as? NSDictionary { //如果是字典
                
                let verifyUser = JSONDeserializer<CYJUser>.deserializeFrom(dict: dict)
                
                if let verifyU = verifyUser {
                    let user = self.user
                    user?.nId = verifyU.nId
                    user?.cId = verifyU.cId
                    user?.babyStatus = verifyU.babyStatus
                    
                    LocaleSetting.saveLocalUser(userInfo: user!)
                    //要去主页面了
                    UIApplication.shared.keyWindow?.rootViewController = CYJInitialViewController()
                }else {
                    DLog("something wrong")
                }
            }
        }
    }
}
