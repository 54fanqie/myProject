//
//  CYJRECControllerViewByParent.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import HandyJSON

class CYJRECCommentParam: CYJParameterEncoding {
    var token = LocaleSetting.token
    var grId: Int = 0 //    Y    成长记录id
    var type: Bool = true  //  Y    1评论 2回复  false 是回复
    var coId: Int?    //N    被回复的评论id 当type为2时 必填
    var content: String?   // Y    回复内容
    var isPraised: Int = 0   // Y    是否点赞，0否1是
}

class CYJRECControllerViewByParent: KYBaseTableViewController {
    
    var grId: Int = 0
    
    var userId: Int = 0
    
    var record: CYJRecord?
    
    var listRecord: CYJRecord?
    
    var infoCellFrame: CYJRECDetailCellFrame?
    
    var evaluate: CYJRecordEvaluate?
    
    var evaluateCellFrame: CYJEvaluateForRecordParentFrame?
    
    var commentParam: CYJRECCommentParam?
    
    var commentBar: CYJRECDetailBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "成长记录查看"
        tableView.register(CYJRECDetailInfoCell.self, forCellReuseIdentifier: "CYJRECDetailInfoCell")
        tableView.register(CYJRECDetailScoreCellParent.self, forCellReuseIdentifier: "CYJRECDetailScoreCellParent")
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 64 + 62, 0)
        
        self.fetchDataSource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
    
    /// 创建Bar
    func addCommentView() {
        //MARK: 只有当角色为家长时@！！！创建bar
        guard LocaleSetting.userInfo()?.role == .child else{
            return
        }
        
        self.commentBar = CYJRECDetailBarView(frame: CGRect(x: 0, y: Theme.Measure.screenHeight - 58, width: Theme.Measure.screenWidth, height: 58))
        
        self.commentBar?.goodActionHandler = { [unowned self] (sender) in
            
            let parameter: [String: Any] = ["grId" : self.grId, "token": LocaleSetting.token]
            
            RequestManager.POST(urlString: APIManager.Record.praise, params: parameter) { [weak sender, unowned self](data, error) in
                //如果存在error
                guard error == nil else {
                    sender?.isSelected = false
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                // 更新自己的页面，再更新外面list 的页面
                self.record?.isPraised = 1
                self.listRecord?.isPraised = 1
                self.commentBar?.isPraised = true
                Third.toast.message("点赞成功")
            }
        }
        self.commentBar?.sendActionHandler = { [unowned self] in
            
            if let text = $0 {
                DLog(text)
                self.uploadComment(text)
            }
        }
        
        view.addSubview(self.commentBar!)
    }
    
    
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Record.info, params: ["token": LocaleSetting.token, "grId": "\(self.grId)"]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let recordDetail = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<CYJRecord>.deserializeFrom(dict: recordDetail)
                self.record = target
                self.infoCellFrame = CYJRECDetailCellFrame(record: target!, role: .child)
                //createUI
                self.tableView.reloadData()
                
                if LocaleSetting.userInfo()?.role == .teacher || LocaleSetting.userInfo()?.role == .teacherL {
                    //是老师
                    if self.record?.isMine == 1 {
                        self.fetchStudentsFromServer()
                    }
                }else if LocaleSetting.userInfo()?.role == .child {
                    //是家长
                    self.fetchStudentsFromServer()
                }
                
            }
        }
    }
    
    func fetchStudentsFromServer() {
        
        RequestManager.POST(urlString: APIManager.Record.student, params: ["token": LocaleSetting.token, "grId" : "\(self.grId)"]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                self.statusUpdated(success: false)
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self.statusUpdated(success: true)
            if let evaluates = data as? NSArray {
                //遍历，并赋值
                evaluates.forEach({ [unowned self] in
                    let target = JSONDeserializer<CYJRecordEvaluate>.deserializeFrom(dict: $0 as? NSDictionary)
                    
                    if self.userId == target?.uId {
                        self.evaluate = target
                        
                        self.evaluateCellFrame = CYJEvaluateForRecordParentFrame(self.evaluate!)
                        self.tableView.reloadData()
                        
                        //添加底部 回复空间
                        self.addCommentView()
                        
                        // 是否点赞
                        self.commentBar?.isPraised = self.record?.isPraised == 1
                        
                        // 是否 已评论
                        if let _ = self.evaluate?.comment?.content {
                            //FIXME: edit commentView
                            self.commentBar?.isCommented = true
                        }else
                        {
                            self.commentBar?.isCommented = false
                        }
                        //bar 允许编辑
                        self.commentBar?.editingEnabled = true
                    }
                })
                
                self.tableView.reloadData()
            }
        }
    }
    
    func uploadComment(_ content: String) {
        
        let text = content
        guard !(text.isEmpty) else {
            return
        }
        
        //        添加输入框的话， 先创建parameter
        self.commentParam = CYJRECCommentParam()
        self.commentParam?.grId = self.grId
        self.commentParam?.type = true //
        self.commentParam?.content = text
        
        guard let commentParamater = self.commentParam else{
            Third.toast.message("error - retry it！")
            return
        }
        
        
        Third.toast.show {}
        RequestManager.POST(urlString: APIManager.Record.comment, params: commentParamater.encodeToDictionary()) { [unowned self] (data, error) in
            //如果存在error
            Third.toast.hide {}
            
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            Third.toast.message("评论成功")
            //TODO: 评论成功的话，刷行barVIew
            self.commentBar?.replaySuccess()
            
            self.fetchStudentsFromServer()
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.record == nil ? 0 : 1
        }else  {
            return self.evaluate == nil ? 0 : 1
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.0001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CYJRECDetailInfoCell") as? CYJRECDetailInfoCell
            cell?.selectionStyle = .none
            
            cell?.infoFrame = infoCellFrame
            cell?.imageClickHandler = { [unowned self] in
                DLog("imageClickHandler\($0)")
                if self.record?.photo?.first?.filetype == 2 {
                    //FIXME: 打开视频
                    if let url = self.record?.photo?.first?.videoPath {
                        //FIXME: 打开视频
                        if url.hasSuffix(".mp4") {
                            let playerC = PlayViewController()
                            playerC.vedioUrl = url
                            playerC.coverImageUrl = self.record?.photo?.first?.url
                            self.navigationController?.pushViewController(playerC, animated: true)
                        }else {
                            Third.toast.message("视频正在转码中，请稍后")
                        }
                    }
                    
                }else
                {
                    if let imageUrls = $0.2 {
                        let imagesArr: [KYImageResource] = imageUrls.map({ (url) -> KYImageResource in
                            return KYImageResource(image: nil, imageURLString: url)
                        })
                        KYImageViewer.showImages(imagesArr, atIndex: $0.0, fromSenderArray: $0.3)
                    }
                }
            }
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CYJRECDetailScoreCellParent") as? CYJRECDetailScoreCellParent
            cell?.selectionStyle = .none
            cell?.calFrame = evaluateCellFrame
            
            return cell!
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //
        switch indexPath.section {
        case 0:
            return infoCellFrame?.infoCellHeight ?? 0
        case 1:
            return evaluateCellFrame?.cellHeight ?? 0
        default:
            return 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let _ = self.commentBar?.superview {
            self.commentBar?.endEditing(true)
        }
    }
}




