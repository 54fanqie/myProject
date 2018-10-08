
//
//  CYJArchive.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class CYJArchive: CYJBaseModel {

    var arId: Int = 0   //档案袋id
    var avatar: String? //头像
    var archivesName: String? //档案袋名称
    var interval: String?   //记录区间
    var record: [CYJRecord] = []
    var grId: [Int] = []
    
    var summary: String? //总结，寄语
    
    var startTime: String?  //开始时间
    var endTime: String? //结束时间
    
}

class CYJArchiveBarData: CYJBaseModel {
    var name: String? //''  //图名称
    var axis: [Axis] = []
    
    class Axis: CYJBaseModel {
        var title: String? //：''  //横坐标名称
        var num: Double = 0 //''  //横坐标值
    }
}
