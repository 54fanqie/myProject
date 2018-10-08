//
//  CYJResetPasswordController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/5/2.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJResetPasswordController: KYBaseViewController {
    
    var oldPassword: KYInputField!
    var newPassword1: KYInputField!
    var newPassword2: KYInputField!

    var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改密码"
        var topY: CGFloat = 64 + 35
        //input code here
        oldPassword = KYInputField(image: nil, hint: "请输入原密码", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        oldPassword.backgroundColor = UIColor.white
        view.addSubview(oldPassword)
        topY += 64
        
        newPassword1 = KYInputField(_passwordImage: nil, hint: "请输入新密码", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        newPassword1.backgroundColor = UIColor.white
        view.addSubview(newPassword1)
        topY += 64

        newPassword2 = KYInputField(_passwordImage: nil, hint: "确认密码", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        newPassword2.backgroundColor = UIColor.white
        view.addSubview(newPassword2)
        topY += 44 + 36

        uploadButton = UIButton(normal: "保存修改", frame: CGRect(x: Theme.Measure.buttonLeft, y: topY, width: Theme.Measure.buttonWidth, height: Theme.Measure.buttonHeight))
        uploadButton.addTarget(self, action: #selector(uploadAction), for: UIControlEvents.touchUpInside)
   
        view.addSubview(uploadButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //input code here
    }
}

//MARK: make UI
extension CYJResetPasswordController {
    
}
//MARK: click method
extension CYJResetPasswordController {
    
    func uploadAction() {
        //
        let oldPwd = oldPassword.text
        let newPwd1 = newPassword1.text
        let newPwd2 = newPassword2.text
        
        guard !(oldPwd?.isEmpty)! else {
            Third.toast.message("原密码不能为空")
            return
        }
        guard (oldPwd?.characters.count)! >= 6 else {
            Third.toast.message("原密码不能少于6位")
            return
        }
        guard !(newPwd1?.isEmpty)! else {
            Third.toast.message("新密码不能为空")
            return
        }
        guard (newPwd1?.characters.count)! >= 6 else {
            Third.toast.message("新密码不能少于6位")
            return
        }
        guard newPwd1 == newPwd2 else {
            Third.toast.message("两次密码不一致")
            return
        }

        let param = ["token": LocaleSetting.userInfo()?.token,
                     "pwdold": oldPwd,
                     "pwdnew": newPwd1,
                     "pwdnew1": newPwd2]
        
        RequestManager.POST(urlString: APIManager.Mine.modPwd, params: param as? [String : String]) { (data, error) in
            //
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            Third.toast.message("保存成功", hide: { 
                //
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}
