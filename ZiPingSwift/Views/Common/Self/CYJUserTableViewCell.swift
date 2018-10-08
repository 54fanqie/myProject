//
//  CYJUserTableViewCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/23.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJUserTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var nextLabel: UILabel!
    
    var user: CYJUser? {
        didSet{
            
            photoImageView.kf.setImage(with: URL(fragmentString: user?.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

            nameLabel.text = user?.username
            descriptionLabel.text = user?.realName
            nextLabel.text = ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoImageView.layer.cornerRadius = 21.5
        photoImageView.layer.masksToBounds = true
        nameLabel.theme_textColor = Theme.Color.textColorDark
        descriptionLabel.theme_textColor = Theme.Color.textColorlight
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
