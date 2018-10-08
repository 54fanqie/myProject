//
//  CYJAddBabyViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/27.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJAddBabyViewController: KYBaseViewController {

    
    var accountField:   KYInputField!
    var nameField:  KYInputField!
    var sexField:   KYInputField!
    var birthField: KYInputField!
    var addChildButton : UIButton!
    var completeHandler: CYJCompleteHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "添加幼儿"
        
        
        // Do any additional setup after loading the view.
        accountField = KYInputField(hint: "手机号/账号", frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: Theme.Measure.screenWidth, height: Theme.Measure.inputHeight))
        
        nameField = KYInputField(hint: "姓名", frame: CGRect(x: 0, y: accountField.frame.maxY, width: Theme.Measure.screenWidth, height: Theme.Measure.inputHeight))

        sexField = KYInputField(hint: "性别", frame: CGRect(x: 0, y: nameField.frame.maxY, width: Theme.Measure.screenWidth, height: Theme.Measure.inputHeight))
        sexField.delegate = self
        
        birthField = KYInputField(hint: "生日", frame: CGRect(x: 0, y: sexField.frame.maxY, width: Theme.Measure.screenWidth, height: Theme.Measure.inputHeight))
        birthField.delegate = self
        
        
        addChildButton = UIButton(frame: CGRect(x: (view.frame.width - 160) * 0.5 ,y: birthField.frame.maxY + 60,width : 160 , height : 40))
        addChildButton.theme_backgroundColor = Theme.Color.main;
        addChildButton?.addTarget(self, action: #selector(upload), for: .touchUpInside)
        addChildButton.setTitle("添加", for: .normal)
        addChildButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        addChildButton.layer.cornerRadius = 20;
        addChildButton.layer.masksToBounds = true
        
        
        
        view.addSubview(accountField)
        view.addSubview(nameField)
        view.addSubview(sexField)
        view.addSubview(birthField)
        view.addSubview(addChildButton)
    }

    func upload() {
        
        
         //    Y    真实姓名
        let sex = sexField.text == "男" ? 1 : 2  // Y    1男 2女
       let birth =  birthField.text //  Y
        
        guard let username = accountField.text else {
            Third.toast.message("账号不能为空")
            return
        }

        guard (username.isVaildPhone) else {
            Third.toast.message("账号必须是手机号")
            return
        }
        guard let realName = nameField.text else {
            Third.toast.message("真实姓名不能为空")
            return
        }
        guard realName.isVaildRealName else {
            Third.toast.message("姓名只能为汉字或字母")
            return
        }
        guard !(birth?.isEmpty)! else {
            Third.toast.message("生日不能为空")
            return
        }
        
        let param = ["username": username,
            "realName" :  realName,
            "sex" :  sex,
            "birth" :  birth!,
            "token": LocaleSetting.token] as [String : Any]
        
        RequestManager.POST(urlString: APIManager.Baby.add, params: param) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            if let handler = self.completeHandler {
                handler(nil)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CYJAddBabyViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == sexField {
            self.view.endEditing(true)
            //FIXME: 去选择性别
            let jobArr = ["男", "女"]
            var options = [CYJOption]()
            for i in 1...2 {
                let option = CYJOption(title: jobArr[i - 1], opId: i)
                options.append(option)
            }
            
            let optionController = CYJOptionsSelectedController(currentIndex: 0, options: options) { (op) in
                print("\(op.title)")
                self.sexField.text = op.title
            }
            optionController.title = "性别"
            navigationController?.pushViewController(optionController, animated: true)
            return false
        }
        if textField == birthField {
            self.view.endEditing(true)

            //FIXME: 去选择生日
            let datePicker = KYDatePickerController(currentDate: Date(timeIntervalSinceNow: 0), minimumDate: Date(timeIntervalSince1970: 0), maximumDate: Date(timeIntervalSinceNow: 0), completeHandler: { [unowned self]  (selectedDate) in
                self.birthField.text = selectedDate.stringWithYMD()
            })
            let halfContainer = KYHalfPresentationController(presentedViewController: datePicker, presenting: self)
            datePicker.transitioningDelegate = halfContainer;
            
            self.present(datePicker, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
}
