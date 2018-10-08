//
//  CYJMessage.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJMessage: CYJBaseModel {
    
    var muId: Int = 0//消息id
    var realName: String?   //发消息人姓名
    var avatar: String?     //发消息人头像
    var content: String?    //消息内容
    var dataContent: String?     //针对数据内容
    var dataImg: String?    //针对数据图片
    var dataId: Int?    //针对数据id
    var dataType: Int?   //消息类型：1成长记录；2档案袋
    var isRead: Int = 2 //是否阅读：1是；2否
    var createtime: String?
}

class CYJUnreadMessageCount: CYJBaseModel {
    
    var thumb: Int = 0  // 收到的赞未读数
    var feedback: Int = 0// 收到的反馈未读数
    var mark: Int = 0 // 园长批阅未读数
    var system: Int = 0     // 系统消息未读数
    var apply: Int = 0     // 测评申请消息未读数
    var sumCount: Int {
        return thumb + feedback + mark + system + apply
    }

}
