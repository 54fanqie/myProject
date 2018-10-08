//
//  CYJCountedView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/22.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJCountedView: UIView {
    
    @IBOutlet weak var recordTitle: UILabel!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var count1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var count2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var count3: UILabel!
    @IBOutlet weak var title4: UILabel!
    @IBOutlet weak var count4: UILabel!
    
    @IBOutlet weak var parentTitle: UILabel!
    @IBOutlet weak var parentGoodTitle: UILabel!
    @IBOutlet weak var parentGoodCount: UILabel!
    @IBOutlet weak var parentReplyTitle: UILabel!
    @IBOutlet weak var parentReplyCount: UILabel!
    
    var pieData: CYJPieData? {
        didSet{
            if let pieData = pieData {
                self.count1.text = "\(pieData.more)"
                self.count2.text = "\(pieData.less)"
                self.count3.text = "\(pieData.avg)"
                self.count4.text = "\(pieData.mid)"
                self.parentGoodCount.text = "\(pieData.praise)"
                self.parentReplyCount.text = "\(pieData.reply)"
            }

        }
    }
    
    public class func countView(frame: CGRect)-> CYJCountedView {
        let countedView = Bundle.main.loadNibNamed("CYJCountedView", owner: nil, options: nil)?.last as! CYJCountedView
        
        countedView.frame = frame
        
        return countedView
    }
    
    
}
