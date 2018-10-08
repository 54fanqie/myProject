//
//  CYJRECDetailEvaluateController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

/// 分页详情的评分的页面
class CYJRECDetailEvaluateController: KYBaseTableViewController {
    
    var grId: Int = 0
    var ownerId: Int = 0
    
    var evaluates: [CYJRecordEvaluate] = []
    var evaluateFrames: [CYJEvaluateForRecordFrame] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 44 - Theme.Measure.navigationBarHeight)
        
        tableView.register(CYJRECDetailCommentCell.self, forCellReuseIdentifier: "CYJRECDetailCommentCell")
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.fetchStudentDataSource()
    }
    
    func fetchStudentDataSource() {
        
        let parameter: [String: Any] = ["token" : LocaleSetting.token, "grId" : self.grId]
        
        RequestManager.POST(urlString: APIManager.Record.student, params: parameter ) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.hide {}
                self.statusUpdated(success: false)
                
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self.statusUpdated(success: true)
            
            //使用之前，清空 数据源
            if let evaluates = data as? NSArray {
                //遍历，并赋值
                self.evaluateFrames.removeAll()

                evaluates.forEach({ [unowned self] in
                    let target = JSONDeserializer<CYJRecordEvaluate>.deserializeFrom(dict: $0 as? NSDictionary)
                    self.evaluates.append(target!)
                    let frame = CYJEvaluateForRecordFrame(target!, owner: self.ownerId)
//                    frame.ownerId = self.ownerId
                    self.evaluateFrames.append(frame)
                })
                self.tableView.reloadData()

                //FIXME: 刷新 recordParam.隐藏，并刷新UI
                Third.toast.hide {}
            }
            
        }
    }
    func addReplayToParent(index: Int, content: String) {
        
        let evaluate = self.evaluates[index]
        if let comment = evaluate.comment {
            
            let parameter = CYJRECCommentParam()
            parameter.grId = self.grId
            parameter.coId = comment.coId
            parameter.type = false
            parameter.content = content
            //FIXME: 测试
//            self.fetchStudentDataSource()
//            self.tableView.deleteSections([0], with: .none)

            RequestManager.POST(urlString: APIManager.Record.comment, params: parameter.encodeToDictionary()) { [weak self] (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                evaluate.comment?.reply = content
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    //更新frame，
                    var frame =  self?.evaluateFrames[index]
                    frame = CYJEvaluateForRecordFrame(evaluate, owner: evaluate.uId)
                    
                    self?.evaluateFrames[index] = frame!
                    self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    
                })
                Third.toast.message("回复成功", hide: {
                })
            }
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.evaluateFrames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJRECDetailCommentCell") as! CYJRECDetailCommentCell
        cell.selectionStyle = .none
        cell.ownerId = self.ownerId  //得分先后啊！ 傻叉
        cell.calFrame = self.evaluateFrames[indexPath.row]
        cell.replayHandler = { [unowned self] in  //执行replay的操作
            guard let index = tableView.indexPath(for: $0) else{
                return
            }
            //MARK: 教师发起回复
            let insertC = CYJInputViewOutletController(title: "回复", placeholder: "请输入您的回复", actionHandler: { [weak self](inoutC, content) in
                inoutC.navigationController?.popViewController(animated: true)
                self?.addReplayToParent(index: index.row, content: content)
                
            })
            self.navigationController?.pushViewController(insertC, animated: true)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //
        return self.evaluateFrames[indexPath.row].cellHeight
    }
    
}
