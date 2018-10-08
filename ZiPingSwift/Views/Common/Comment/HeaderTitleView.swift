//
//  HeaderTitleView.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/8/9.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit
class TitleView: UIView {
    var typeLab: UILabel!
    var line: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initial()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //初始化属性配置
    func initial(){
        typeLab = UILabel();
        typeLab?.text = "120"
        typeLab?.theme_textColor = Theme.Color.main
        typeLab?.font = UIFont.systemFont(ofSize: 12)
        typeLab?.textAlignment = .center
        typeLab.numberOfLines = 0
        self.addSubview(typeLab!)
        
        typeLab?.snp.makeConstraints({ (make)in
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.centerY.equalTo(self).offset(0)
        })
        
        line = UILabel();
        line.theme_backgroundColor = Theme.Color.line
        self.addSubview(line)
        
        line?.snp.makeConstraints({ (make)in
            make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.width.equalTo(1)
        })
    }
    
}

class HeaderTitleView: UIView {
    
    
    var backView: UIView!
    var typeData = NSArray()
    {
        didSet {
            for index in 0..<typeData.count {
                print(index)
                let fw = (Theme.Measure.screenWidth - 129)  / CGFloat(typeData.count)
                let vi = TitleView.init(frame: CGRect(x: fw * CGFloat(index), y: 0, width: fw , height: 46));
                let  name = typeData[index] as! String
                vi.typeLab.text = name
                backView.addSubview(vi)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let xibView =  awakeFromNib(frame: frame)
        self.addSubview(xibView)
        
        backView = UIView()
        backView.backgroundColor = UIColor.clear
        self.addSubview(backView)
        backView?.snp.makeConstraints({ (make)in
            make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.left.equalTo(self).offset(129)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // load view from xib
    //加载xib
    func awakeFromNib(frame: CGRect)-> UIView{
        let xibView = Bundle.main.loadNibNamed("HeaderTitleView", owner: self, options: nil)?.last as! UIView
        xibView.frame =  CGRect(x: 0, y: 0, width: frame.width, height: frame.height);
        return xibView
    }
    
}
