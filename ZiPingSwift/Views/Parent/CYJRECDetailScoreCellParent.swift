//
//  CYJRECDetailScoreCellParent.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


class CYJRECDetailScoreCellParent: UITableViewCell {
    
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
    lazy var replayFromTeacherLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "教师回复："
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var replayFromTeacherDetailLabel: UILabel = {
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
    var calFrame: CYJEvaluateForRecordParentFrame! {
        didSet{
            makeContainerView()
            
            layoutContainerView()
            
        }
    }
    
    func makeContainerView() {
        
        for view in scoreView.subviews {
            view.removeFromSuperview()
        }
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        //1. 判断是否存在评分
        if let quotas = evaluate?.quota {
            if quotas.count > 0 { // 显示评分
                contentView.addSubview(scoreView)
                scoreView.addSubview(scoreTitleBackView)
                scoreView.addSubview(scoreTitleLabel)
                
                for i in 0..<(evaluate?.quota?.count)! {
                    let quota = evaluate?.quota?[i]
                    
                    let fieldView = CYJRECDetailCommentScoreView()
                    fieldView.tag = kScoreViewTag + i
                    fieldView.titleLabel.text = quota?.qTitle
                    fieldView.detailLabel.text = quota?.lName
                    scoreView.addSubview(fieldView)
                }
            }else {
                //显示 未评分
                contentView.addSubview(scoreView)
                scoreView.addSubview(scoreTitleBackView)
                scoreView.addSubview(scoreTitleLabel)
                scoreView.addSubview(scoreEmptyLabel)
                
            }
        }
        
        // 2. 判断是否存在评价
        if let content = evaluate?.formContent {
            contentView.addSubview(commentView)
            
            commentView.addSubview(commentTitleBackView)
            commentView.addSubview(commentTitleLabel)
            
            commentView.addSubview(commentDetailLabel)
            commentDetailLabel.text = content
        }
        
        // 3. 判断是否存在反馈
        if let comment = evaluate?.comment {
            
            if let _ = comment.content {
                contentView.addSubview(replayView)
                replayView.addSubview(replayTitleBackView)
                replayView.addSubview(replayTitleLabel)
                replayView.addSubview(replayDetailLabel)
                replayDetailLabel.text = comment.content
                // 4. 判断是否存在回复
                if let _ = comment.reply {
                    replayView.addSubview(replayFromTeacherLabel)
                    replayFromTeacherLabel.attributedText = comment.replayAttr
//                    replayView.addSubview(replayFromTeacherDetailLabel)
//                    replayFromTeacherDetailLabel.text = comment.reply
                }
            }
        }
    }
    
    func layoutContainerView() {
        //1. 判断是否存在评分
        if let quotas = evaluate?.quota {
            if quotas.count > 0 {
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
                
                
                
                //MARK: 在最下面显示一条线出来
                let line = UIView()
                line.theme_backgroundColor = Theme.Color.line
                line.frame = CGRect(x: 0, y: scoreView.frame.maxY - 0.5, width: Theme.Measure.screenWidth, height: 0.5)
//                scoreView.addSubview(line)
                
            }
        }
//        if calFrame.scoreFrames.count > 0 {
//
//
//        }
        // 2. 判断是否存在评价
        if let _ = evaluate?.content {
            commentView.frame = calFrame.commentViewFrame
            commentTitleLabel.frame =  CGRect(x: 11, y: 6, width: 100, height: 13)
            commentTitleBackView.frame = CGRect(x: 0, y: 0, width: commentView.frame.width, height: 25)
            commentDetailLabel.frame = calFrame.commentDetailFrame
        }
        // 3. 判断是否存在反馈
        if let _ = evaluate?.comment?.content {
            replayView.frame = calFrame.replayViewFrame
            replayTitleLabel.frame = CGRect(x: 11, y: 6, width: 100, height: 13)
            replayTitleBackView.frame = CGRect(x: 0, y: 0, width: replayView.frame.width, height: 25)
            replayDetailLabel.frame = calFrame.replayDetailFrame
            // 4. 判断是否存在回复
            if let _ = evaluate?.comment?.reply {
                replayFromTeacherLabel.frame = calFrame.replayForTeacherFrame
//                replayFromTeacherDetailLabel.frame = calFrame.replayForTeacherDetailFrame
            }
        }
    }
}

