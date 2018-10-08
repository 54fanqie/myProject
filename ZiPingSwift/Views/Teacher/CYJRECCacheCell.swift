//
//  CYJRECCacheCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/12.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJRECCacheCell: UITableViewCell {
    
    enum CellMode: String {
        case none = "CYJRECCacheCellWithNoneImageView"
        case one = "CYJRECCacheCellWithOneImageView"
        case two = "CYJRECCacheCellWithTwoImageView"
        case three = "CYJRECCacheCellWithThreeImageView"
        case four = "CYJRECCacheCellWithFourImageView"
        case video = "CYJRECCacheCellWithVideoImageView"
    }
    
    lazy var imageViewContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var imageViewOne: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 200
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "default_small")
        return imageView
    }()
    lazy var imageViewTwo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = 201
        imageView.image = #imageLiteral(resourceName: "default_small")
        
        return imageView
    }()
    lazy var imageViewThree: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 202
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "default_small")
        
        return imageView
    }()
    lazy var imageViewFour: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 203
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "default_small")
        
        return imageView
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
        
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    //MARK:  园长和教师共有
    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "icon_gray_trash"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(actionClicked(_:)), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: CYJActionPassOnDeleagte?
    var imageSufix: String = "?imageMogr2/thumbnail/200x"
    
    //设置数据源
    var listFrame: CYJRECCacheCellFrame! {
        didSet {
            layoutContainerView()
            
            dateLabel.attributedText = listFrame.record.attrDate
            
            userLabel.text = "记录幼儿：\(listFrame.record.babyName ?? "")"
            contentLabel.text = listFrame.record.describe
            
            
            if let photo = listFrame.record.photo {
                switch photo.count {
                case 1:
                    let element = photo.first
                    imageViewOne.kf.setImage(with: URL(fragmentString: (element?.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_small"))
                case 2:
                    let element1 = photo.first
                    let element2 = photo.last
                    imageViewOne.kf.setImage(with: URL(fragmentString: (element1?.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_long"))
                    imageViewTwo.kf.setImage(with: URL(fragmentString: (element2?.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_long"))
//
                case 3:
                    let element1 = photo[0]
                    let element2 = photo[1]
                    let element3 = photo[2]
                    
                    imageViewOne.kf.setImage(with: URL(fragmentString: element1.url! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_long"))
                    imageViewTwo.kf.setImage(with: URL(fragmentString: element2.url! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_small"))
                    imageViewThree.kf.setImage(with: URL(fragmentString: element3.url! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_small"))
                    
                case 4:
                    let element1 = photo[0]
                    let element2 = photo[1]
                    let element3 = photo[2]
                    let element4 = photo[3]
                    imageViewOne.kf.setImage(with: URL(fragmentString: element1.url! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_long"))
                    imageViewTwo.kf.setImage(with: URL(fragmentString: element2.url! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_long"))
                    imageViewThree.kf.setImage(with: URL(fragmentString: element3.url! + imageSufix),placeholder:  #imageLiteral(resourceName: "default_long"))
                    imageViewFour.kf.setImage(with: URL(fragmentString: element4.url! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_long"))
//                    
                default:
                    break
                }
            }
//            listFrame.record.photo?.enumerated().forEach({ (offset: Int, element: CYJMedia) in
//                let imageView = contentView.viewWithTag(200 + offset) as? UIImageView
//
//                if let imageV = imageView {
//
//                    imageV.kf.setImage(with: URL(fragmentString: element.url) ,placeholder: #imageLiteral(resourceName: "default_image"))
//                }
//            })
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.theme_backgroundColor = Theme.Color.ground
        makeContainerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func layoutContainerView() {
        //MARK: Left part
        dateLabel.frame = listFrame.dateLabelFrame
        
        //MARK: Right Part
        //展示user  20 here for delete button
        userLabel.frame = listFrame.userLabelFrame
        actionButton.frame = listFrame.actionButtonFrame
        
        if reuseIdentifier == CellMode.none.rawValue { //没有图片，和视频
            contentLabel.frame = listFrame.contentLabelFrame
        }else{
            imageViewContainerView.frame = listFrame.imageViewContainerViewFrame
            
            
            switch reuseIdentifier! {
            case CellMode.one.rawValue,CellMode.video.rawValue:
                imageViewOne.frame = listFrame.firstImageViewFrame
            case CellMode.two.rawValue:
                imageViewOne.frame = listFrame.firstImageViewFrame
                imageViewTwo.frame = listFrame.secondImageViewFrame
            case CellMode.three.rawValue:
                imageViewOne.frame = listFrame.firstImageViewFrame
                imageViewTwo.frame = listFrame.secondImageViewFrame
                imageViewThree.frame = listFrame.thirdImageViewFrame
            case CellMode.four.rawValue:
                imageViewOne.frame = listFrame.firstImageViewFrame
                imageViewTwo.frame = listFrame.secondImageViewFrame
                imageViewThree.frame = listFrame.thirdImageViewFrame
                imageViewFour.frame = listFrame.forthImageViewFrame
            default:
                break
            }
            contentLabel.frame = listFrame.contentLabelFrame
            
            
        }
        
    }
    func makeContainerView() {
        
        contentView.addSubview(dateLabel)
        
            contentView.addSubview(userLabel)
            contentView.addSubview(actionButton)
        
        if reuseIdentifier == CellMode.none.rawValue { //没有图片，和视频
        }else
        {
            contentView.addSubview(imageViewContainerView)
            
            switch reuseIdentifier! {
            case CellMode.one.rawValue:
                imageViewContainerView.addSubview(imageViewOne)
            case CellMode.two.rawValue:
                imageViewContainerView.addSubview(imageViewOne)
                imageViewContainerView.addSubview(imageViewTwo)
            case CellMode.three.rawValue:
                imageViewContainerView.addSubview(imageViewOne)
                imageViewContainerView.addSubview(imageViewTwo)
                imageViewContainerView.addSubview(imageViewThree)
            case CellMode.four.rawValue:
                imageViewContainerView.addSubview(imageViewOne)
                imageViewContainerView.addSubview(imageViewTwo)
                imageViewContainerView.addSubview(imageViewThree)
                imageViewContainerView.addSubview(imageViewFour)
            case CellMode.video.rawValue:
                imageViewContainerView.addSubview(imageViewOne)
            default:
                break
            }
        }
        
        contentView.addSubview(contentLabel)
    }
    
    
    func tapGuesture(guesture: UITapGestureRecognizer) {
        
    }
    
    func actionClicked(_ sender: UIButton) {
        if let del = delegate {
            del.actionsPass(on: self)
        }
    }
    
}
