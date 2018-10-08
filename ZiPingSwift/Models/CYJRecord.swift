//
//  CYJRecord.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import HandyJSON

class CYJMedia: CYJBaseModel, ExpressibleByStringLiteral {
    
    typealias StringLiteralType = String
    
    var url: String? //地址
    var filetype: Int?  //1 图片，2视频
    var fileName: String?
    var oldName: String?
    var size: UInt8 = 0
    var suffix: String?
    var videoId: String?
    var videoPath: String?

    required init(stringLiteral value: StringLiteralType) {
        url = value
        filetype = 1
        fileName = URL(string: value)?.lastPathComponent
    }
    
    required init() {
        super.init()
    }
}

class CYJRecord: CYJBaseModel {

    var grId: Int = 0 //记录id
    
    var uId: Int = 0  // 添加教师的Id

    var createtime: TimeInterval = 0 //记录日期
    var rTime: String? //同createtime， 只有成长记录列表（暂存）用到了
    
    var babyName: String?  //幼儿名称，逗号分隔
    var teacherName: String?    //添加教师
    var thumbName: String = ""  //点赞名单，逗号分隔
    var describe: String? //记录描述
    var comment: String? //记录描述

    var cName: String? //班级名称
    var photo: [CYJMedia]?

    var commentNum: Int = 0 //评论数
    var isGood: Int = 2 //是否为优秀记录:1是，2否，
    var praiseNum: Int = 0   //点赞数
    var isMine: Int = 1   //是否是本班的成长记录，教师使用 1 是， 0 不是
    var isMark: Int = 1 //1未批阅 2已批阅
    var isPraised: Int = 0   //是否点赞（0未点赞，1已点赞）
    var scoreA: Int = 0     //记录客观准确(1-5) 从这往下均为已批阅才有
    var scoreB: Int = 0     //记录全面细致
    var scoreC: Int = 0     //评分指标得当
    var scoreD: Int = 0     //评分结果准确
    var content: String?     //评语
    var commentName: String?  // 园长姓名
    var commentTime: String?  //批阅时间
    var user: [CYJChild] = []  //肯定有，而且不为空
    
    var total: Int = 0  //总数
    
}

extension CYJRecord {
    
    func newPraise(name: String) {
        
        if (thumbName.isEmpty) {
            thumbName = name
        }else {
            thumbName += ",\(name)"
        }
    }
    
