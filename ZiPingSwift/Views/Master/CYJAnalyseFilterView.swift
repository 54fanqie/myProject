//
//  CYJAnalyseFilterView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/25.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJActionsView: UIView {
    
    var isFull: Bool = false
    var innerPadding: CGFloat = 40
    
    var actions : [UIButton] = [] {
        didSet{
            if isFull {
                var originX: CGFloat = 0
                let width = (containerView.frame.width - innerPadding * CGFloat(actions.count - 1)) / CGFloat(actions.count)
                actions.forEach { [unowned self] (sender) in
                    sender.frame = CGRect(x: originX, y: 0.5, width: width , height: frame.height - 0.5)
                    self.containerView.addSubview(sender)
                    
                    originX += (width + innerPadding)
                }
            }else
            {
                var originX: CGFloat = 0
                
                actions.forEach { [unowned self] (sender) in
                    guard let title = sender.title(for: .normal) else {
                        return
                    }
                    var titleWidth = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.black], context: nil).width
                    
                    if let image = sender.image(for: .normal) {
                        let imageWidth = image.size.width
                        
                        titleWidth += imageWidth
                    }
                    titleWidth += 20
                    if titleWidth + 20 < 80 {
                        titleWidth = 80
                    }
                    
                    sender.frame = CGRect(x: originX, y: (frame.height - 32) * 0.5, width: titleWidth , height: 32)
                    self.containerView.addSubview(sender)
                    
                    originX += (titleWidth + innerPadding)
                }
                
                let totalWidth = originX  - 15 // 最后面多加了一个15上面
                containerView.frame.origin = CGPoint(x: (frame.width - totalWidth) * 0.5, y: 0)
            }
        }
    }
    
    var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        theme_backgroundColor = Theme.Color.line
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(containerView)
    }

    func makeButtonDisabled() {
        actions.forEach { (btn) in
            btn.isEnabled = false
        }
    }
    func makeButtonEnabled() {
        actions.forEach { (btn) in
            btn.isEnabled = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CYJConditionView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    lazy var lineView: UIView = {
        let vv = UIView()
        vv.theme_backgroundColor = Theme.Color.line
        return vv
    }()
    
    var conditions: [CYJConditionButton] = []
    
    var title: String!
    var key: String!
    
    init(title: String, key: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 60))
        self.title = title
        self.key = key
        theme_backgroundColor = Theme.Color.ground

        
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(x: 15, y: 24)
        self.addSubview(titleLabel)
        
        lineView.frame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
        addSubview(lineView)
        
    }
    
    func addCondition(_ condition: CYJConditionButton) {
        
        let before = conditions.count
        
        condition.frame.origin = CGPoint(x: titleLabel.frame.maxX + 15 + (78.5 + 10) * CGFloat(before), y: 15)
        addSubview(condition)
        conditions.append(condition)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CYJConditionButton: UIButton {
    
    var title: String! {
        didSet{
            self.setTitle(title, for: .normal)
            
            let titleSize = self.titleLabel?.sizeThatFits(CGSize(width: 320, height: 21))
            
            // 如果文字变大，那么 整体变大
            if (titleSize?.width)! > CGFloat(50.0) {
                var rect = self.frame
                rect.size.width = (titleSize?.width)! + 28.5
                self.frame = rect
            }
            
            self.imagePosition(position: .right)
            
        }
    }
    var key: String!
    var completeHandler: ((_ sender: CYJConditionButton) -> Void)!
    
    
    init(title: String, key: String, complete: @escaping (_ sender: CYJConditionButton) -> Void) {
        
        self.title = title
        self.key = key
        self.completeHandler = complete
        super.init(frame: CGRect(x: 0, y: 0, width: 78.5, height: 32))

        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.setTitle(title, for: .normal)
        self.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        
        let titleSize = self.titleLabel?.sizeThatFits(CGSize(width: 320, height: 21))
        
        // 如果文字变大，那么 整体变大
        if (titleSize?.width)! > CGFloat(50.0) {
            self.frame = CGRect(x: 0, y: 0, width: (titleSize?.width)! + 28.5, height: 32)
        }
        
        self.setImage(#imageLiteral(resourceName: "icon_gray_arrow_down"), for: .normal)
        self.imagePosition(position: .right)
        
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor(hex6: 0xB5B5B5).cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonAction() {
        completeHandler(self)
    }
}


class CYJTimeConditionView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "记录时间:"
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = CYJFilterButton(title: "起始日期", complete: {[unowned self] (sender) in
            self.startHandler(sender)
        })
        button.filterButtonStyle = .nomal_whithColor_Style
        button.setTitle("起始日期", for: .normal)
        //FIXME: 给按钮设置两个图片
        return button
    }()
    lazy var lineView: UIView = {
        let vv = UIView()
        vv.theme_backgroundColor = Theme.Color.line
        return vv
    }()
    
    private lazy var toLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "TO"
        label.sizeToFit()
        
        return label
    }()
    
    lazy var endButton: UIButton = {
        let button = CYJFilterButton(title: "截止日期", complete: {[unowned self] (sender) in
            self.endHandler(sender)
        })
        button.filterButtonStyle = .nomal_whithColor_Style
        button.setTitle("截止日期", for: .normal)
        //FIXME: 给按钮设置两个图片
        return button
    }()
    
    var startHandler: ((_ sender: UIButton) -> Void)!
    var endHandler: ((_ sender: UIButton) -> Void)!


    init(title: String, start: @escaping ((_ sender: UIButton) -> Void), end: @escaping ((_ sender: UIButton) -> Void)) {
        super.init(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: 60))
        
        theme_backgroundColor = Theme.Color.ground
        
        startHandler = start
        endHandler = end
        titleLabel.text = title
        
        titleLabel.frame = CGRect(x: 15, y: 24, width: 70, height: 15)
        
        startButton.frame = CGRect(x: titleLabel.frame.maxX + 10, y: 15, width: 100, height: 32)
        var toFrame = toLabel.frame
        toFrame.origin = CGPoint(x: startButton.frame.maxX + 10, y: 24)
//        toLabel.frame.origin = CGPoint(x: startButton.frame.maxX + 10, y: 24)
        
        toLabel.frame = toFrame
        endButton.frame = CGRect(x: toLabel.frame.maxX + 10, y: 15, width: 100, height: 32)
        
        addSubview(titleLabel)
        addSubview(startButton)
        addSubview(toLabel)
        addSubview(endButton)
        
        lineView.frame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
        addSubview(lineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
