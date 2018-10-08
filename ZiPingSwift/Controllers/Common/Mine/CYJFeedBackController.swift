//
//  CYJFeedBackController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/20.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJFeedBackController: KYBaseViewController {

    
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentView: UITextView!
    @IBOutlet weak var contractField: UITextField!
    @IBOutlet weak var placeholderView: UITextView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "意见反馈"
        self.placeholderView.text = " 请填写您的意见.."
        if Theme.Measure.isIphoneX {
            self.topSpace.constant = 72 + 24 
        }
        
        self.uploadButton.layer.theme_borderColor = "Nav.barTintColor"
        self.uploadButton.layer.borderWidth = 1
        self.uploadButton.layer.cornerRadius = self.uploadButton.frame.height * 0.5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadAction(_ sender: Any) {
        
        
        let title = titleField.text
        let content = contentView.text
        
        guard !(title?.isEmpty)! else {
            Third.toast.message("标题不能为空")
            return
        }
        guard !(content?.isEmpty)! else {
            Third.toast.message("内容不能为空")
            return
        }
        guard let contract = contractField.text else {
            Third.toast.message("联系方式能为空")
            return
        }
        guard (contract.isVaildPhone) || (contract.isVaildEmail) else {
            Third.toast.message("联系方式只能为手机号或邮箱")
            return
        }

        let param = ["token": LocaleSetting.token,
                     "title": title,
                     "content": content,
                     "contract" : contract]
        
        RequestManager.POST(urlString: APIManager.Mine.feedback, params: param as? [String : String]) { [weak self] (data, error) in
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            Third.toast.message("反馈成功")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension CYJFeedBackController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderView.text = textView.text.count > 0 ? "":"I'm a placeholder"
        
    }
    
}





