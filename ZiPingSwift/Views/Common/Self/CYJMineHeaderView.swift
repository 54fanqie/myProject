//
//  CYJMineHeaderView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/7.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

import UIKit

class CYJMineHeaderView: UIView {
    
    var role: CYJRole {
        return (LocaleSetting.userInfo()?.role)!
    }
    
    lazy var backgroundImageView: UIImageView = {
        
        let imageView = UIImageView()
//        imageView.image = #imageLiteral(resourceName: "bg_blue_cela")
        imageView.theme_image = "Mine.headerBackgroundImage"
        return imageView
    }()
    
    lazy var photoImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default_user")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var photoClickedHandler: ((_ photoImageView: UIImageView)->Void)?
    
    lazy var gardenLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = "Mine.headerTextColor"

        label.font = UIFont.systemFont(ofSize: 15)
        label.text = ""
        return label
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = "Mine.headerTextColor"
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 15)

        return label
    }()
    
    //MARK: teacher and child
    lazy var classLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = "Mine.headerTextColor"

        label.text = ""

        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    //MARK: teacher only
    lazy var excellentImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "icon_red_jinghua")
        return imageView
    }()
    lazy var excellent: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = "Mine.headerTextColor"
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "共有0条优秀记录"

        return label
    }()
    
    var user: CYJUser? {
        didSet{
            if let user = user {
                if let avater = user.avatar {
                    photoImageView.kf.setImage(with: URL(fragmentString: avater) ,placeholder: #imageLiteral(resourceName: "default_user"))

                    photoImageView.layer.cornerRadius = 25
                    photoImageView.layer.masksToBounds = true
                }
                
                nameLabel.text = user.realName
                gardenLabel.text = user.sName
                
            }
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundImageView.frame = bounds
        
        addSubview(backgroundImageView)
        addSubview(photoImageView)
        addSubview(gardenLabel)
        addSubview(nameLabel)

        photoImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(photoClicked))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        photoImageView.addGestureRecognizer(tap)
        
        photoImageView.frame = CGRect(x: 21.5 , y: 40, width: 52, height: 52)
        
        let photoImageViewX = photoImageView.frame.minX
        
        
        
        
        
        switch role {
        case .master:
            photoImageView.frame = CGRect(x: 21.5 , y: 52, width: 52, height: 52)
            nameLabel.frame = CGRect(x: photoImageView.frame.maxX + 15, y: photoImageView.frame.minY + 14, width: frame.width - photoImageView.frame.maxX - 20, height: 24)
            gardenLabel.frame = CGRect(x: photoImageViewX, y: photoImageView.frame.maxY + 15, width: frame.width - photoImageViewX, height: 19)
        case .teacher,.teacherL:
            nameLabel.frame = CGRect(x: photoImageView.frame.maxX + 15, y: photoImageView.frame.minY + 14, width: frame.width - photoImageView.frame.maxX - 20, height: 24)
            gardenLabel.frame = CGRect(x: photoImageViewX, y: photoImageView.frame.maxY + 15, width: frame.width - photoImageViewX, height: 19)
            addSubview(classLabel)
            addSubview(excellent)
            addSubview(excellentImageView)

            classLabel.frame = CGRect(x: photoImageViewX, y: gardenLabel.frame.maxY + 10, width: frame.width  , height: 13)
            excellent.frame = CGRect(x: photoImageViewX, y: classLabel.frame.maxY + 12, width: frame.width - photoImageViewX, height: 21)
            
        case .child:
            addSubview(classLabel)
            nameLabel.frame = CGRect(x: photoImageView.frame.maxX + 15, y: photoImageView.frame.minY + 14, width: frame.width - photoImageView.frame.maxX - 20, height: 24)
            gardenLabel.frame = CGRect(x: photoImageViewX, y: photoImageView.frame.maxY + 15, width: frame.width - photoImageViewX, height: 19)
            classLabel.frame = CGRect(x: photoImageViewX, y: gardenLabel.frame.maxY + 10, width: frame.width - photoImageViewX, height: 13)

        case .none,.noGarden,.noClass:
            break
    
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func photoClicked() {
        if let complete = photoClickedHandler {
            complete(self.photoImageView)
        }
    }
}
