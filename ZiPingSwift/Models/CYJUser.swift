//
//  CYJUser.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

enum CYJRole: String {
    case none
    case noClass
    case noGarden
    case child
    case master
    case teacher
    case teacherL
}

class CYJUser: CYJBaseModel, NSCoding {
    
    var token           : String? //可反解加密(userId+登录时间+按规则加密后的码),
    var uId             : Int = 0
    var cId             : Int = 0 // 班级id
    var nId             : Int = 0  //幼儿园Id
    var isVerification  : Int = 0 //验证，是否有验证信息  1是 0不是
    var sName           : String? //验证消息的幼儿园名称，有验证消息的时候使用
    var username        : String? //账号-phone
    var realName        : String? //真实姓名
    var groupId         : Int = 0 //身份，（1园长，2教师 ，3家长，）
    var avatar          : String? //头像
    var uType           : Int = 0  // 教师类型（1 => '班主任',2 => '配班教师',‘’=>都不是）
    var babyStatus      : Int = 0 //  幼儿园内状态（1在园，2毕业3退学）
    var lookAuth        : Int = 0 //  2=全部权限 ，1=同班级权限，0=无权限
    var grade           : Int = 0 //  用户班级
    
    var role: CYJRole {
        if groupId == 1 {
            return .master
        }else if groupId == 2 {
            if nId == 0 {
                return .noGarden
            }else
            {
                if uType == 1 {
                    return .teacher
                }else if uType == 2 {
                    return .teacherL
                }else {
                    return .noClass
                }
            }
        }else
        {
            if nId == 0 {
                return .noGarden
            }else
            {
                return .child
            }
        }
    }
    
    
    // MARK:- 处理需要归档的字段
    func encode(with aCoder:NSCoder) {
        aCoder.encode(token, forKey:"token")
        aCoder.encode(uId, forKey:"uId")
        aCoder.encode(cId, forKey:"cId")
        aCoder.encode(nId, forKey:"nId")

        aCoder.encode(isVerification, forKey:"isVerfication")
        aCoder.encode(sName, forKey:"sName")
        aCoder.encode(username, forKey:"username")
        aCoder.encode(realName, forKey:"realName")
        aCoder.encode(groupId, forKey:"groupId")
        aCoder.encode(avatar, forKey:"avatar")
        aCoder.encode(uType, forKey:"uType")
        aCoder.encode(babyStatus, forKey:"babyStatus")
        aCoder.encode(lookAuth, forKey:"lookAuth")
        aCoder.encode(grade, forKey:"grade")
        
    }
    
    // MARK:- 处理需要解档的字段
    required init(coder aDecoder:NSCoder) {
        super.init()
        token  = aDecoder.decodeObject(forKey:"token") as? String
        uId  = aDecoder.decodeInteger(forKey: "uId")
        cId  = aDecoder.decodeInteger(forKey: "cId")
        nId  = aDecoder.decodeInteger(forKey: "nId")

        isVerification = aDecoder.decodeInteger(forKey: "isVerfication")
        sName = aDecoder.decodeObject(forKey:"sName") as? String
        username = aDecoder.decodeObject(forKey:"username") as? String
        realName = aDecoder.decodeObject(forKey:"realName") as? String
        groupId = aDecoder.decodeInteger(forKey: "groupId")
        avatar = aDecoder.decodeObject(forKey:"avatar") as? String
        uType = aDecoder.decodeInteger(forKey: "uType")
        babyStatus = aDecoder.decodeInteger(forKey: "babyStatus")
        lookAuth = aDecoder.decodeInteger(forKey: "lookAuth")
        grade = aDecoder.decodeInteger(forKey: "grade")
    }
    
    required init() {
        super.init()
    }
}

class CYJChild: CYJBaseModel {
    var uId             : Int = 0
    var username        : String? //账号
    var realName        : String? //真实姓名
    var avatar          : String? //头像
    
    var uvId: Int?//验证数据id，type=2才有
    var status: Int?    //状态(2未验证,3拒绝加入) type=2才有
    
    var weekRecordNum: Int?
    var grownRecordNum: Int?   //成长记录数 type=1才有
    var archivesNum: Int?   //档案袋数 type=1才有
}

/// 个人详细资料
class CYJUserExtraInfo: CYJBaseModel {
    var avatar: String?       //头像地址
    var realName: String?     //真实姓名
    var sex: Int = 0            // 1男 2女
    var birthday: String?       //生日
    var eduBackground: Int = 0  // 初始学历（1初中，2高中及中专，3大专，4本科，5硕士及以上）
    var major: Int = 0          // 初始学历所学专业（1学期教育，2其他教育类专业3心理教育4非教育类专业）
    var highestEdu: Int = 0     // 最高学历
    var highestMajor: Int = 0   // 最高学历所学专业
    var titleName: Int = 0      //  职称（1三级，2二级，3一级， 4中学高级5无职称）
    var email: String?          //邮箱
    var jobName: Int = 0        // 现任职务：1园长;2业务副园长;3保教主任;4.其他 ）
    var workTime: Int = 0       //  任职时间(1.不到1年,2. 1-3年,3. 4-8年,4. 9年以上)
    
    var sexDescription: String {
        return sex == 1 ? "男" : "女"
    }
    
    var eduBackgroundDescription: String {
        switch eduBackground {
        case 1: return "初中"
        case 2: return "高中及中专"
        case 3: return "大专"
        case 4: return "本科"
        case 5: return "硕士及以上"
        default: return "请选择"
        }
    }
    
    var highestEduDescription: String {
        switch highestEdu {
        case 1: return "初中"
        case 2: return "高中及中专"
        case 3: return "大专"
        case 4: return "本科"
        case 5: return "硕士及以上"
        default: return "请选择"
        }
    }
    var majorDescription: String {
        switch major {
        case 1: return "学前教育"
        case 2: return "其他教育类专业"
        case 3: return "心理教育"
        case 4: return "非教育类专业"
        default: return "请选择"
        }
    }
    var highestMajorDescription: String {
        switch highestMajor {
        case 1: return "学前教育"
        case 2: return "其他教育类专业"
        case 3: return "心理教育"
        case 4: return "非教育类专业"
        default: return "请选择"
        }
    }
    var titleNameDescription: String {
        switch titleName {
        case 1: return "三级"
        case 2: return "二级"
        case 3: return "一级"
        case 4: return "中学高级"
        case 5: return "无职称"
        default: return "请选择"
        }
    }
    var jobNameDescription: String {
        switch jobName {
        case 1: return "园长"
        case 2: return "业务副园长"
        case 3: return "保教主任"
        case 4: return "其他"
        default: return "请选择"
        }
    }
    var workTimeDescription: String {
        switch workTime {
        case 1: return "不到1年"
        case 2: return "1-3年"
        case 3: return "4-8年"
        case 4: return "9年以上"
        default: return "请选择"
        }
    }
    
    
}
