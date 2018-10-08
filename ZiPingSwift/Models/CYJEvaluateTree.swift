//
//  CYJEvaluateTree.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

/// 领域
class CYJDomain: CYJBaseModel{
    var dId: Int?    // 领域id
    var dName: String?  // 领域名称
    var dNum: Float? //总体分析使用
    var dimension: [CYJDimension]?
}

/// 纬度， dNum：只有当fordata的时候才用到了
class CYJDimension: CYJBaseModel{
    var diId: String?
    var diName: String?
    var quota: [CYJQuota]?
    
    var dNum: Float? //得分次数,,
}

/// 指标 lName：已经答过的才有    qNum: 只有formData的时候才用到
class CYJQuota: CYJBaseModel{
    var qId: String?    // 指标名称
    var qTitle: String? //指标标题
    var level: [CYJLevel]?
    var qNum: Float?  //得分次数
    var lName: String? // 答案，
    
    var lId: String?  //水平id 从这往下用户暂存记录的编辑展示
    var diId: String? //维度id
    var dId: String? //领域id

    var qTitleAttr: NSAttributedString{
        return NSAttributedString(string: qTitle ?? "qTitleAttr异常", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.black])
    } //指标标题
    var lNameAttr: NSAttributedString{
        return NSAttributedString(string: lName ?? "qTitleAttr异常", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.black])
    }// 答案，
    
    var zbColo: String? //颜色
    var zbDes: String? //摘要描述
    var zbGive: String? //
    
}

/// 水平
class CYJLevel: CYJBaseModel{
    var lId: String?
    var lName: String?
}

