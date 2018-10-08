//
//  CYJRECBuildChildAddCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/26.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJRECBuildChildAddCell: UITableViewCell {

    
    
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var child: CYJChild? {
        didSet{
            photoImageView.kf.setImage(with: URL(fragmentString: child?.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

            nameLabel.text = child?.realName
        }
    }
    
    var isAdd: Bool = false{
        didSet{
//            let imageSelect = #imageLiteral(resourceName: "icon_black_true")
//            let imageNormal = #imageLiteral(resourceName: "icon_gray_true")
                statusButton.isSelected = isAdd
            
//            statusImageView.image = isAdd ? imageSelect : imageNormal
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusButton.theme_setImage("Selected.singleSelected", forState: .selected)
        statusButton.theme_setImage("Selected.singleNormal", forState: .normal)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
