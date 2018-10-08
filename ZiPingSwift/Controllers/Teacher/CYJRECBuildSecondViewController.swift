//
//  CYJRECBuildSecondViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import IQKeyboardManagerSwift

class CYJRECBuildSecondViewController: UIViewController {
    
    var textView: UITextView!
    var placeholderTextView: UITextView!
    /// 整个界面通过recordParam 创建
    var recordParam : CYJNewRECParam {
        return CYJRECBuildHelper.default.recordParam
    }
    
    var IamChangedHandler: CYJCompleteHandler?
    
    var childIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.brown

        // Do any additional setup after loading the view.
        
        let inputFrame = CGRect(x: 15, y: 0, width: view.frame.width - 30, height: Theme.Measure.screenHeight - 64 - 58 - 8 - 44 - 64)
        
        placeholderTextView = UITextView(frame: inputFrame)
        placeholderTextView.textColor = UIColor(hex6: 0xD0D0D0)
        placeholderTextView.font = UIFont.systemFont(ofSize: 15)
        placeholderTextView.isUserInteractionEnabled = false
        placeholderTextView.text = "体现出哪些方面的发展？处于什么水平？幼儿表现背后的原因是什么？教师/家长可以怎样做？"
        view.addSubview(placeholderTextView)
        
        textView = UITextView(frame: inputFrame)
        textView.backgroundColor = UIColor.clear
        textView.theme_textColor = Theme.Color.textColorDark
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.delegate = self
        view.addSubview(textView)

        let button = UIButton (frame: CGRect(x: 50, y: 5, width: Theme.Measure.screenWidth - 120, height: 34))
        button.setTitle(" 按住 进行语音录入", for: .normal)
        button.setImage(#imageLiteral(resourceName: "icon_voice"), for: .normal)
        button.setTitleColor(UIColor(hex6: 0x666666), for: .normal)
        button.setTitleColor(UIColor(hex6: 0xA0A0A0), for: .highlighted)

        button.backgroundColor = UIColor(hex6: 0xEDECED)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        
        if #available(iOS 11, *) {
            CYJASRRecordor.share.actionButton = button
            textView.keyboardToolbar.titleBarButton = IQTitleBarButtonItem(customView: button)
        } else {
            // Fallback on earlier versions
            CYJASRRecordor.share.actionButton = button

            textView.keyboardToolbar.addSubview(button)
        }
        
        //设置初始的值
        let evaluate = recordParam.info[childIndex]
        if evaluate.content != nil, !(evaluate.content?.isEmpty)! {
            textView.text = evaluate.content!
            placeholderTextView.isHidden = true
            if let com = IamChangedHandler {
                com(true)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CYJRECBuildSecondViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        if textView.text.count > 0 {
            placeholderTextView.isHidden = true
            
            if textView.text.characters.count > 300 {
                //获得已输出字数与正输入字母数
                let selectRange = textView.markedTextRange
                //获取高亮部分 － 如果有联想词则解包成功
                if let selectRange = selectRange {
                    let position =  textView.position(from: (selectRange.start), offset: 0)
                    if (position != nil) {
                        return
                    }
                }
                let textContent = textView.text
                let textNum = textContent?.characters.count
                //截取300个字
                if textNum! > 300 {
                    let index = textContent?.index((textContent?.startIndex)!, offsetBy: 300)
                    let str = textContent?.substring(to: index!)
                    textView.text = str
                }
                Third.toast.message("字数超过限制")
            }
            
            
            if let com = IamChangedHandler {
                com(true)
            }
        }else
        {
            placeholderTextView.isHidden = false
            if let com = IamChangedHandler {
                com(false)
            }
        }
        
        let evaluate = self.recordParam.info[childIndex]
        evaluate.content = textView.text
        
    }
    // 根据响应，随时更改回调位置
    func textViewDidBeginEditing(_ textView: UITextView) {
        CYJASRRecordor.share.delegate = self
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        CYJASRRecordor.share.delegate = nil
    }
}
extension CYJRECBuildSecondViewController: CYJASRRecordorDelegate {
    
    func asrRecordorFinished(with text: String) {
        let range = textView.selectedRange
        var oldText = textView.text!
        
        let index = oldText.index(oldText.startIndex, offsetBy: range.location)
        
        oldText.insert(contentsOf: text, at: index)
        
        textView.text = oldText
        print("这里执行了多次？？？？？")
        textViewDidChange(textView)
    }
}
