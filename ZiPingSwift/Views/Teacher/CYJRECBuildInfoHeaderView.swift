//
//  CYJRECBuildInfoHeaderView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJRECBuildInfoHeaderView: UICollectionReusableView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColorlight
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.frame = CGRect(x: 15, y: 0, width: 300, height: frame.height)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CYJRECBuildChildFooterView: UICollectionReusableView {
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("+ 选择幼儿", for: .normal)
        button.theme_setTitleColor(Theme.Color.main, forState: .normal)
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.theme_borderColor = "Nav.barTintColor"
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 4
        return button
    }()
    
    var addActionHandler: (()->Void)!
    var lineView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addButton.frame = CGRect(x: (frame.width - 120) * 0.5, y: 10, width: 120, height: 32)
        addSubview(addButton)
        addButton.theme_backgroundColor = Theme.Color.TabMain

        lineView = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
        lineView.theme_backgroundColor = Theme.Color.line
        addSubview(lineView)
        
    }
    func addButtonAction() {
        addActionHandler()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CYJRECBuildLineHeaderView: UICollectionReusableView {
    
    var lineView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineView = UIView(frame: bounds)
        lineView.theme_backgroundColor = Theme.Color.line
        addSubview(lineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class CYJRECBuildLineFooterView: UICollectionReusableView {
    
    var lineView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineView = UIView(frame: bounds)
        lineView.theme_backgroundColor = Theme.Color.line
        addSubview(lineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

