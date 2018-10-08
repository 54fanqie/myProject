//
//  ForgetPasswordNextController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/17.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJForgetPasswordEndController: KYBaseViewController {
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改密码"
        
        makeThirdView()
    }
    
    var verifiField: KYInputField?
    var passwordField1: KYInputField?
    var passwordField2: KYInputField?
    
    var sureButton: UIButton?
    
    func makeThirdView() {
        
        var topY: CGFloat = 64 + 50
        
        let desc = UILabel(frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: 60))
        desc.theme_textColor = Theme.Color.textColorlight
        desc.font = UIFont.systemFont(ofSize: 15)
        
        desc.numberOfLines = 0
        desc.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        desc.text = "验证码已经发送到：\(username!) ,若未收到短信，点击获取验证码重新获取"
        
        view.addSubview(desc)
        topY += 70
        
        verifiField = KYInputField(_verifierImage: nil, hint: "请输入验证码", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        verifiField?.backgroundColor = UIColor.white
        verifiField?.aButton?.addTarget(self, action: #selector(getCodeAgain), for: UIControlEvents.touchUpInside)
        verifiField?.aButton?.beginCount()
        view.addSubview(verifiField!)
        
        topY += (Theme.Measure.inputHeight + 10)

        
        passwordField1 = KYInputField(_passwordImage: nil, hint: "新密码(字母、数字或特殊符号)", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        passwordField1?.backgroundColor = UIColor.white
        passwordField1?.isSecureTextEntry = true
        view.addSubview(passwordField1!)
        
        topY += (Theme.Measure.inputHeight + 10)

        passwordField2 = KYInputField(_passwordImage: nil, hint: "确认密码", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        passwordField2?.backgroundColor = UIColor.white
        passwordField2?.isSecureTextEntry = true
        view.addSubview(passwordField2!)
        
        topY += (Theme.Measure.inputHeight + 35)

        sureButton = UIButton(normal: "提交", frame: CGRect(x: Theme.Measure.buttonLeft, y: topY, width: Theme.Measure.buttonWidth, height: Theme.Measure.buttonHeight)
        )

        sureButton?.addTarget(self, action: #selector(changePassword), for: UIControlEvents.touchUpInside)
        
        sureButton?.setTitle("保存修改", for: UIControlState.normal)
        
        view.addSubview(sureButton!)
    }
}

//MARK: 点击事件
extension CYJForgetPasswordEndController {
    
    func getCodeAgain() {
        let params = ["username": username!, "type": "1"]
        
        verifiField?.aButton?.isEnabled = false
        Third.toast.show {
            //
        }
        RequestManager.POST(urlString: APIManager.User.code, params: params , complete: { [weak self] (data, error) in
            //
            Third.toast.hide {
            }
            guard error == nil else {
                Third.toast.message("\(error?.localizedDescription ?? "发送失败")")
                self?.verifiField?.aButton?.isEnabled = true
                return
            }
            Third.toast.message("验证码已成功发送", hide: {
            })
            self?.verifiField?.aButton?.beginCount()
        })
    }
    
    func changePassword() {
        //
        let code = verifiField?.text
        let oldPwd = passwordField1?.text
        let newPwd = passwordField2?.text
        
        guard !(code?.isEmpty)! else {
            Third.toast.message("验证码不能为空")
            return
        }
        guard !(oldPwd?.isEmpty)! else {
            Third.toast.message("新密码不能为空")
            return
        }
        guard (oldPwd?.characters.count)! >= 6 && (oldPwd?.characters.count)! < 20 else {
            Third.toast.message("新密码长度不符")
            return
        }
        guard oldPwd == newPwd else {
            Third.toast.message("两次密码不一致")
            return
        }
        
        let param = ["code": code, "password": oldPwd, "password1": newPwd]
        
        RequestManager.POST(urlString: APIManager.User.modifyPwd, params: param as? [String : String]) { [weak self] (data, error) in
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }

            Third.toast.message("修改成功")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { [weak self] in
                //
                self?.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
}



