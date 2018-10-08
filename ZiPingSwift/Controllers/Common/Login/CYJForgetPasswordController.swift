//
//  CYJForgetPasswordController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/17.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON



class CYJForgetPasswordController: KYBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "忘记密码"
        
        makeUI()
    }
    
    var accountField: KYInputField!
    var getAcceptButton: UIButton!
    
}

//MARK: UI
extension CYJForgetPasswordController {
    
    /// UI
    func makeUI() {
        
        let topY: CGFloat = 30 + 64
        
        accountField = KYInputField(image: nil, hint: "请输入登录账号", frame: CGRect(x: Theme.Measure.inputLeft, y: topY, width: Theme.Measure.inputWidth, height: Theme.Measure.inputHeight))
        
        accountField.backgroundColor = UIColor.white
        view.addSubview(accountField)
        
        getAcceptButton = UIButton(normal: "下一步", frame: CGRect(x: Theme.Measure.buttonLeft, y: accountField.frame.maxY + 38, width: Theme.Measure.buttonWidth, height: Theme.Measure.buttonHeight)
        )
        getAcceptButton.addTarget(self, action: #selector(getAccept), for: UIControlEvents.touchUpInside)
    
        view.addSubview(getAcceptButton)
        
    }
}

extension CYJForgetPasswordController
{
    func getAccept() {
        //
        DLog("\(getAccept)")
        //根据当前时第几步，确定事件
        
        accountField.resignFirstResponder()
        
        let account = accountField.text
        
        guard (account?.characters.count)! > 0 else {
            Third.toast.message("用户名不能为空")
            return
        }
        guard (account?.isVaildPhone)! else {
            Third.toast.message("手机号格式不正确")
            return
        }

        Third.toast.show { [unowned self] in
            RequestManager.POST(urlString: APIManager.User.code, params: ["username" : account!, "type": "1"], complete: { [weak self] (data, error) in
                Third.toast.hide {
                    //
                }
                if !(error != nil) {
                    DispatchQueue.main.async { [weak self] in
                        //创建第二步的界面
                        let next = CYJForgetPasswordEndController()
                        next.username = account
                        self?.navigationController?.pushViewController(next, animated: true)
                    }
                }else
                {
                    Third.toast.message((error?.localizedDescription)!)
                }
            })
        }
    }
}
