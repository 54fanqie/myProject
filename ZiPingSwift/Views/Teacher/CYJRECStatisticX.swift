//
//  CYJRECStatisticX.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/12.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECStatisticX: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //测试git服务
        var la = UILabel(frame: CGRect.zero)
        addSubview(la)
    }

}
