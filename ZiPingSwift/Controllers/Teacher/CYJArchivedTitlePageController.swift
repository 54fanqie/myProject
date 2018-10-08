//
//  CYJArchivedTitlePageController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/1.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJArchivedTitlePageController: UIViewController {
    
    var backgroundImageView: UIImageView!
    var childImageView: UIImageView!
    var titleLabel: UILabel!
    var timeLabel: UILabel!
    
    var archive: CYJArchive!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "Archived.archivedBackgroundColor"
//        1.34  0.9
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: view.frame.width * 0.9 * 0.6))
        backgroundImageView.image =  #imageLiteral(resourceName: "dangandai-fengmian-bg1")
        view.addSubview(backgroundImageView)
        
        childImageView = UIImageView(frame: CGRect(x: 0, y:  backgroundImageView.frame.size.height + 30 , width: view.frame.width , height: Theme.Measure.screenHeight - backgroundImageView.frame.size.height - 30 ))
        childImageView.image =  #imageLiteral(resourceName: "dangandai-fengmian-bg2")
        view.addSubview(childImageView)
        
        
        titleLabel = UILabel(frame: CGRect(x: 15, y: 20 , width: view.frame.width - 110, height: 220))
        titleLabel.text = archive.archivesName
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name:"STHUPO",size: 36) // 设置字体，同时设置字体大小
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.sizeToFit()

        view.addSubview(titleLabel)
        
        timeLabel = UILabel(frame: CGRect(x: 26.5, y: Theme.Measure.screenHeight - 40 - 64 , width: Theme.Measure.screenWidth - 58, height: 15))
        timeLabel.text = "档案袋记录区间：\(archive.startTime ?? "——")~\(archive.endTime ?? "——")"
        timeLabel.font = UIFont.boldSystemFont(ofSize: 12)
        timeLabel.textColor = UIColor.white
        timeLabel.textAlignment = .center
        view.addSubview(timeLabel)
        
    }
    
}
