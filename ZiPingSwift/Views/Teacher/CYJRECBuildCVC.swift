//
//  CYJRECBuildCVC.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CYJRECBuildCVC: UICollectionViewCell {

    static let CYJRECBuildCVCTime = "CYJRECBuildCVC_Time"
    static let CYJRECBuildCVCChild = "CYJRECBuildCVC_Child"
    static let CYJRECBuildCVCDescription = "CYJRECBuildCVC_Desc"

    
    @IBOutlet weak var childNameLabel: UILabel!
    
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeDetailLabel: UILabel!
    @IBOutlet weak var timeEditButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var timeEditOver: ((_ created :Date)->Void)?
    
    var textViewUpdating: ((_ text: String)->Void)?
    
    @IBAction func timeEditButtonAction(_ sender: Any) {
        

    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        
        if reuseIdentifier == CYJRECBuildCVC.CYJRECBuildCVCTime {
            self.childNameLabel.isHidden = true
            
            self.textView.isHidden = true
            self.placeholderLabel.isHidden = true
            
        }else if reuseIdentifier == CYJRECBuildCVC.CYJRECBuildCVCChild
        {
            timeEditButton.isHidden = true
            timeTitleLabel.isHidden = true
            timeDetailLabel.isHidden = true
            
            textView.isHidden = true
            placeholderLabel.isHidden = true
            self.childNameLabel.layer.cornerRadius = 10
            self.childNameLabel.layer.masksToBounds = true
        }else if reuseIdentifier == CYJRECBuildCVC.CYJRECBuildCVCDescription
        {
            childNameLabel.isHidden = true
            
            timeEditButton.isHidden = true
            timeTitleLabel.isHidden = true
            timeDetailLabel.isHidden = true
            
            textView.delegate = self
            
            let button = UIButton (frame: CGRect(x: 50, y: 5, width: Theme.Measure.screenWidth - 120, height: 34))
            button.setTitle(" 按住 进行语音录入", for: .normal)
            button.setImage(#imageLiteral(resourceName: "icon_voice"), for: .normal)
            button.setTitleColor(UIColor(hex6: 0x666666), for: .normal)
            button.setTitleColor(UIColor(hex6: 0x999999), for: .highlighted)

            button.backgroundColor = UIColor(hex6: 0xEDECED)
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
            
            button.addTarget(self, action: #selector(testAction), for: .touchUpInside)
            
            if #available(iOS 11, *) {
                CYJASRRecordor.share.actionButton = button
                textView.keyboardToolbar.titleBarButton = IQTitleBarButtonItem(customView: button)
            } else {
                // Fallback on earlier versions
                CYJASRRecordor.share.actionButton = button

                textView.keyboardToolbar.addSubview(button)
            }
            
            CYJASRRecordor.share.delegate = self
        }

    }
    
    @objc func testAction() {
        DLog("touch down")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        placeholderLabel.theme_textColor = Theme.Color.textColorlight
        
        self.timeEditButton.isEnabled = false
        
        self.timeEditButton.theme_setImage("Record.calenderEdit", forState: .normal)
        
    }

}

extension CYJRECBuildCVC : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            placeholderLabel.isHidden = true
            
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
            
        }else
        {
            placeholderLabel.isHidden = false
        }
//        DLog("听写能否激活textViewChange方法？")
        if let updating = self.textViewUpdating {
            updating(textView.text)
        }
    }
}
extension CYJRECBuildCVC: CYJASRRecordorDelegate {
    
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

