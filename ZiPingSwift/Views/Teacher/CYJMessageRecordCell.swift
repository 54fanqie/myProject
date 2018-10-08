//
//  CYJMessageCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJMessageRecordCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var recordImageView: UIImageView!
    @IBOutlet weak var recordDescLabel: UILabel!
    @IBOutlet weak var recordDescLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var recordBackgroundView: UIView!
    
    
    var message: CYJMessage? {
        didSet {
            
            photoImageView.kf.setImage(with: URL(fragmentString: message?.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

            nameLabel.text = message?.realName
            contentLabel.text = message?.content
            
            //
            if (message?.dataImg?.isEmpty)! {
                //没有图片，那么把文字提前
                recordDescLeadingConstaint.constant = 8
                recordImageView.isHidden = true
                
            }else
            {
                recordImageView.isHidden = false

                recordDescLeadingConstaint.constant = 50
                recordImageView.kf.setImage(with: URL(fragmentString: message?.dataImg) ,placeholder: #imageLiteral(resourceName: "default_threefour"))
            }
            
            createdLabel.text = message?.createtime?.toTimeStringMMDD()
            //FIXME: 创建时间去哪儿了
            recordDescLabel.text = message?.dataContent
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photoImageView.image = #imageLiteral(resourceName: "default_user")
        photoImageView.layer.cornerRadius = 21.5
        photoImageView.layer.masksToBounds = true
        
        nameLabel.theme_textColor = Theme.Color.textColor
        createdLabel.theme_textColor = Theme.Color.textColorlight
        contentLabel.theme_textColor = Theme.Color.textColorDark
        
        recordDescLabel.theme_textColor = Theme.Color.textColorDark
        recordBackgroundView.theme_backgroundColor = Theme.Color.TabMain
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
