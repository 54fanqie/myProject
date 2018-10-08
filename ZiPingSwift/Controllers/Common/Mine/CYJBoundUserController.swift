//
//  CYJBoundUserController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/23.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJBoundUserController: KYBaseViewController {
    
    var accountField: KYInputField!
    var passwordField: KYInputField!
    var verifyField: KYInputField!

    var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "添加关联账号"
        accountField = KYInputField(hint: "手机号/账号", frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: view.frame.width, height: Theme.Measure.inputHeight))
        view.addSubview(accountField)
        
        passwordField = KYInputField(_passwordImage: nil, hint: "输入密码", frame: CGRect(x: 0, y: accountField.frame.maxY, width: view.frame.width, height: Theme.Measure.inputHeight))
        view.addSubview(passwordField)
        
//        verifyField = KYInputField(_verifierImage: nil, hint: "验证码", frame: CGRect(x: 0, y: passwordField.frame.maxY, width: view.frame.width, height: Theme.Measure.inputHeight))
//        verifyField.backgroundColor = UIColor.white
//        verifyField.aButton?.addTarget(self, action: #selector(getCodeAgain), for: UIControlEvents.touchUpInside)
//        view.addSubview(verifyField)
        
        addButton = UIButton(type: .custom)
        addButton.frame = CGRect(x: Theme.Measure.buttonLeft, y: passwordField.frame.maxY + 35, width: Theme.Measure.buttonWidth, height: 40)
        addButton.setTitle("添加关联账号", for: .normal)
        addButton.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        addButton.layer.cornerRadius = 20
        addButton.layer.masksToBounds = true
        addButton.layer.theme_borderColor = "Nav.barTintColor"
        addButton.theme_backgroundColor = Theme.Color.main
        addButton.layer.borderWidth = 0.5
        addButton.addTarget(self, action: #selector(addNewAccount), for: .touchUpInside)
        view.addSubview(addButton)
    }
    
//    func getCodeAgain() {
//
//
//        guard let account = accountField.text else {
//            Third.toast.message("请输入手机号/账号")
//            return
//        }
//
//        guard account.isVaildPhone else {
//            Third.toast.message("请检查手机号是否符合规范")
//            return
//        }
//
//        verifyField.aButton?.isEnabled = false
//
//        RequestManager.POST(urlString: APIManager.User.code, params: ["username" : account, "type": "1"])     { [unowned self] (data, error) in
//            //如果存在error
//            guard error == nil else {
//                Third.toast.message((error?.localizedDescription)!)
//                self.verifyField.aButton?.isEnabled = true
//
//                return
//            }
//            self.verifyField.aButton?.beginCount()
//            Third.toast.message("验证码发送成功！")
//        }
//    }
    
    func addNewAccount() {
        //FIXME: addNewAccount
        
        guard let account = accountField.text else {
            Third.toast.message("请输入手机号")
            return
        }
        
        guard account != LocaleSetting.userInfo()?.username else {
            Third.toast.message("您不能添加自己")
            return
        }
        
        guard let password = passwordField.text else {
            Third.toast.message("请输入您的密码")
            return
        }
//        guard let verifyCode = verifyField.text else {
//            Third.toast.message("验证码不能为空")
//            return
//        }
        
        guard account.isVaildPhone else {
            Third.toast.message("请检查手机号是否符合规范")
            return
        }
        guard password.isVaildPassword else {
            Third.toast.message("请检查密码是否符合规范")
            return
        }
//        guard verifyCode.isVaildCode else {
//            Third.toast.message("请检查验证码是否符合规范")
//            return
//        }
        
        let param: [String: Any] = ["username" : account, "password" : password,"token" : LocaleSetting.token]//, "code" : verifyCode]
        
        RequestManager.POST(urlString: APIManager.Mine.addnexus, params: param) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
