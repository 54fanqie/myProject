//
//  CYJArchivedSummaryController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/1.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJArchivedSummaryController: UIViewController {
    
    var titleLabel: UILabel!
    var timeLabel: UILabel!
    
    var bottomImageView: UIImageView!
    var topImageView: UIImageView!
    var rightImageView: UIImageView!
    var archive: CYJArchive!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.theme_backgroundColor = "Archived.archivedBackgroundColor"

        rightImageView = UIImageView(frame: CGRect(x:view.frame.width * 0.5, y: 0, width: view.frame.width * 0.5, height: view.frame.width * 0.5 * 0.5))
        rightImageView.image = #imageLiteral(resourceName: "dangandai-fengdi-bg1")
        view.addSubview(rightImageView)
        
        topImageView = UIImageView(frame: CGRect(x:35, y: 80, width: view.frame.width * 0.4, height: view.frame.width * 0.3 * 0.5))
        topImageView.image = #imageLiteral(resourceName: "dangandai-fengdi-tit")
        view.addSubview(topImageView)
        
        timeLabel = UILabel(frame: CGRect(x: 35, y: topImageView.frame.maxY + 22 , width: Theme.Measure.screenWidth - CGFloat(56), height: 15))
        timeLabel.text = archive.summary
        timeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        timeLabel.textColor = UIColor.white
        timeLabel.numberOfLines = 0
        timeLabel.lineBreakMode = .byWordWrapping
        timeLabel.sizeToFit()
        
        view.addSubview(timeLabel)
        
        bottomImageView = UIImageView(frame: CGRect(x: 0, y: view.frame.height - view.frame.height * 0.3 - 64, width: view.frame.width, height: view.frame.height * 0.3))
        bottomImageView.image = #imageLiteral(resourceName: "dangandai-fengdi-bg2")
        
        view.addSubview(bottomImageView)
    }
    
}
