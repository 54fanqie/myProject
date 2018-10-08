//
//  CYJRecordListCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/11.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import Kingfisher

class CYJRecordListCell: UITableViewCell {
    
    var role = (LocaleSetting.userInfo()?.role)!
    
    
    enum CellMode: String {
        case none = "reuseIdentifierWithNoneImageView"
        case one = "reuseIdentifierWithOneImageView"
        case two = "reuseIdentifierWithTwoImageView"
        case three = "reuseIdentifierWithThreeImageView"
        case four = "reuseIdentifierWithFourImageView"
        case video = "reuseIdentifierWithVideoImageView"
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
        imageView.image = #imageLiteral(resourceName: "default_one")
        return imageView
    }()
    lazy var imageViewTwo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = 201
        imageView.image = #imageLiteral(resourceName: "default_two")
        
        return imageView
    }()
    lazy var imageViewThree: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 202
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "default_threefour")
        
        return imageView
    }()
    lazy var imageViewFour: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 203
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "default_threefour")
        
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
    
    lazy var byLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 12)
        
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
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "icon_gray_trash"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(deletebuttonClicked), for: .touchUpInside)
        return button
    }()
    
    lazy var excellentImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "icon_red_jinghua")
        return imageView
    }()
    
    lazy var goodImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "list-zan")
        
        return imageView
    }()
    lazy var goodLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    //MARK: 园长专用
    lazy var readOverImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "icon_blue_read")
        return imageView
    }()
    
    //MARK: teacher 使用
    lazy var replayImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "list-pinglun")
        return imageView
    }()
    lazy var replayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    lazy var goodButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "icon_white_heart"), for: .selected)
        button.setImage(#imageLiteral(resourceName: "icon_gray_heart"), for: .normal)
        button.addTarget(self, action: #selector(goodbuttonClicked(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var separaLine: UILabel = {
        let label = UILabel()
        label.theme_backgroundColor = Theme.Color.line
        return label
    }()
    var imageSufix: String = "?imageMogr2/thumbnail/100x"

    //MARK: 设置数据源
    var listFrame: CYJRecordCellFrame! {
        didSet {
            layoutContainerView()
            
            dateLabel.attributedText = listFrame.record.attrDate
            
            userLabel.text = "记录幼儿：\(listFrame.record.babyName ?? "")"
            
            if listFrame.role == .master {
                byLabel.text = "by: \(listFrame.record.teacherName ?? "") (\(listFrame.record.cName ?? ""))"

            }else
            {
//                if listFrame.isOtherClass {
//                    byLabel.text = "by: (\(listFrame.record.cName ?? "")) \(listFrame.record.teacherName ?? "")"
//                }else{
                    byLabel.text = "by: \(listFrame.record.teacherName ?? "")"
//                }
                
            }
            
            contentLabel.text = listFrame.record.describe
            excellentImageView.isHidden = listFrame.record.isGood == 2
            
            readOverImageView.isHidden = listFrame.record.isMark == 1
            
            // 修改 删除按钮的显示
            if listFrame.role == .teacherL {
                if listFrame.record.teacherName == LocaleSetting.userInfo()?.realName {
                    deleteButton.isHidden = false
                }else {
                    deleteButton.isHidden = true
                }
            }else
            {
                deleteButton.isHidden = true
            }
            if listFrame.role == .teacher || listFrame.role == .master {
                if listFrame.isOtherClass == true{
                    deleteButton.isHidden = true
                }else{
                deleteButton.isHidden = false
                }
            }
            
            if let photo = listFrame.record.photo {
                switch photo.count {
                case 1:
                    let element = photo.first
                    imageViewOne.kf.setImage(with: URL(fragmentString: (element?.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_small"))
                case 2:
                    let element1 = photo.first
                    let element2 = photo.last
                    imageViewOne.kf.setImage(with: URL(fragmentString: (element1?.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_two"))
                    imageViewTwo.kf.setImage(with: URL(fragmentString: (element2?.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_two"))
                    
                case 3:
                    let element1 = photo[0]
                    let element2 = photo[1]
                    let element3 = photo[2]
                    
                    imageViewOne.kf.setImage(with: URL(fragmentString: (element1.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_two"))
                    imageViewTwo.kf.setImage(with: URL(fragmentString: (element2.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_one"))
                    imageViewThree.kf.setImage(with: URL(fragmentString: (element3.url)! + imageSufix) ,placeholder: #imageLiteral(resourceName: "default_one"))
                    
                case 4:
                    let element1 = photo[0]
                    let element2 = photo[1]
                    let element3 = photo[2]
                    let element4 = photo[3]
                    imageViewOne.kf.setImage(with: URL(fragmentString: (element1.url)! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_two"))
                    imageViewTwo.kf.setImage(with: URL(fragmentString: (element2.url)! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_two"))
                    imageViewThree.kf.setImage(with: URL(fragmentString: (element3.url)! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_two"))
                    imageViewFour.kf.setImage(with: URL(fragmentString: (element4.url)! + imageSufix) ,placeholder:  #imageLiteral(resourceName: "default_two"))
                    
                default:
                    break
                }
            }
            separaLine.frame = listFrame.separaLineFrame
            goodLabel.text = "\(listFrame.record.praiseNum)"
            replayLabel.text = "\(listFrame.record.commentNum)"
            
            goodButton.isSelected = listFrame.record.isPraised == 1
        }
    }
    
    var deleteActionHandler: ((_ cell: UITableViewCell)->Void)?
    var goodActionHandler: ((_ cell: UITableViewCell, _ sender: UIButton)->Void)?

    
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
    
    /// 为内部视图添加frame
    func layoutContainerView() {
        //MARK: Left part
        dateLabel.frame = listFrame.dateLabelFrame
        
        excellentImageView.frame = listFrame.excellentImageViewFrame
        //MARK: Right Part
        
        if role != .child {
            //展示user  20 here for delete button
            userLabel.frame = listFrame.userLabelFrame
            deleteButton.frame = listFrame.deleteButtonFrame
        }
        
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
        
        byLabel.frame = listFrame.byLabelFrame
        
        //Bottom
        if role == .teacher || role == .teacherL {
            
            goodImageView.frame = listFrame.goodImageViewFrame
            goodLabel.frame = listFrame.goodLabelFrame
            replayImageView.frame = listFrame.replyImageViewFrame
            replayLabel.frame = listFrame.replyLabelFrame
            
            readOverImageView.frame = listFrame.readOverImageViewFrame

        }else if role == .master {
            
            goodImageView.frame = listFrame.goodImageViewFrame
            goodLabel.frame = listFrame.goodLabelFrame
            readOverImageView.frame = listFrame.readOverImageViewFrame
        }else if role == .child {
            goodButton.frame = listFrame.goodButtonFrame
        }
    }
    
    
    /// 创建 内部视图
    func makeContainerView() {
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(excellentImageView)
        
        if role != .child {  //角色判断
            contentView.addSubview(userLabel)
        }
        if role == .teacher || role == .teacherL || role == .master {
            contentView.addSubview(deleteButton)
        }
        
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
        contentView.addSubview(byLabel)
        
        //Bottom
        if role == .teacher || role == .teacherL {
            contentView.addSubview(goodImageView)
            contentView.addSubview(goodLabel)
            
            contentView.addSubview(replayImageView)
            contentView.addSubview(replayLabel)
            contentView.addSubview(readOverImageView)

        }else if role == .master {
            contentView.addSubview(goodImageView)
            contentView.addSubview(goodLabel)
            
            contentView.addSubview(readOverImageView)
        }else if role == .child {
            contentView.addSubview(goodButton)
        }
//        contentView.addSubview(separaLine)
    }
    
    //TODO: Actions
    func deletebuttonClicked() {
        if let deleteAction = self.deleteActionHandler {
            deleteAction(self)
        }
    }
    
    func goodbuttonClicked(_ sender: UIButton) {
        
        if !sender.isSelected {
            if let good = self.goodActionHandler {
                good(self, sender)
            }
        }
    }
    
    func tapGuesture(guesture: UITapGestureRecognizer) {
        
    }
    
}