    var thumbNameAttr: NSAttributedString {
        
        guard !self.thumbName.isEmpty else {
            return NSAttributedString(string: "暂无点赞", attributes: [NSForegroundColorAttributeName : Theme.Color.color("Global.textColorMid"), NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
        }
        return NSAttributedString(string: self.thumbName , attributes: [NSForegroundColorAttributeName : Theme.Color.color("Global.textColorMid"), NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
    }
    
    var contentAttr: NSAttributedString {
        guard let content = self.content else {
            return NSAttributedString(string: "暂没有评语")
        }
        return NSAttributedString(string: content , attributes: [NSForegroundColorAttributeName : UIColor.blue, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
    }
    
    var attrDate: NSAttributedString  {
        if let str = self.rTime{
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd"
            let currentDate = dateFormater.date(from: str)
            let calendar = Calendar.current
            var comps: DateComponents = DateComponents()
            comps = calendar.dateComponents([.year,.month,.day], from: currentDate!)
            
            let month = comps.month
            let day = comps.day
            
            let attrDay = NSAttributedString(string: "\(day ?? 1)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 26)])
            let attrMonth = NSAttributedString(string: "\(month ?? 1)月", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
            
            let dateStr = NSMutableAttributedString(attributedString: attrDay)
            dateStr.append(attrMonth)
            return dateStr
            
        }else
        {
            fatalError("时间不能为空")
        }
    }
    
    /// 详细描述
    var attrContent: NSAttributedString  {
        
        guard let content = self.describe else {
            return NSAttributedString(string: "教师没有添加详细描述")
        }
        
        return NSAttributedString(string: content , attributes: [NSForegroundColorAttributeName : UIColor.blue, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
    }
}


class CYJRecordEvaluate: CYJBaseModel {
    
    var uId: Int = 0  //学生id
    var realName: String? //姓名
    var avatar: String? //头像
    var content: String? //评语
    var formContent: String {
        if let content = self.content {
            if content.isEmpty{
                return "暂未设置评语／建议"
            }
        }
        return self.content!
    }
    var contentAttr: NSAttributedString {
        guard let content = self.content else {
            return NSAttributedString(string: "暂未设置评语／建议")
        }
        return NSAttributedString(string: content , attributes: [NSForegroundColorAttributeName : UIColor.blue, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
    }
    var quota: [CYJQuota]? //评分
    var comment: CYJRecordComment?
}

class CYJRecordComment: CYJBaseModel{
    var content: String?    //家长评论内容
    var formContent: String {
        if let content = self.content {
            if content.isEmpty{
                return "暂没有反馈内容"
            }
        }
        return self.content!
    }
    var contentAttr: NSAttributedString {
        guard let content = self.content else {
            return NSAttributedString(string: "暂没有反馈内容")
        }
        return NSAttributedString(string: content , attributes: [NSForegroundColorAttributeName : UIColor(hex6: 0x333333), NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
    }

    
    var createtime: String? //家长评论时间
    var reply: String?  //教师回复内容
    var formReplay: String {
        if let replay = self.reply {
            if replay.isEmpty{
                return "暂没有回复内容"
            }
        }
        return self.content!
    }
    
    var replayAttr: NSAttributedString {
        
        let mutiable = NSMutableAttributedString()
        let leading = NSAttributedString(string: "教师回复：" , attributes: [NSForegroundColorAttributeName : UIColor(hex6: 0x999999), NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
        
        let message = NSAttributedString(string: "\(self.reply ?? "暂没有回复内容")" , attributes: [NSForegroundColorAttributeName : UIColor(hex6: 0x333333), NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
        
        mutiable.append(leading)
        mutiable.append(message)
        
        return mutiable
    }
    
    var replyTime: String?  //教师回复时间
    
    var coId: Int = 0 //''，//家该条评论id
    var realName: String? // ''，//家长姓名
    var replyName: String? //''，//教师姓名
}

//MARK: 家长--评分Cell
class CYJEvaluateForRecordParentFrame: NSObject {
    
    /// 评分的高度  0. 整体高度， 1，标题高度， 2， 内容高度
    typealias OptionCellMeasure = (CGFloat,CGFloat,CGFloat)
    var evaluate: CYJRecordEvaluate
    
    var scoreViewFrame: CGRect = .zero
    var scoreFrames: [OptionCellMeasure] = []
    var commentViewFrame: CGRect = .zero
    var commentDetailFrame: CGRect = .zero
    var replayViewFrame: CGRect = .zero
    var replayDetailFrame: CGRect = .zero
    var replayForTeacherFrame: CGRect = .zero
//    var replayForTeacherDetailFrame: CGRect = .zero
    
    var cellHeight: CGFloat = 0
    
    init(_ evaluate: CYJRecordEvaluate) {
        self.evaluate = evaluate
        
        let contentSize = CGSize(width: Theme.Measure.screenWidth - 76, height: CGFloat(MAXFLOAT))
        
        var y: CGFloat = 15
        if let fields = evaluate.quota {
            if fields.count > 0 {
                var optionsFrame:[OptionCellMeasure] = []
                var allOptionHeight: CGFloat = 40
                for option in fields {

                    let calTitleHeight = option.qTitleAttr.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    let calDetailHeight = option.lNameAttr.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    optionsFrame.append((15 + calTitleHeight + 8 + calDetailHeight, calTitleHeight + 2, calDetailHeight + 2))
                    allOptionHeight += 15 + calTitleHeight + 8 + calDetailHeight
                }
                self.scoreFrames = optionsFrame
                self.scoreViewFrame = CGRect(x: 38, y: y, width: contentSize.width, height: allOptionHeight)
                
                y += (allOptionHeight + 15)
            }else {
                // 当评分为空时，显示  暂未设置评分
                self.scoreViewFrame = CGRect(x: 38, y: y, width: contentSize.width, height: 44 + 8)
                y += (44 + 15 + 15)
            }
        }
        
//        if let content = {
            let calTitleHeight = evaluate.contentAttr.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            self.commentDetailFrame = CGRect(x: 11, y: 13 + 25, width: contentSize.width - 22, height: calTitleHeight)
            
            self.commentViewFrame = CGRect(x: 38, y: y, width: contentSize.width, height: calTitleHeight + 13 + 25 + 15)
            y += (self.commentViewFrame.height + 15)
            
//        }
        
        if let _ = evaluate.comment?.content {
            
            var replayViewHeight: CGFloat = 25 + 15
            
            let calTitleHeight = (evaluate.comment?.contentAttr)!.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            
            self.replayDetailFrame = CGRect(x: 11, y: 13 + 25, width: contentSize.width - 22, height: calTitleHeight)
            
            replayViewHeight += calTitleHeight
            
            if let _ = evaluate.comment?.reply {
                replayViewHeight += 15
                let calReplayHeight = (evaluate.comment?.replayAttr)!.boundingRect(with: CGSize(width: contentSize.width - 11 - 11, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                
                self.replayForTeacherFrame = CGRect(x: 11, y: replayViewHeight, width: contentSize.width - 11 - 11, height: calReplayHeight)
                
//                self.replayForTeacherDetailFrame = CGRect(x: replayForTeacherFrame.maxX, y: replayViewHeight, width: contentSize.width - 66, height: calReplayHeight)
                replayViewHeight += calReplayHeight
            }
            
            self.replayViewFrame = CGRect(x: 38, y: y, width: contentSize.width, height: replayViewHeight + 15 )
            
            y += (self.replayViewFrame.height + 15)
        }
        
        cellHeight = y
    }
}


class CYJEvaluateForRecordFrame: NSObject {
    
    /// 评分的尺寸， 0.整体高度， 1，标题高度， 2，内容高度
    typealias OptionCellMeasure = (CGFloat,CGFloat,CGFloat)
    var evaluate: CYJRecordEvaluate
    var ownerId: Int = 0
    
    var scoreViewFrame: CGRect = .zero
    var scoreFrames: [OptionCellMeasure] = []
    var commentViewFrame: CGRect = .zero
    var commentDetailFrame: CGRect = .zero
    var replayViewFrame: CGRect = .zero
    var replayDetailFrame: CGRect = .zero
    
    var teacherReplayTitleLabelFrame : CGRect = .zero
//    var teacherReplayDetailLabelFrame : CGRect = .zero
    var replayButtonFrame: CGRect = .zero
    
    var cellHeight: CGFloat = 0
    
    init(_ evaluate: CYJRecordEvaluate, owner: Int) {
        self.evaluate = evaluate
        self.ownerId = owner
        // 排除了头像和边距之后剩下的宽度
        let contentSize = CGSize(width: Theme.Measure.screenWidth - 76 - 15, height: CGFloat(MAXFLOAT))

        var y: CGFloat = 61
        if let fields = evaluate.quota {
            if fields.count > 0 {
                var optionsFrame:[OptionCellMeasure] = []
                var allOptionHeight: CGFloat = 40
                for option in fields {
                    //FIXME: quto的 名字和内容
                    let calTitleHeight = option.qTitleAttr.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    let calDetailHeight = option.lNameAttr.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    optionsFrame.append((15 + calTitleHeight + 8 + calDetailHeight, calTitleHeight, calDetailHeight))
                    allOptionHeight += 15 + calTitleHeight + 8 + calDetailHeight
                }
                self.scoreFrames = optionsFrame
                self.scoreViewFrame = CGRect(x: 76, y: y, width: contentSize.width, height: allOptionHeight)
                
                y += (allOptionHeight + 15)
            }else {
                
                self.scoreViewFrame = CGRect(x: 76, y: y + 8, width: contentSize.width, height: 44 + 15)
            
                y += (44 + 15 + 15)
            }
        }
        
        let comment = evaluate.contentAttr
            let calTitleHeight = comment.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            self.commentDetailFrame = CGRect(x: 11, y: 13 + 25, width: contentSize.width - 22, height: calTitleHeight)
            
            self.commentViewFrame = CGRect(x: 76, y: y, width: contentSize.width, height: calTitleHeight + 13 + 25 + 15)
            y += (self.commentViewFrame.height + 15)
        
        if let commentContent = evaluate.comment?.contentAttr {
            // replayView 的高度，与y区别计算
            /**/
            var replayViewY: CGFloat =  25/*titleBackViewHeight*/ + 15/*space*/ + 15/*name and time Height*/ + 13 /*space*/
            
            let calTitleHeight = commentContent.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            self.replayDetailFrame = CGRect(x: 11, y: replayViewY, width: contentSize.width - 22, height: calTitleHeight)
            
            replayViewY += calTitleHeight
            
            if let _ = evaluate.comment?.content { //只有存在家长反馈，才会显示回复
                if let _ = evaluate.comment?.reply {
                    
                    let replayHeight = (evaluate.comment?.replayAttr)!.boundingRect(with: CGSize(width: contentSize.width - 22, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    self.teacherReplayTitleLabelFrame = CGRect(x: self.replayDetailFrame.minX, y: replayViewY + 15, width: contentSize.width - 22 - 11, height: replayHeight)
                    print("-----------------")

                    print(self.teacherReplayTitleLabelFrame)

                    replayViewY += (replayHeight + 15)
                    
                }else {
                    
                    //replay 没有的话，应该显示回复按钮
                    
                    if LocaleSetting.userInfo()?.uId == self.ownerId {
                        self.replayButtonFrame = CGRect(x: self.replayDetailFrame.minX, y: self.replayDetailFrame.maxY + 8, width: 40, height: 30)
                        
                        replayViewY += (self.replayButtonFrame.height + 8)
                    }
                }
            }
            
            
            self.replayViewFrame = CGRect(x: 76, y: y, width: contentSize.width, height: replayViewY + 15)

            y += (self.replayViewFrame.height)
        }
        
        cellHeight = y
    }
}




struct CYJRECDetailCellFrame {
    
    var record: CYJRecord
    var role: CYJRole
    
    var leftBaseLine: CGFloat =  40
    var padding: CGFloat = 2
    var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    var dateLabelFrame: CGRect              = .zero //时间
    var toLabelFrame: CGRect                = .zero //写给谁
    var excellentImageViewFrame: CGRect     = .zero // 优秀记录
    var contentLabelFrame: CGRect           = .zero // 文字 内容
    var imageViewContainerViewFrame: CGRect = .zero // 图片内容的容器
    var byLabelFrame: CGRect                = .zero    // 发布者
    var goodImageViewFrame: CGRect          = .zero  // 赞
    var goodLabelFrame: CGRect              = .zero  //赞的个数
    
    var evaluateCalHeight : CGFloat = 0     //综合评语的内容高度
    
    var infoCellHeight: CGFloat = 0
    var evaluateCellHeight: CGFloat = 0
  
    init(record: CYJRecord, role: CYJRole?) {
        self.record = record
        
        if let rr = role {
            self.role = rr
        }else {
            self.role = (LocaleSetting.userInfo()?.role)!
        }
        
        layoutContainerView()
    }
    
    mutating func layoutContainerView() {
        //
        let x: CGFloat = leftBaseLine
        var y: CGFloat = 20
        //MARK: Left part
        dateLabelFrame = CGRect(x: x, y: y, width: width - 2 * x, height: 21)
        y = dateLabelFrame.maxY + 15
        
        excellentImageViewFrame = CGRect(x: x - 8 - 16, y: y+2, width: 16, height: 21)
        
        if role != .child {
            toLabelFrame = CGRect(x: x, y: y, width: width - 2 * x, height: 21)
            
            y = toLabelFrame.maxY + 15
        }
        
        
        
        //设置文本显示内中最大高度与最大宽度
        //1 成长记录描述内容 2 综合英语内容
        let size = CGSize(width: width - 80, height: CGFloat(MAXFLOAT))
        
        
        let calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
        
        contentLabelFrame = CGRect(x: x , y: y , width: size.width, height: calHeight)
        
        y += (calHeight + 15)
        
        var contentHeight: CGFloat = 0
        
        if let images =  record.photo {
            
            if images.count > 0 {
                let tmpFrame = CGRect(x: x, y: y, width: width, height: contentHeight)
                contentHeight = CYJRECImageViewContainer(frame: tmpFrame).configImageViewRects(imageCount: images.count)
                
                imageViewContainerViewFrame = CGRect(x: 0, y: y, width: width, height: contentHeight)
                
                y += (contentHeight + 15)
            }
        }
        byLabelFrame = CGRect(x: x, y: y, width: 250, height: 13)
        
        y += (8 + 13)
        
        if role != .child
        {
            goodImageViewFrame = CGRect(x: x, y: y, width: 13, height: 14)
            
            
            //MARK: 内容的最大高
            let goodsize = CGSize(width: size.width - goodImageViewFrame.maxX - 8, height: CGFloat(MAXFLOAT))
            let thumbHeight = record.thumbNameAttr.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            
            goodLabelFrame = CGRect(x: goodImageViewFrame.maxX + 8, y: y, width: goodsize.width , height: thumbHeight)
            
            infoCellHeight = goodLabelFrame.maxY + 20
        } else {
            infoCellHeight = y
        }
        
        evaluateCalHeight = record.contentAttr.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
        
        if evaluateCalHeight < 20 {
            evaluateCalHeight = 20
        }
        //readbackView、综合评分、记录客观、综合评语所有高度 + 间距 = 260 在加上 bottom间距  30
        evaluateCellHeight = CGFloat(260 + evaluateCalHeight + 30)
    }
}

/// RecordListCell 的高度
struct CYJRecordCellFrame {
    var isOtherClass : Bool = false
    var record: CYJRecord
    
    var leftBaseLine: CGFloat =  82.5
    
    var padding: CGFloat = 2
    
    var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    var role: CYJRole = (LocaleSetting.userInfo()?.role)!
    
    var dateLabelFrame: CGRect = .zero //时间
    var excellentImageViewFrame: CGRect = .zero // 优秀记录
    var userLabelFrame: CGRect = .zero // 记录的幼儿
    var deleteButtonFrame: CGRect = .zero //删除
    var contentLabelFrame: CGRect = .zero // 文字 内容
    var imageViewContainerViewFrame: CGRect = .zero // 图片内容的容器
    var firstImageViewFrame: CGRect = .zero // 图片1
    var secondImageViewFrame: CGRect = .zero    // 图片2
    var thirdImageViewFrame: CGRect = .zero // 图片3
    var forthImageViewFrame: CGRect = .zero // 图片4
    var byLabelFrame: CGRect = .zero    // 发布者
    var goodImageViewFrame: CGRect = .zero  // 赞
    var goodLabelFrame: CGRect = .zero  //赞的个数
    var replyImageViewFrame: CGRect = .zero // 回复
    var replyLabelFrame: CGRect = .zero // 回复的个数
    var readOverImageViewFrame: CGRect = .zero  // 已阅
    
    var goodButtonFrame: CGRect = .zero // 点赞按钮
    
    var separaLineFrame: CGRect = .zero // 自定义华丽丽的分割线
    var cellHeight: CGFloat = 0

    init(record: CYJRecord, role: CYJRole?) {
        if let rol = role {
            self.role = rol
        }else {
            self.role = (LocaleSetting.userInfo()?.role)!
        }
        self.record = record
        layoutContainerView()
    }
    
    init(record: CYJRecord, role: CYJRole? ,isOtherClass : Bool) {
        if let rol = role {
            self.role = rol
        }else {
            self.role = (LocaleSetting.userInfo()?.role)!
        }
        self.isOtherClass = isOtherClass
        self.record = record
        layoutContainerView()
    }
    
    mutating func layoutContainerView() {
        //
        var x: CGFloat = 15
        var y: CGFloat = 15
        //MARK: Left part
        dateLabelFrame = CGRect(x: x, y: y, width: 62.5, height: 21)
        
        y += 21
        excellentImageViewFrame = CGRect(x: x + 2, y: y + 10, width: 16, height: 21)
        
        //MARK: Right Part

        x = leftBaseLine
        y = 15
        let rightPartWidth = width - leftBaseLine - 15
        
        //如不是学生，显示记录幼儿信息和删除按钮
        if role != .child {
            //展示user  20 here for delete button
            userLabelFrame = CGRect(x: leftBaseLine, y: 15, width: rightPartWidth - 20 , height: 13)
            y += (12 + 15)
            
            deleteButtonFrame = CGRect(x: width - 30 - 15, y: 7.5, width: 30 , height: 30)
        }
        //MARK: 内容的最大高度
        let contentHeight: CGFloat = 80
        if let images =  record.photo {
            if images.count > 0 {
                if images.first?.filetype == 2 {
                    //视频
                    imageViewContainerViewFrame = CGRect(x: x, y: y, width: contentHeight, height: contentHeight)
                    //有东西
                    let size = CGSize(width: rightPartWidth - x, height: CGFloat(MAXFLOAT))
                    //            计算文字高度
                    var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    if calHeight > contentHeight {
                        calHeight = contentHeight
                    }
                    
                    contentLabelFrame = CGRect(x: x + contentHeight + 6 , y: y + 2, width: rightPartWidth - x - contentHeight - 6, height: calHeight)
                    y += contentHeight
                }else { //图片
                    
                    imageViewContainerViewFrame = CGRect(x: x, y: y, width: contentHeight, height: contentHeight)
                    
                    //有东西
                    let size = CGSize(width: rightPartWidth - x, height: CGFloat(MAXFLOAT))
                    //            计算文字高度
                    var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    if calHeight > contentHeight {
                        calHeight = contentHeight
                    }
                    
                    contentLabelFrame = CGRect(x: x + contentHeight + 6 , y: y, width: rightPartWidth - x, height: calHeight)
                    
                    switch images.count {
                    case 1:
                        firstImageViewFrame = CGRect(origin: .zero, size: imageViewContainerViewFrame.size)
                    case 2:
                        let twidth = (imageViewContainerViewFrame.width - padding) * 0.5
                        
                        firstImageViewFrame = CGRect(x: 0, y: 0, width: twidth, height: imageViewContainerViewFrame.height)
                        secondImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + padding*0.5, y: 0, width: twidth, height: imageViewContainerViewFrame.height)
                    case 3:
                        let twidth = (imageViewContainerViewFrame.width - CGFloat(padding)) * 0.5
                        let theight = (imageViewContainerViewFrame.height - CGFloat(padding)) * 0.5
                        
                        firstImageViewFrame = CGRect(x: 0, y: 0, width: twidth, height: imageViewContainerViewFrame.height)
                        
                        secondImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: twidth, height: theight)
                        
                        thirdImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: imageViewContainerViewFrame.height * 0.5 + CGFloat(padding) * 0.5, width: twidth, height: theight)
                    default:
                        let twidth = (imageViewContainerViewFrame.width - CGFloat(padding)) * 0.5
                        let theight = (imageViewContainerViewFrame.height - CGFloat(padding)) * 0.5
                        
                        firstImageViewFrame = CGRect(x: 0, y: 0, width: twidth, height: theight)
                        
                        secondImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: twidth, height: theight)
                        
                        thirdImageViewFrame = CGRect(x: 0, y: imageViewContainerViewFrame.height * 0.5 + CGFloat(padding) * 0.5, width: twidth, height: theight)
                        
                        forthImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: imageViewContainerViewFrame.height * 0.5 + CGFloat(padding) * 0.5, width: twidth, height: theight)
                    }
                    y += contentHeight
                    
                }
            }else
            {
                //没有东西
                let size = CGSize(width: rightPartWidth, height: CGFloat(MAXFLOAT))
                //            计算文字高度
                var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                
                if calHeight > contentHeight {
                    calHeight = contentHeight
                }
                
                contentLabelFrame = CGRect(x: x , y: y + 2, width: rightPartWidth, height: calHeight)
                y = y + calHeight + 2
            }
            
        }

        x = leftBaseLine
        y = y + 15
        
        if role == .master {
            byLabelFrame = CGRect(x: x, y: y, width: 180, height: 13)
        }else {
            if isOtherClass {
                byLabelFrame = CGRect(x: x, y: y, width: 186, height: 13)
            }else{
                byLabelFrame = CGRect(x: x, y: y, width: 100, height: 13)
            }

        }
        
        
//        print("y-parent\(y + 13 + 15)")
//        cellHeight = y + 13
        
        //Bottom
        if role == .teacher || role == .teacherL {
            
        
            if isOtherClass {
                replyLabelFrame = CGRect(x: width - 25 - 5, y: y, width: 25, height: 12)
                replyImageViewFrame = CGRect(x: replyLabelFrame.minX - 8 - 13, y: y + 1, width: 13, height: 11)
                
                goodLabelFrame = CGRect(x: replyImageViewFrame.minX - 8 - 25, y: y, width: 25, height: 12)
                goodImageViewFrame = CGRect(x: goodLabelFrame.minX - 5 - 12.5, y: y + 1.5, width: 12.5, height: 10.5)

            }else{
                goodImageViewFrame = CGRect(x: byLabelFrame.maxX+5, y: y + 1.5, width: 12.5, height: 10.5)
                goodLabelFrame = CGRect(x: goodImageViewFrame.maxX + 8, y: y, width: 30, height: 12)
                replyImageViewFrame = CGRect(x: goodLabelFrame.maxX + 35, y: y + 1, width: 13, height: 11)
                replyLabelFrame = CGRect(x: replyImageViewFrame.maxX + 8, y: y, width: 30, height: 12)
                
            }
            
            readOverImageViewFrame = CGRect(x: width - 35, y: y, width: 35, height: 30)
//            print("y-teacher\(y + 13 + 15)")
            cellHeight = y + 15 + 15
        }else if role == .master {
            
            goodImageViewFrame = CGRect(x: byLabelFrame.maxX+5, y: y, width: 16, height: 14)
            
            goodLabelFrame = CGRect(x: goodImageViewFrame.maxX + 8, y: y, width: 30, height: 12)
            
//            y = y + 15

            readOverImageViewFrame = CGRect(x: width - 35, y: y, width: 35, height: 30)
//            print("y-master\(y + 12 + 15)")
            cellHeight = y + 33

        }else if role == .child {
            goodButtonFrame = CGRect(x: width - 45, y: byLabelFrame.minY + 1.5, width: 12.5, height: 10.5)
            cellHeight = y + 30
        }
        
        separaLineFrame = CGRect(x: 5, y: y + 30, width: width - 10, height: 0.5)
    }
}

struct CYJRECCacheCellFrame {
    
    var record: CYJRecord
    
    var leftBaseLine: CGFloat =  82.5
    
    var padding: CGFloat = 2
    
    var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var dateLabelFrame: CGRect = .zero //时间
    var userLabelFrame: CGRect = .zero // 记录的幼儿
    var actionButtonFrame: CGRect = .zero //删除
    var contentLabelFrame: CGRect = .zero // 文字 内容
    var imageViewContainerViewFrame: CGRect = .zero // 图片内容的容器
    var firstImageViewFrame: CGRect = .zero // 图片1
    var secondImageViewFrame: CGRect = .zero    // 图片2
    var thirdImageViewFrame: CGRect = .zero // 图片3
    var forthImageViewFrame: CGRect = .zero // 图片4
    
    var cellHeight: CGFloat = 0
    
    init(record: CYJRecord) {
        self.record = record
        
        layoutContainerView()
    }
    
    mutating func layoutContainerView() {
        //
        var x: CGFloat = 15
        var y: CGFloat = 15
        //MARK: Left part
        dateLabelFrame = CGRect(x: x, y: y, width: 62.5, height: 21)
        
        //MARK: Right Part
        x = leftBaseLine
        y = 15
        let rightPartWidth = width - leftBaseLine - 15

        //展示user  20 here for delete button
            userLabelFrame = CGRect(x: leftBaseLine, y: 20, width: rightPartWidth - 20 , height: 13)
            y += (12 + 15)
            
            actionButtonFrame = CGRect(x: width - 30 - 15, y: 7.5, width: 30 , height: 30)
        
        //MARK: 内容的最大高度
        let contentHeight: CGFloat = 80
        if let images =  record.photo {
            
            if images.count > 0 {
                if record.photo?.first?.filetype == 2{
                    imageViewContainerViewFrame = CGRect(x: x, y: y, width: contentHeight, height: contentHeight)
                    //有东西
                    let size = CGSize(width: rightPartWidth - x, height: CGFloat(MAXFLOAT))
                    //            计算文字高度
                    var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    if calHeight > contentHeight {
                        calHeight = contentHeight
                    }
                    
                    contentLabelFrame = CGRect(x: x + contentHeight + 6 , y: y + 2, width: rightPartWidth - x - contentHeight - 6, height: calHeight)
                    y += contentHeight
                }else {
                    
                    imageViewContainerViewFrame = CGRect(x: x, y: y, width: contentHeight, height: contentHeight)
                    
                    //有东西
                    let size = CGSize(width: rightPartWidth - x, height: CGFloat(MAXFLOAT))
                    //            计算文字高度
                    var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                    
                    if calHeight > contentHeight {
                        calHeight = contentHeight
                    }
                    
                    contentLabelFrame = CGRect(x: x + contentHeight + 6 , y: y + 2, width: rightPartWidth - x, height: calHeight)
                    
                    switch images.count {
                    case 1:
                        firstImageViewFrame = CGRect(origin: .zero, size: imageViewContainerViewFrame.size)
                    case 2:
                        let twidth = (imageViewContainerViewFrame.width - padding) * 0.5
                        
                        firstImageViewFrame = CGRect(x: 0, y: 0, width: twidth, height: imageViewContainerViewFrame.height)
                        secondImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + padding*0.5, y: 0, width: twidth, height: imageViewContainerViewFrame.height)
                    case 3:
                        let twidth = (imageViewContainerViewFrame.width - CGFloat(padding)) * 0.5
                        let theight = (imageViewContainerViewFrame.height - CGFloat(padding)) * 0.5
                        
                        firstImageViewFrame = CGRect(x: 0, y: 0, width: twidth, height: imageViewContainerViewFrame.height)
                        
                        secondImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: twidth, height: theight)
                        
                        thirdImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: imageViewContainerViewFrame.height * 0.5 + CGFloat(padding) * 0.5, width: twidth, height: theight)
                    default:
                        let twidth = (imageViewContainerViewFrame.width - CGFloat(padding)) * 0.5
                        let theight = (imageViewContainerViewFrame.height - CGFloat(padding)) * 0.5
                        
                        firstImageViewFrame = CGRect(x: 0, y: 0, width: twidth, height: theight)
                        
                        secondImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: 0, width: twidth, height: theight)
                        
                        thirdImageViewFrame = CGRect(x: 0, y: imageViewContainerViewFrame.height * 0.5 + CGFloat(padding) * 0.5, width: twidth, height: theight)
                        
                        forthImageViewFrame = CGRect(x: imageViewContainerViewFrame.width * 0.5 + CGFloat(padding) * 0.5, y: imageViewContainerViewFrame.height * 0.5 + CGFloat(padding) * 0.5, width: twidth, height: theight)
                    }
                    y += contentHeight
                    
                }
                
            }else{
                //没有东西
                let size = CGSize(width: rightPartWidth, height: CGFloat(MAXFLOAT))
                //            计算文字高度
                var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
                
                if calHeight > contentHeight {
                    calHeight = contentHeight
                }
                
                contentLabelFrame = CGRect(x: x , y: y + 2, width: rightPartWidth - x, height: calHeight)
                y = y + calHeight + 2
            }
        }else {
            //没有东西
            let size = CGSize(width: rightPartWidth, height: CGFloat(MAXFLOAT))
            //            计算文字高度
            var calHeight = record.attrContent.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            
            if calHeight > contentHeight {
                calHeight = contentHeight
            }
            
            contentLabelFrame = CGRect(x: x , y: y + 2, width: rightPartWidth - x, height: calHeight)
            y = y + calHeight + 2
        }
        cellHeight = y + 15
    }
}
