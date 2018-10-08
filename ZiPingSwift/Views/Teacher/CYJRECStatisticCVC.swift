//
//  CYJRECStatisticCVC.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/11.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECStatisticCVC: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    var level: Int = 0 {
        didSet{
            switch level {
            case 1:
                backView.backgroundColor = UIColor(hex6: 0xFE6134)
            case 2:
                backView.backgroundColor = UIColor(hex6: 0xFFFF67)
            case 3:
                backView.backgroundColor = UIColor(hex6: 0x66CC9A)
            default:
                backView.backgroundColor = UIColor.white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
