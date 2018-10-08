//
//  CYJRECDetailInfoCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/29.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJRECDetailInfoCell: UITableViewCell {
    
    lazy var imageViewContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var guestureRecognizer: UITapGestureRecognizer = {
        let tapG = UITapGestureRecognizer(target: self, action: #selector(tapGuesture(guesture:)))
        tapG.numberOfTapsRequired = 1
        tapG.numberOfTouchesRequired = 1
        
        return tapG
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "2016-18-22"
        return label
    }()
    
    lazy var toLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "新小红的成长记录"
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = ""
        return label
    }()
    
    lazy var byLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "by: 莉莉，大一班"
        return label
    }()
    
    lazy var excellentImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "icon_red_jinghua")
        return imageView
    }()
    
    lazy var goodImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit;
        imageView.image = #imageLiteral(resourceName: "icon_white_heart")
        
        return imageView
    }()
    lazy var goodLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.theme_backgroundColor = Theme.Color.ground
        makeContainerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageClickHandler: CYJImagesTapHandler!

    
    var infoFrame: CYJRECDetailCellFrame! {
        didSet {
            layoutContainerView()
           
            self.dateLabel.text = infoFrame.record.rTime
            self.toLabel.text = "\(infoFrame.record.babyName ?? "韩梅梅")的成长记录"
            self.contentLabel.text = infoFrame.record.describe
          
            self.byLabel.text = "by: \(infoFrame.record.teacherName ?? "--")"
            self.excellentImageView.isHidden = infoFrame.record.isGood == 2
            self.goodLabel.attributedText = infoFrame.record.thumbNameAttr
        }
    }
 
    func layoutContainerView() {
        dateLabel.frame = infoFrame.dateLabelFrame
        toLabel.frame = infoFrame.toLabelFrame
        excellentImageView.frame = infoFrame.excellentImageViewFrame
        contentLabel.frame = infoFrame.contentLabelFrame
        
        //先把image都移除
        imageViewContainerView.subviews.forEach { $0.removeFromSuperview() }
        imageViewContainerView.removeFromSuperview()
        if let photo = infoFrame.record.photo {
            
            if photo.first?.filetype == 2 {
                
                contentView.addSubview(imageViewContainerView)
                imageViewContainerView.frame = infoFrame.imageViewContainerViewFrame
                
                let imageViewContainer = CYJRECImageViewContainer(frame: imageViewContainerView.bounds)
                
                imageViewContainer.videoUrls = ((photo.first?.url)!, "播放地址未引入")
                
                let _ = imageViewContainer.configImageViewRects(imageCount: 1)
                
                imageViewContainer.makeImageViewByRects()
                imageViewContainer.imageClickHandler = imageClickHandler
                imageViewContainerView.addSubview(imageViewContainer)
                
            }else {
                contentView.addSubview(imageViewContainerView)
                imageViewContainerView.frame = infoFrame.imageViewContainerViewFrame
                
                let urls = infoFrame.record.photo?.map({ (media) -> String in
                    return media.url!
                })
                
                let imageViewContainer = CYJRECImageViewContainer(frame: imageViewContainerView.bounds)
                
                imageViewContainer.imageUrls = urls!
                
                let _ = imageViewContainer.configImageViewRects(imageCount: (urls?.count)!)
                
                imageViewContainer.makeImageViewByRects()
                imageViewContainer.imageClickHandler = imageClickHandler
                imageViewContainerView.addSubview(imageViewContainer)
            }
        }

        byLabel.frame = infoFrame.byLabelFrame
        goodImageView.frame = infoFrame.goodImageViewFrame
        goodLabel.frame = infoFrame.goodLabelFrame
    }
    
    
    func makeContainerView() {
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(toLabel)

        contentView.addSubview(excellentImageView)

        contentView.addSubview(contentLabel)
        contentView.addSubview(byLabel)
        
        if LocaleSetting.userInfo()?.role != .child {
            contentView.addSubview(goodImageView)
            contentView.addSubview(goodLabel)
        }
    }
    
    
    func tapGuesture(guesture: UITapGestureRecognizer) {
        
    }
    
}
