//
//  CYJThemeDisplayCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/7.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJThemeDisplayCell: UICollectionViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        background.layer.cornerRadius = 10
        background.layer.masksToBounds = true
        
    }

}
