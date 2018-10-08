//
//  ScoreListTableViewCell.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/8/8.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit

class ScoreListTableViewCell: UITableViewCell {
    
    var typeLab: UILabel?
    var tatolLab: UILabel?
    var averageLab: UILabel?
    var backView: UIView?

    var testGroupData = TestGroupData(){
        didSet{
            typeLab?.text = testGroupData.rangeToAge
            tatolLab?.text = testGroupData.averageScore
            averageLab?.text = testGroupData.averageAge
        }
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override init(style: UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    func initUI() {
        
        let bootomLine = UILabel();
        bootomLine.theme_backgroundColor = Theme.Color.line
        contentView.addSubview(bootomLine)
        
        bootomLine.snp.makeConstraints({ (make)in
            make.right.equalTo(contentView).offset(0)
            make.left.equalTo(contentView).offset(0)
            make.bottom.equalTo(contentView).offset(0)
            make.height.equalTo(1)
        })
        
        let leftspace = 97
        
        typeLab = UILabel();
        typeLab?.text = "3.5~4岁/男孩"
        typeLab?.theme_textColor = Theme.Color.textColor
        typeLab?.font = UIFont.systemFont(ofSize: 13)
        typeLab?.textAlignment = .center
        self.contentView.addSubview(typeLab!)
        
        typeLab?.snp.makeConstraints({ (make)in
            make.left.equalTo(contentView).offset(0)
            make.centerY.equalTo(contentView).offset(0)
            make.width.equalTo(leftspace)
        })
        
        
        backView = UIView();
        //        backView?.backgroundColor = UIColor.red
        self.contentView.addSubview(backView!)
        
        backView?.snp.makeConstraints({ (make)in
            make.left.equalTo(contentView).offset(97)
            make.right.equalTo(contentView).offset(0)
            make.top.equalTo(contentView).offset(0)
            make.bottom.equalTo(contentView).offset(0)
        })
        
        
        let firstLine = UILabel();
        firstLine.theme_backgroundColor = Theme.Color.line
        backView?.addSubview(firstLine)
        
        firstLine.snp.makeConstraints({ (make)in
            make.left.equalTo(backView!).offset(0)
            make.top.equalTo(backView!).offset(0)
            make.bottom.equalTo(backView!).offset(0)
            make.width.equalTo(1)
        })
        
        
        
        let midLine = UILabel();
        midLine.theme_backgroundColor = Theme.Color.line
        backView?.addSubview(midLine)
        
        midLine.snp.makeConstraints({ (make)in
            make.centerX.equalTo(backView!).offset(0)
            make.top.equalTo(backView!).offset(0)
            make.bottom.equalTo(backView!).offset(0)
            make.width.equalTo(1)
        })
        
        //总分数
        tatolLab = UILabel();
        tatolLab?.text = "100"
        tatolLab?.theme_textColor = Theme.Color.textColor
        tatolLab?.textAlignment = .center
        tatolLab?.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(tatolLab!)
        tatolLab?.snp.makeConstraints({ (make)in
            make.left.equalTo(firstLine).offset(0)
            make.right.equalTo(midLine).offset(0)
            make.centerY.equalTo(backView!).offset(0)
        })
        
        //平均分数
        averageLab = UILabel();
        averageLab?.text = "55"
        averageLab?.theme_textColor = Theme.Color.textColor
        averageLab?.font = UIFont.systemFont(ofSize: 13)
        averageLab?.textAlignment = .center
        self.contentView.addSubview(averageLab!)
        
        averageLab?.snp.makeConstraints({ (make)in
            make.left.equalTo(midLine).offset(0)
            make.right.equalTo(backView!).offset(0)
            make.centerY.equalTo(backView!).offset(0)
        })
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
