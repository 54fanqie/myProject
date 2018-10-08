//
//  CYJInputViewOutletController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/31.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


class CYJInputViewOutletController: KYBaseViewController {
    
    var textView: KYTextView!
    
    var placeholder: String?
    
    var complete: ((_ inoutController: CYJInputViewOutletController, _ string: String) -> Void)?
    
    var uploadButton: UIButton!
    
    var initialString: String?
    
    lazy var isTime: Bool = {
        return self.title == "出生日期"
    }()
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - title: 页面标题
    ///   - placeholder: 输入框的placeHolder
    ///   - actionHandler: 点击完成的方法，完成后，需要让页面消失
    init(title: String, placeholder: String?, actionHandler: ((_ inoutController: CYJInputViewOutletController, _ string: String) -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.placeholder = placeholder
        self.complete = actionHandler
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView = KYTextView(frame: CGRect(x: 15, y: 64, width: view.frame.width - 30, height: 150))
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.theme_textColor = Theme.Color.textColorDark
        textView.placeholder = self.placeholder
        textView.maximumLength = 140
        textView.text = initialString
        view.addSubview(textView)
        
        //        textField = UITextField(frame: CGRect(x: 15, y: 64, width: view.frame.width - 30, height: 50))
        //        textField.font = UIFont.systemFont(ofSize: 15)
        //        textField.theme_textColor = Theme.Color.textColorDark
        //        textField.placeholder = self.placeholder
        //        textField.delegate = self
        //        textField.text = initialString
        //
        //        view.addSubview(textField)
        
        uploadButton = UIButton(frame: CGRect(x: view.frame.width * 0.25, y: textView.frame.maxY + 30, width: view.frame.width * 0.5, height: 35))
        uploadButton.theme_backgroundColor = Theme.Color.main
        uploadButton.setTitle("确定", for: UIControlState.normal)
        uploadButton.theme_setTitleColor("Nav.barTextColor", forState: .normal)
        
        uploadButton.addTarget(self, action: #selector(uploadSelected), for: UIControlEvents.touchUpInside)
        uploadButton.layer.cornerRadius = 5
        uploadButton.layer.masksToBounds = true
        
        view.addSubview(uploadButton)
        
    }
    
    func uploadSelected() {
        
        if let text = textView.text {
            guard !text.isEmpty else{
                Third.toast.message("\(self.title ?? "输入的内容") 不能为空")
                return
            }
            if let click = complete {
                click(self,text)
            }
        }
    }
}
