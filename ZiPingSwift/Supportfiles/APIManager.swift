//
//  APIManager.swift
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/17.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation


struct APIManager {
    
    //MARK: Server地址
        static let serverPath = "http://api.epaofu.com"
    //    static let serverPath = "http://testapi.emice.net"
//    static let serverPath = "http://testapi.epaofu.com"
    
    struct User {
        /// 登录
        static let login: String = serverPath + "/user/login"
        /// 退出登录
        static let logout: String = serverPath + "/user/logout"
        /// 获取联系方式
        static let contract: String = serverPath + "/user/contact"
        /// 获取验证码
        static let code: String = serverPath + "/user/code"
        /// 修改密码-通过验证码
        static let modifyPwd: String = serverPath + "/user/modifyPwd"
        
    }
    
    struct Record {
        /// 模版
        static let tree: String = serverPath + "/grown/tree"
        /// 成长记录列表
        static let list: String = serverPath + "/grown/list"
        /// 成长记录列表- 暂存列表
        static let listTemp: String = serverPath + "/grown/listTemp"
        /// 成长记录列表-家长
        static let listParent: String = serverPath + "/grown/listParent"
        /// 获取幼儿园指定学年的所有班级
        static let allClasses: String = serverPath + "/baby/class"
        /// 添加成长记录
        static let add: String = serverPath + "/grown/add"
        /// 修改成长记；成长记
        static let edit: String = serverPath + "/grown/edit"
        
        /// 成长记录详细描述
        static let info: String = serverPath + "/grown/info"
        /// 成长记录评价
        static let student: String = serverPath + "/grown/student"
        /// 删除成长记录
        static let delete: String = serverPath + "/grown/del"
        /// 将成长记录分享给家长
        static let share: String = serverPath + "/grown/share"
        /// 批阅成长记录
        static let mark: String = serverPath + "/grown/mark"
        
        /// 成长记录回复或评论
        static let comment: String = serverPath + "/grown/comment"
        
        /// 点赞
        static let praise: String = serverPath + "/grown/praise"
        
        /// listDomain
        static let listDomain: String = serverPath + "/grown/listDomain"
        
    }
    
    struct Archive {
        /// 档案袋列表
        static let list: String = serverPath + "/archives/list"
        /// 档案袋详细信息
        static let info: String = serverPath + "/archives/info"
        
        /// 档案袋的表 们
        static let chartData: String = serverPath + "/archives/bar"
        
    }
    
    struct Message {
        /// 消息列表
        static let list: String = serverPath + "/message/list"
        /// 消息未读条数信息
        static let info: String = serverPath + "/message/info"
        /// 未读消息树木
        static let unread: String = serverPath + "/message/read"
        
    }
    struct Baby {
        /// 班级幼儿列表
        static let list: String = serverPath + "/baby/list"
        /// 删除未验证幼儿
        static let delete: String = serverPath + "/baby/del"
        /// 给班级添加幼儿
        static let add: String = serverPath + "/baby/add"
        
        /// 获取又有班级
        static let getClass: String = serverPath + "/baby/class"
    }
    
    struct Mine {
        
        /// 登录验证发送验证码
        static let getCode: String = serverPath + "/my/getCode"
        /// 登录验证页 当不为200的时候 需要弹出为不登录状态
        static let valid: String = serverPath + "/my/valid"
        /// 登录时，放弃验证
        static let validno: String = serverPath + "/my/validno"
        /// 绑定账号
        static let listnexus: String = serverPath + "/my/listnexus"
        /// 取消绑定账号
        static let delnuxus: String = serverPath + "/my/delnexus"
        /// 添加关联账号
        static let addnexus: String = serverPath + "/my/addnexus"
        /// 切换账号！，当密码判断错误，输入密码重新调用此接口需传此字段
        static let changecount: String = serverPath + "/my/changecount"
        /// 个人资料
        static let info: String = serverPath + "/my/info"
        /// 告诉我们
        static let care: String = serverPath + "/my/care"
        /// 获取告诉我们的选项
        static let getCare: String = serverPath + "/my/getcare"
        /// 提交反馈
        static let feedback: String = serverPath + "/my/feedback"
        /// 修改联系方式
        static let resetContract: String = serverPath + "/my/modContact"
        /// 修改密码
        static let modPwd: String = serverPath + "/my/modPwd"
        
        /// 上传头像
        static let avater: String = serverPath + "/my/avatar"
        
        /// 获取当前用户所有教师
        static let teacher: String = serverPath + "/my/teacher"
        
        /// 获取教师的信息
        static let teacherInfo: String = serverPath + "/my/teacherinfo"
        /// 更改个人信息
        static let update: String = serverPath + "/my/update"
        
        
    }
    
    struct Media {
        static let photoServer: String = serverPath + "/photoServer/createSignature"
        static let videoServer: String = serverPath + "/video/createSignature"
    }
    
    struct Tongji {
        static let grownfx: String = serverPath + "/tj/grownfx"
        static let attentionpj: String = serverPath + "/tj/attentiontj"
        static let grownpj: String = serverPath + "/tj/grownpj"
        static let analPro: String = serverPath + "/tj/analPro"
    }
    struct Valuation {
        static let check: String = serverPath + "/evaluation/check"
        static let getShiti: String = serverPath + "/evaluation/getShiti"
        static let addAnswer: String = serverPath + "/evaluation/addAnswer"
        static let teacherResult: String = serverPath + "/evaluation/teacherResult"
        static let applyReport: String = serverPath + "/evaluation/applyReport"
        static let teacherApplyReport: String = serverPath + "/evaluation/teacherApplyReport"
        static let getClass: String = serverPath + "/evaluation/getClass"
        static let getTestTime: String = serverPath + "/evaluation/getTestTime"
        static let analysis: String = serverPath + "/evaluation/analysis"
        
    }
}
