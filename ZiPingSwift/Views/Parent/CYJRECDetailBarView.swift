//
//  CYJRECDetailBarView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

class CYJRECDetailBarView: UIView {
    
    var lineView: UIView!
    var goodView: UIView!
    var goodButton: UIButton!
    var goodLabel: UILabel!
    
//    var textField: UITextField!
    var textView: UITextView!
    var sendButton: UIButton!
    var commentLabel: UILabel!
    
    var editingEnabled: Bool = false
    
    let maxHeight: Float = 120
    let minHeight: Float = 44
    
    var spaceHeight: CGFloat {
        return frame.height - CGFloat(minHeight)
    }
    lazy var firstFrame: CGRect = {
        return self.frame
    }()
    
    var isPraised: Bool = false {
        didSet{
            goodButton.isSelected = isPraised
            goodLabel.text = isPraised ? "已点赞" : "给老师点赞"
            
        }
    }
    var isCommented: Bool = false {
        didSet{
            if isCommented {
                textView.isHidden = true
                commentLabel.text = "已反馈给老师"
                commentLabel.isHidden = false
                sendButton.isHidden = true
            }else
            {
                textView.isHidden = false
                commentLabel.isHidden = false
                commentLabel.numberOfLines = 0
                commentLabel.text = "写点感想或者想说的话，\n仅能反馈一次哦"
                sendButton.isHidden = false
            }
        }
    }
    
    var goodActionHandler: ((_ sender: UIButton)->Void)?
    var sendActionHandler: ((_ text: String?)->Void)?
    
    deinit {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        IQKeyboardManager.sharedManager().enable = false

        theme_backgroundColor = Theme.Color.viewLightColor
        
        lineView = UIView(frame: CGRect(x: 0, y: -4, width: Theme.Measure.screenWidth, height: 4))
        lineView.theme_backgroundColor = Theme.Color.line
//        addSubview(lineView)
        
        goodView = UIView(frame: CGRect(x: 10, y: 0, width: 66, height: frame.height))
//        goodView.theme_backgroundColor = Theme.Color.ground
        addSubview(goodView)
        
        goodButton = UIButton(type: .custom)
        goodButton.frame = CGRect(x: (66-25)*0.5, y: 8, width: 25, height: 25)
        goodButton.setImage(#imageLiteral(resourceName: "icon_gray_heart"), for: .normal)
        goodButton.setImage(#imageLiteral(resourceName: "icon_white_heart"), for: .selected)
        goodButton.addTarget(self, action: #selector(goodButtonAction(_:)), for: .touchUpInside)
        goodView.addSubview(goodButton)
        
        goodLabel = UILabel(frame: CGRect(x: 0, y: 42 - 8, width: 66, height: 15))
        goodLabel.font = UIFont.systemFont(ofSize: 11)
        goodLabel.theme_textColor = Theme.Color.textColor
        goodLabel.text = "给老师点赞"
        goodLabel.textAlignment = .center
        goodView.addSubview(goodLabel)
        
        
        textView = UITextView(frame: CGRect(x: goodView.frame.maxX + 5, y: (frame.height - CGFloat(minHeight)) * 0.5, width: Theme.Measure.screenWidth - 96 - 50 - 8, height: CGFloat(minHeight)))
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.theme_backgroundColor = Theme.Color.ground
        textView.delegate = self
        
        addSubview(textView)

        sendButton = UIButton(type: .custom)
        sendButton.frame = CGRect(x: frame.width - 55 - 8, y: 8, width: 55, height: 45)
        sendButton.setTitle("发表", for: .normal)
        sendButton.layer.cornerRadius = 5;
        sendButton.layer.masksToBounds = true
        sendButton.theme_backgroundColor = Theme.Color.main
        sendButton.addTarget(self, action: #selector(sendButtonAction(_:)), for: .touchUpInside)
        addSubview(sendButton)
        
        commentLabel = UILabel(frame: textView.frame)
        commentLabel.font = UIFont.systemFont(ofSize: 14)
        commentLabel.theme_textColor = Theme.Color.textColor
        commentLabel.text = "已反馈给老师"
        commentLabel.textAlignment = .center
        addSubview(commentLabel)
     
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func goodButtonAction(_ sender: UIButton) {
        
        if self.editingEnabled {
            if sender.isSelected {
                return
            }else {
                if let good = self.goodActionHandler {
                    good(sender)
                }
            }
        }
    }
    func sendButtonAction(_ sender: UIButton) {

        if self.editingEnabled {
            if let send = self.sendActionHandler {
                send(textView.text)
            }
        }
    }
    func replaySuccess() {
        self.frame = firstFrame
        self.isCommented = true
        
        self.textView.endEditing(true)
    }
    
}

extension CYJRECDetailBarView: UITextViewDelegate {
    
    func keyboardWillChangeFrame(_ notify: Notification) {
        
        // 0.取出键盘动画的时间
        let duration = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        // 1.取得键盘最后的frame
        let  keyboardFrame = notify.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect
        // 2.计算控制器的view需要平移的距离
        let transformY = (keyboardFrame?.origin.y)! - Theme.Measure.screenHeight
        // 3.执行动画
        
        UIView.animate(withDuration: duration!) {
            self.transform = CGAffineTransform(translationX: 0, y: transformY)
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        print("location: \(range.location) length: \(range.length)")
        if range.length == 1 { //在删除东西 不受字数限制
            return true
        }
        //增加的时候，判断总长度，如果不满意的话，那就不让他输入
        return !(range.location + text.characters.count > 140)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 隐藏placeholder
        if textView.text.characters.count > 0 {
            commentLabel.isHidden = true
        }else {
            commentLabel.numberOfLines = 0
            commentLabel.text = "写点感想或者想说的话，\n仅能反馈一次哦"
            commentLabel.isHidden = false
        }
        
        //变大！！
        let textViewFrame = textView.frame
        let constraintSize = CGSize(width: textViewFrame.width, height: CGFloat(MAXFLOAT))
        var size = textView.sizeThatFits(constraintSize)
        if size.height <= CGFloat(minHeight) {
            size.height = CGFloat(fmaxf(Float(textViewFrame.size.height), minHeight))
            textView.isScrollEnabled = false
        }else {
            if size.height >= CGFloat(maxHeight) {
                size.height = CGFloat(maxHeight)
                textView.isScrollEnabled = true
            }else {
                textView.isScrollEnabled = false
            }
        }
        
        let fframe = CGRect(x: 0, y: firstFrame.minY - (size.height - CGFloat(minHeight)), width: frame.width, height: size.height + spaceHeight)
        self.frame = fframe
        textView.frame = CGRect(x: textViewFrame.origin.x, y: textViewFrame.origin.y, width: textViewFrame.size.width, height: size.height)
    }
    
    
}

