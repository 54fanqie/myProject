//
//  CYJNotificationCell.swift
//  ZiPingSwift
//
//  Created by 番茄 on 2017/12/10.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJNotificationCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var redIconLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLable.theme_textColor = Theme.Color.textColorDark
        titleLable.font = UIFont.systemFont(ofSize: 16)
        
        redIconLable.theme_backgroundColor = Theme.Color.main;
        redIconLable.layer.cornerRadius = 10;
        redIconLable.layer.masksToBounds = true
        redIconLable.theme_textColor = Theme.Color.ground
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
