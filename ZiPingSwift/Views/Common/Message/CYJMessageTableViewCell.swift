//
//  CYJMessageTableViewCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/23.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var message: CYJMessage? {
        didSet {
            if message?.dataType == 3 {
                photoImageView.kf.setImage(with: URL(fragmentString: message?.avatar) ,placeholder: #imageLiteral(resourceName: "icon_system_default"))
                fromLabel.text = message?.realName
            }else{
                photoImageView.image = #imageLiteral(resourceName: "icon_system_default")
                fromLabel.text =  "系统消息" //message?.realName
            }
            
            //FIXME: 系统消息的时间去哪儿了
            timeLabel.text = String(format: "%@  %@", (message?.createtime?.toTimeStringMMDD())!,(message?.createtime?.toTimeStringHHmm())!)
            detailLabel.text = message?.content
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoImageView.layer.cornerRadius = 15
        photoImageView.layer.masksToBounds = true
        
        fromLabel.theme_textColor = Theme.Color.textColor
        timeLabel.theme_textColor = Theme.Color.textColorlight
        detailLabel.theme_textColor = Theme.Color.textColorDark
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
