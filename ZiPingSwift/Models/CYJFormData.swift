//
//  CYJFormData.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJFormData: CYJBaseModel {
    
    var uId: Int = 0 //幼儿id
    var realName: String?    //幼儿姓名
    var domain: [Domain]?
    
    
    class Domain: CYJBaseModel {
        var dId: Int = 0     //领域id
        var dName: String? //领域名称
        var gSum: Int = 0 //领域使用次数
        var gNum: Float = 0 //星级
    }
}

class CYJBarData: CYJBaseModel {
    var domain: [CYJDomain]? //按领域
    var dimension: [CYJDimension]? //按维度
}

/// 总体统计
class CYJEvaluate: CYJBaseModel {
    var eId: Int = 0
    var eName: String?
    var domain: [CYJDomain]?
}


class CYJPieData: CYJBaseModel {
    var more: Int = 0// 最多
    var less: Int = 0// 最少
    var avg: Float = 0// 平均
    var mid: Float = 0// 中位数
    var praise: Int = 0 
    var reply: Int = 0
    /**
     domain : [ {
                     id：''，//领域id
                     dName：''，//领域名称
                     dimension: [//维度
                                     {
                                         diId: ''，//维度id
                                         diName: ''，//维度名称
                                         dNum: ''，//得分次数
                                     }， ...
                                 ]
                 }
     */
    var domain: [CYJDomain]? //按领域
    
    /**
     dimension : [{
                     id：''，//维度id
                     diName：''，//维度名称
                     quota：[//指标
                     {
                     qId: ''，//指标id
                     qTitle: ''，//指标名称
                     qNum: ''，//得分次数
                     }， ...]
                     }
                 ]
    */
    var dimension: [CYJDimension]? //按维度
    var evaluate: [CYJEvaluate]? //总体分析

}
