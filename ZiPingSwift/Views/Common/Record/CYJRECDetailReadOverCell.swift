//
//  CYJRECDetailReadoverCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/29.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


class CYJRECDetailReadOverCell: UITableViewCell {
    
    lazy var readBackView :UIView = {
        let view = UIView(frame: CGRect.zero)
        view.theme_backgroundColor = Theme.Color.TabMain
        return view;
    }()
    lazy var readOverLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.main
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.text = "被批阅"
        return label
    }()
    lazy var byLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorlight
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        label.text = "(番茄 2017-12-12)"
        
        return label
    }()
    lazy var scoreTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "综合评分"
        return label
    }()
    lazy var scoreLabel1: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "描述客观清晰:"
        
        return label
    }()
    lazy var scoreLabel2: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "描述全面细致:"
        
        return label
    }()
    lazy var scoreLabel3: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "评价指标适宜:"
        
        return label
    }()
    lazy var scoreLabel4: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "评价水平准确:"
        return label
    }()
    
    lazy var starView1: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.hasShowHalfStar = false // 是否打开半星
        halfStarView.isUserInteractionEnabled = false
        halfStarView.starCount = 5
        halfStarView.space = 4
        return halfStarView
    }()
    lazy var starView2: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.hasShowHalfStar = false // 是否打开半星
        halfStarView.isUserInteractionEnabled = false
        halfStarView.starCount = 5
        halfStarView.space = 4
        return halfStarView
    }()
    lazy var starView3: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.starCount = 5
        halfStarView.space = 4
        halfStarView.hasShowHalfStar = false // 是否打开半星
        halfStarView.isUserInteractionEnabled = false
        
        return halfStarView
    }()
    lazy var starView4: StarEvaluateView = {
        let halfStarView = StarEvaluateView(sumCount: 5, starSpace: 20, norImg: UIImage(named: "GoodsDetailCollection"), selImg: UIImage(named: "yellowStar"))
        halfStarView.hasShowHalfStar = false // 是否打开半星
//        halfStarView.isUserInteractionEnabled = false
        halfStarView.starCount = 5
        halfStarView.space = 4
        return halfStarView
    }()
    
    lazy var evaluateTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.theme_textColor = Theme.Color.textColor
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "综合评语"
        return label
    }()
    lazy var evaluateLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.theme_textColor = Theme.Color.textColorDark
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    //MARK: init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.theme_backgroundColor = Theme.Color.ground
        makeContainerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var infoFrame: CYJRECDetailCellFrame! {
        didSet {
            layoutContainerView()
            
            self.byLabel.text = "(\(infoFrame.record.commentName ?? "commentName异常")" + " " + "\(infoFrame.record.commentTime ?? "commentTime异常"))"
            
            self.starView1.currentStar = infoFrame.record.scoreA
            self.starView2.currentStar = infoFrame.record.scoreB
            self.starView3.currentStar = infoFrame.record.scoreC
            self.starView4.currentStar = infoFrame.record.scoreD
            
            self.evaluateLabel.text = infoFrame.record.content
        }
    }
    
    func layoutContainerView() {
        readBackView.frame = CGRect(x: 40, y: 10, width: Theme.Measure.screenWidth - 80, height: 55)
        readOverLabel.frame = CGRect(x: 0, y: 5, width: readBackView.frame.width , height: 20)
        byLabel.frame = CGRect(x: 0, y: readOverLabel.frame.maxY + 10, width: readBackView.frame.width, height: 15)
        
        scoreTitleLabel.frame = CGRect(x: 40, y: readBackView.frame.maxY + 25, width: 150, height: 15)
        scoreLabel1.frame = CGRect(x: 40, y: scoreTitleLabel.frame.maxY + 15, width: 100, height: 15)
        scoreLabel2.frame = CGRect(x: 40, y: scoreLabel1.frame.maxY + 15, width: 100, height: 15)
        scoreLabel3.frame = CGRect(x: 40, y: scoreLabel2.frame.maxY + 15, width: 100, height: 15)
        scoreLabel4.frame = CGRect(x: 40, y: scoreLabel3.frame.maxY + 15, width: 100, height: 15)
        starView1.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel1.frame.minY, width: 92, height: 15)
        starView2.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel2.frame.minY, width: 92, height: 15)
        starView3.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel3.frame.minY, width: 92, height: 15)
        starView4.frame = CGRect(x: scoreLabel1.frame.maxX + 10, y: scoreLabel4.frame.minY, width: 92, height: 15)
        
        
        evaluateTitleLabel.frame = CGRect(x: 40, y: scoreLabel4.frame.maxY + 20, width: 150, height: 15)
        evaluateLabel.frame = CGRect(x: 40, y: evaluateTitleLabel.frame.maxY + 15, width: Theme.Measure.screenWidth - 80, height: infoFrame.evaluateCalHeight )
        
    }
    
    func makeContainerView() {
        contentView.addSubview(readBackView)
        readBackView.addSubview(readOverLabel)
        readBackView.addSubview(byLabel)
        
        contentView.addSubview(scoreTitleLabel)
        contentView.addSubview(scoreLabel1)
        contentView.addSubview(scoreLabel2)
        contentView.addSubview(scoreLabel3)
        contentView.addSubview(scoreLabel4)
        contentView.addSubview(starView1)
        contentView.addSubview(starView2)
        contentView.addSubview(starView3)
        contentView.addSubview(starView4)
        
        contentView.addSubview(evaluateTitleLabel)
        contentView.addSubview(evaluateLabel)
        
    }
}
