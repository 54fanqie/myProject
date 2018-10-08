//
//  CYJRECBuildHelper.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/21.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJNewRECParam: NSObject {
    
    var grId: Int = 0
    
    var rTime: String = Date().stringWithYMD()
    var token: String = LocaleSetting.token
//    var children: [ChildEvaluate] = []
    
    var photo: [CYJMediaImage] = []
    var filetype: Int = 0 // 1图片 2视频
    var describe: String? //行为表现描述
    
    var info: [ChildEvaluate] = []
    var fileId: String? // 视频id
    
    var type: Int = 1 //1暂存，2完成
    
    var mark: Int = 0  //当mark为1时清除数据
    
    class ChildEvaluate: CYJParameterEncoding {
        var bId: Int = 0 //幼儿id
        var name: String? //幼儿名称
        var lId: [String] = []//幼儿选择的维度，逗号分隔或者数组
        var diId: [String] = []
        var dId: [String] = []
        var qId: [String] = []
        var content: String? //对幼儿的评论建议
        var avatar: String?
        var ignorePropreties: [String] {
            return ["avatar", "bId", "diId", "dId", "qId"]
        }
    }
    func getValues(record: CYJRecord) {
        self.grId = record.grId
        self.rTime = record.rTime!
        self.describe = record.describe
        self.type = 1
        
        self.info = record.user.map({
            let evaluate = ChildEvaluate()
            evaluate.bId = $0.uId
            evaluate.name = $0.realName
            return evaluate
        })
        
        if let firstPhoto = record.photo?.first
        {
            if firstPhoto.filetype == 2 { //视频
                self.fileId = firstPhoto.videoId
                self.filetype = 2
                // photo 里面存储的是 video的视频Coverimage
                let videoImage = CYJMediaImage()
                videoImage.url = firstPhoto.url
                videoImage.size = firstPhoto.size
                videoImage.suffix = firstPhoto.suffix
                videoImage.oldName = firstPhoto.oldName
                videoImage.fileType = 2
                videoImage.videoPath = firstPhoto.videoPath
                self.photo = [videoImage]
            }else
            {
                self.filetype = 1
                let recordPhote = record.photo!
                self.photo =  recordPhote.map({ (media) -> CYJMediaImage in
                    let mediaImage = CYJMediaImage()
                    mediaImage.url = media.url
                    mediaImage.size = media.size
                    mediaImage.suffix = media.suffix
                    mediaImage.oldName = media.oldName
                    return mediaImage
                })
            }
        }
    }
    
    func getValues(evaluates: [CYJRecordEvaluate]) {
        
        for i in 0..<self.info.count {
            
            let evaluate = evaluates[i]
            let oldEvaluate = self.info[i]
            
            oldEvaluate.bId = evaluate.uId
            oldEvaluate.content = evaluate.content
            oldEvaluate.avatar = evaluate.avatar
            
            if let quoto = evaluate.quota {
                oldEvaluate.lId = quoto.map({ return $0.lId ?? "0" })
                oldEvaluate.qId = quoto.map({ return $0.qId ?? "0" })
                oldEvaluate.diId = quoto.map({ return $0.diId ?? "0" })
                oldEvaluate.dId = quoto.map({ return $0.dId ?? "0" })
            }
        }
    }
    
    func encodeToDictionary() -> [String: Any] {
        
        var param = [String: Any]()
        
        if grId != 0 {
            param["grId"] = self.grId
        }
        
        param["rTime"] = self.rTime
        param["token"] = self.token
        
        var info = [String: Any]()
        for i in 0..<self.info.count {
            let evaluate = self.info[i]
            let child = evaluate.encodeToDictionary()
            
            info["\(evaluate.bId)"] = child
        }
        param["info"] = toJSONString(dict: info)
        
        if self.filetype == 2 {
            param["fileId"] = self.fileId
            param["filetype"] = "2"

        }else if self.filetype == 1{
            var photoDict = [[String: Any]]()
            for i in 0..<photo.count {
                let media = self.photo[i]
                photoDict.append(media.encodeToDictionary())
            }
            param["photo"] = toJSONString(dict: photoDict)
            param["filetype"] = "1"

        }
        param["describe"] = self.describe ?? "" //    Y    行为表现描述
        param["type"] = self.type //
        param["mark"] = self.mark //

        return param
    }
    
    func toJSONString(dict: Any)-> String{
        do {

            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let strJson = String(data: data, encoding: .utf8)
            return strJson ?? ""
        }catch
        {
            return ""
        }
    }
}

/// 新建成长记录
enum RecordBuildStep {
    case new  //新建
    case cached(IndexPath)
    case uploaded
    case published(IndexPath?)
    
    mutating func next() {
        switch self {
        case .new:
            self = .uploaded
        default:
            break
        }
    }
    mutating func publish() {
        switch self {
        case .uploaded:
            self = .published(nil)
        case .cached(let indexPath):
            self = .published(indexPath)
        default:
            break
        }
    }
}
class CYJRECBuildHelper: NSObject {
    
    static let `default` =  CYJRECBuildHelper()
    
    override init() {
        super.init()
        print("build Once")
        buildStep = .new
    }
    

//        case editInfo //编辑edit
//        case newScore // 新建score
//        case editScore //从编辑的条件下更改Score
        
//        /// 保存 new => editInfo
//        mutating func saveInfo() {
//            switch self {
//            case .new:
//                self = .editInfo
//            default:
//                self = .editInfo
//            }
//        }
//
//        /// 保存 new => editInfo
//        mutating func saveScore() {
//            switch self {
//            case .newScore:
//                self = .editScore
//            default:
//                self = .editScore
//            }
//        }
//
//        mutating func nextStep() {
//            switch self {
//            case .new:
//                self = .newScore
//            default:
//                self = .editScore
//            }
//        }
//    }
    
    func resetParam() {
        _recordParam = CYJNewRECParam()
    }
    
    /// 每次设置为new 或者 editInfo 都刷新paramter
    var buildStep: RecordBuildStep = .new
        
    var recordParam: CYJNewRECParam {
        return _recordParam
    }
    private var _recordParam: CYJNewRECParam!
    
    
}


