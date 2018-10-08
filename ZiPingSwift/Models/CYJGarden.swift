//
//  CYJGarden.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJGarden: CYJBaseModel{
    
}

class CYJGrade: CYJBaseModel {
    var gId: String?    // 领域id
    var gName: String?  // 幼儿园名称
    var gClasses: [CYJClass]?  // 所属年级
}

class CYJClass: CYJBaseModel {
    var cId: Int = 0    // 班级id
    var cName: String?  // 幼儿园名称
    var grade: Int = 0  // 所属年级
}
