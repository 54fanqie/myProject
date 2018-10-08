//
//  CYJButtonItem.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/22.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import SwiftTheme

class CYJButtonItem: UIButton{
    
    var borderColorNormal: ThemeCGColorPicker?
    var borderColorSelected: ThemeCGColorPicker?
    
    var backgroundColorNormal: ThemeColorPicker?
    var backgroundColorSelected: ThemeColorPicker?

    var borderWidth: CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    var cornerRadius: CGFloat = 0
    
    var completeHandler: ((_ sender: CYJButtonItem)->Void)?
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                if let normalBorderColor = borderColorNormal {
                    layer.theme_borderColor = normalBorderColor
                }
                if let bgc = backgroundColorNormal {
                    theme_backgroundColor = bgc
                }
            }else {
                if let selectedBorderColor = borderColorSelected {
                    layer.theme_borderColor = selectedBorderColor
                }
                if let bgc = backgroundColorSelected {
                    theme_backgroundColor = bgc
                }
            }
        }
    }
    
    init(title: String, complete: @escaping (_ sender: CYJButtonItem)->Void) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.completeHandler = complete
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonAction() {
        completeHandler?(self)
    }
}
