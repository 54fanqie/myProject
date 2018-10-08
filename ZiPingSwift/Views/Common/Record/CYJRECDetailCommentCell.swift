//
//  CYJDetailCommentCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/29.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation



class CYJRECDetailCommentCell: UITableViewCell {
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22.5
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "俄共"
        return label
    }()
    
    lazy var scoreView: UIView = {
        let view = UIView()
//        view.layer.borderColor = UIColor(hex6: 0xE3E3E3).cgColor
//        view.layer.borderWidth = 0.5
        
        return view
    }()
    lazy var scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.main
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "评分"
        return label
    }()
    lazy var scoreTitleBackView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Theme.Color.TabMain
        return view
    }()
    
    lazy var scoreEmptyLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 11, y: 25 + 8, width:200, height: 21)
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "暂未设置评分"
        return label
    }()
    
    let kScoreViewTag: Int = 996
    
    var scoreOptionViews: [UIView] = []
    
    lazy var commentView: UIView = {
        let view = UIView()
//        view.layer.borderColor = UIColor(hex6: 0xE3E3E3).cgColor
//        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var commentTitleLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.main
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "评语"
        return label
    }()
    lazy var commentTitleBackView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Theme.Color.TabMain
        
        return view
    }()
    lazy var commentDetailLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "asdasdasdasd"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var replayView: UIView = {
        let view = UIView()
//        view.layer.borderColor = UIColor(hex6: 0xE3E3E3).cgColor
//        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var replayTitleLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.main
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "家长反馈"
        return label
    }()
    lazy var replayTitleBackView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Theme.Color.TabMain
        
        return view
    }()
    lazy var replayNameLabel
        : UILabel = {
            let label = UILabel()
            label.theme_textColor = Theme.Color.textColorlight
            label.font = UIFont.systemFont(ofSize: 13)
            label.text = "家长    2017-9-10"
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            return label
    }()
    lazy var replayDetailLabel
        : UILabel = {
            let label = UILabel()
            label.theme_textColor = Theme.Color.textColorDark
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = "好，很好，非常好"
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            return label
    }()
    
    lazy var replayButton: UIButton = {
        let button = UIButton(type: .custom)
        button.theme_setTitleColor(Theme.Color.main, forState: .normal)
        button.setTitle("回复", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(replayButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    lazy var teacherReplayTitleLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColorlight
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "教师回复："
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var teacherReplayDetailLabel
        : UILabel = {
            let label = UILabel()
            label.theme_textColor = Theme.Color.textColorDark
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = "好，很好，非常好"
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            return label
    }()
    
    var evaluate: CYJRecordEvaluate? {
        return calFrame?.evaluate
    }
    var ownerId: Int?
    
    var calFrame: CYJEvaluateForRecordFrame! {
        didSet{
            
            makeContainerView()
            
            layoutContainerView()
        }
    }
    
    var replayHandler: ((_ cell: CYJRECDetailCommentCell)->Void)?
    
    func makeContainerView() {
        
        for view in self.scoreView.subviews {
            view.removeFromSuperview()
        }
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        contentView.addSubview(photoImageView)
        contentView.addSubview(nameLabel)
        
        photoImageView.kf.setImage(with: URL(fragmentString: evaluate?.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

        nameLabel.text = evaluate?.realName
        
        if (evaluate?.quota?.count)! > 0 {
            contentView.addSubview(scoreView)
            scoreView.addSubview(scoreTitleBackView)
            scoreView.addSubview(scoreTitleLabel)
            
            for i in 0..<(evaluate?.quota?.count)! {
                if let quota = evaluate?.quota?[i] {
                    let fieldView = CYJRECDetailCommentScoreView()
                    fieldView.tag = kScoreViewTag + i
                    
                    //设置数据
                    fieldView.titleLabel.text = quota.qTitle
                    fieldView.detailLabel.text = quota.lName
                    scoreView.addSubview(fieldView)
                }
            }
        }else
        {
            //显示 未评分
            contentView.addSubview(scoreView)
            scoreView.addSubview(scoreTitleBackView)
            scoreView.addSubview(scoreTitleLabel)
            scoreView.addSubview(scoreEmptyLabel)
        }
        
        if let content = evaluate?.formContent {
            contentView.addSubview(commentView)
            
            commentView.addSubview(commentTitleBackView)
            commentView.addSubview(commentTitleLabel)
            commentView.addSubview(commentDetailLabel)
            
            commentDetailLabel.text = content
        }
        
        if let commentContent = evaluate?.comment?.contentAttr {
            //存在comment
            contentView.addSubview(replayView)
            replayView.addSubview(replayTitleBackView)
            replayView.addSubview(replayTitleLabel)
            replayView.addSubview(replayNameLabel)
            replayView.addSubview(replayDetailLabel)
            
            replayNameLabel.text = "家长" + "    " +  ((evaluate?.comment?.createtime?.toTimeStringyyyyMMDD()) ?? "")
            
            replayDetailLabel.attributedText = commentContent
            
            if let _ = evaluate?.comment?.reply {
                print("这里添加")

                replayView.addSubview(teacherReplayTitleLabel)
//                replayView.addSubview(teacherReplayDetailLabel)
                teacherReplayTitleLabel.attributedText = evaluate?.comment?.replayAttr
                
                // 如果存在回复按钮，移除
                if let _ = replayButton.superview {
                    superview?.removeFromSuperview()
                }
            }else {
                //FIXME: 区分是不是自己发布的成长记录，只有自己发布的成长记录才可以回复
                if let _ = evaluate?.comment?.content {
                    //存在学生反馈
                    if LocaleSetting.userInfo()?.uId == ownerId {
                        replayView.addSubview(replayButton)
                    }
                }
                
//                replayView.addSubview(replayButton)
            }
        }
    }
    
    func layoutContainerView() {
        photoImageView.frame = CGRect(x: 15, y: 15, width: 45, height: 45)
        photoImageView.backgroundColor = UIColor.purple
        nameLabel.frame = CGRect(x: 76, y: 25, width: 200, height: 15)
        
        if calFrame.scoreFrames.count > 0 {
            scoreView.frame = calFrame.scoreViewFrame
            scoreTitleLabel.frame = CGRect(x: 11, y: 6, width: 100, height: 13)
            scoreTitleBackView.frame = CGRect(x: 0, y: 0, width: scoreView.frame.width, height: 25)
            
            var scoreY : CGFloat =  25
            for i in 0..<calFrame.scoreFrames.count {
                let optionHeights = calFrame?.scoreFrames[i]
                if let fieldView = self.viewWithTag(kScoreViewTag + i) as? CYJRECDetailCommentScoreView {
                    fieldView.frame = CGRect(x: 0, y: scoreY, width: scoreView.frame.width, height: (optionHeights?.0)!)
                    fieldView.arrowImageView.frame = CGRect(x: 12, y: 15 , width: 6, height:18);
                    fieldView.titleLabel.frame = CGRect(x: 22, y: 15, width: scoreView.frame.width - 22, height: (optionHeights?.1)!)
                    fieldView.detailLabel.frame = CGRect(x: 11, y: fieldView.titleLabel.frame.maxY + 8, width: scoreView.frame.width - 22, height: (optionHeights?.2)!)
                    
                    scoreY += (optionHeights?.0)!
                }
            }
        }else {
            scoreView.frame = calFrame.scoreViewFrame
            scoreTitleLabel.frame = CGRect(x: 11, y: 6, width: 100, height: 13)
            scoreTitleBackView.frame = CGRect(x: 0, y: 0, width: scoreView.frame.width, height: 25)
        }
        
        if calFrame.evaluate.content != nil {
            commentView.frame = calFrame.commentViewFrame
            commentTitleLabel.frame =  CGRect(x: 11, y: 6, width: 100, height: 13)
            commentTitleBackView.frame = CGRect(x: 0, y: 0, width: commentView.frame.width, height: 25)
            commentDetailLabel.frame = calFrame.commentDetailFrame
        }
        
        if (evaluate?.comment?.contentAttr) != nil {
            replayView.frame = calFrame.replayViewFrame
            replayTitleLabel.frame = CGRect(x: 11, y: 6, width: 100, height: 13)
            replayTitleBackView.frame = CGRect(x: 0, y: 0, width: replayView.frame.width, height: 25)
            replayNameLabel.frame = CGRect(x: 11, y: replayTitleBackView.frame.maxY + 15, width: 300, height: 15)
            replayDetailLabel.frame = calFrame.replayDetailFrame
            
            if let _ = evaluate?.comment?.reply {
                print(calFrame.teacherReplayTitleLabelFrame)
                teacherReplayTitleLabel.frame = calFrame.teacherReplayTitleLabelFrame
                
            }else {
                replayButton.frame = calFrame.replayButtonFrame
            }
        }
    }
    
    func replayButtonAction() {
        DLog("replayButtonAction")
        if let handelr = self.replayHandler {
            handelr(self)
        }
    }
}
