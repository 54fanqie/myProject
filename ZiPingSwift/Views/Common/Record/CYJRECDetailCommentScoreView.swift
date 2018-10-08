//
//  CYJRECDetailCommentScoreView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/29.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


class CYJRECDetailCommentScoreView: UIView {
    lazy var  arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"czjl-info-ic.png")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "2016-18-22"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex6: 0x955E2E)
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "2016-18-22"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(arrowImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
