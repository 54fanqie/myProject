//
//  CYJRECFilterView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/25.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

protocol CYJDropDownViewDelegate: class {
    
    func numberOfItemIn(dropdownView: CYJRECDropDownView) -> Int
    
    func dropDownView(dropdownView: CYJRECDropDownView, itemFor index: Int) -> CYJDropDownItem
    
    func dropDownView(dropdownView: CYJRECDropDownView, selectedViewFor index: Int) -> UIView
}

struct CYJDropDownItem {
    var text: String
    var key: String
}

class CYJDropDownButton: UIButton {
    
    func makeImageRight() {
        let imageWidth = imageView?.frame.width
        
        imageEdgeInsets = UIEdgeInsetsMake(0, (titleLabel?.frame.width)! + 4, 0, -(titleLabel?.frame.width)!)
        titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth!, 0, imageWidth!)
        
    }
}
class CYJRECDropDownView: UIView {
    
    //    var autoresizesWidth: Bool = true
    
    private let kDropDownButtonTag = 567
    private let kDropDownSelectedViewTag = 678
    
    private var _items: [CYJDropDownItem] = []
    
    weak var delegate: CYJDropDownViewDelegate?
    
    weak var contianerView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        guard let _ = delegate else {
            return
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reloadDropDownView() {
        for view in subviews {
            view.removeFromSuperview()
        }
        let count = delegate?.numberOfItemIn(dropdownView: self)
        
        let itemWidth = frame.width / CGFloat(count!)
        print(frame.height)
        
        for i in 0..<count! {
            
            let opItem = delegate?.dropDownView(dropdownView: self, itemFor: i)
            
            guard let item = opItem else {
                return
            }
            
            let btn = CYJDropDownButton(frame: CGRect(x: itemWidth * CGFloat(i), y: 0, width: itemWidth, height: frame.height))
            
            btn.tag = kDropDownButtonTag + i
            btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
            btn.setTitle( item.text, for: .normal)
            btn.setTitleColor(UIColor(hex6: 0xBABABA), for: .normal)
            btn.theme_setTitleColor(Theme.Color.main, forState: .selected)

            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setImage(#imageLiteral(resourceName: "icon_gray_arrow_down_small"), for: .normal)
            btn.setImage(#imageLiteral(resourceName: "icon_red_arrow_up"), for: .selected)
//            btn.theme_setImage("Record.arrowDown", forState: .normal)
//            btn.theme_setImage("Record.arrowUp", forState: .selected)
            
            btn.makeImageRight()
            addSubview(btn)
        }
    }
    
    func setTitleForItem(title: String, at index: Int) {
        guard let btn = self.viewWithTag(kDropDownButtonTag + index) as? CYJDropDownButton else {
            return
        }
        btn.setTitle(title, for: .normal)
        //调用方法，让按钮适应文字
        btn.makeImageRight()

    }
    
    @objc func btnClicked(sender: UIButton) {
        print("btn: \(sender.tag - kDropDownButtonTag)")

        showSelectView(sender.tag)
    }
    
    //    var selectView: UIView?
    
    var selectViewIndex: Int = 0
    var selectViewContainerView = [UIView]()
    
    func showSelectView(_ index: Int) {
        
        guard let fatherView = contianerView else {
            return
        }
        
        if selectViewIndex == index { //同一个
            let btn = self.viewWithTag(selectViewIndex) as? UIButton
            btn?.isSelected = !(btn?.isSelected)!
            dismissSelected(animated: false)
        }else
        {

            if fatherView.viewWithTag(selectViewIndex) != nil {
                let btn = self.viewWithTag(selectViewIndex) as? UIButton
                btn?.isSelected = !(btn?.isSelected)!
                print("这个是之前的--存在")
                dismissSelected(animated: false)
            }
            let rectToView = self.convert(self.frame, to: fatherView)
            
            let sender = self.viewWithTag(index) as? UIButton
            sender?.isSelected = !(sender?.isSelected)!
            
            let selectView = UIView(frame: CGRect(x: 0, y: rectToView.maxY, width: frame.width, height: fatherView.frame.height - rectToView.maxY))
            selectView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            selectView.tag = kDropDownSelectedViewTag + index
            
            selectViewIndex = index
            fatherView.addSubview(selectView)
            let contentSelectView = delegate?.dropDownView(dropdownView: self, selectedViewFor: index - kDropDownButtonTag)
            
            selectView.addSubview(contentSelectView!)
            selectView.layer.masksToBounds = true
            
            let transition = CATransition()
            transition.duration = 0.336;//时间
            transition.type = kCATransitionPush;//动画的效果
            transition.subtype = kCATransitionFromBottom;//动画的目的地
            
            contentSelectView?.layer.add(transition, forKey: "show")
            
//            let tap = UITapGestureRecognizer(target: self, action: #selector(tapClicked(tap:)))
//            tap.numberOfTapsRequired = 1
//            tap.numberOfTouchesRequired = 1
//
//            selectView.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapClicked(tap: UITapGestureRecognizer) {
        
        dismissSelected(animated: false)
    }
    
    func dismissSelected(animated: Bool){
        
        guard let fatherView = contianerView else {
            return
        }
        let selectView = fatherView.viewWithTag(kDropDownSelectedViewTag + selectViewIndex)
        if let selectedButton = self.viewWithTag(selectViewIndex) as? UIButton {
            
            selectedButton.isSelected = false
        }
        selectViewIndex = 0
        
        guard let dele = delegate else {
            return
        }
        print(dele)
        selectView?.frame = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: 0)
        
        selectView?.removeFromSuperview()
    }
}
