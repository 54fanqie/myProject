//
//  CYJRECBuildFirstViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit


class CYJRECBuildFirstViewController: UIViewController {

    var dynamicTree: FQDynamicTree!
    var allDomains: [CYJDomain]!
    //父节点滚动视图
    var fatherNodes: [KYDynamicTreeNode] = []
    
    /// 记录当前选中的下标
     var currentIndex = 0

    //指标标题
    var evaluateScoreSegmentView : EvaluateScoreSegmentView!
    /// 整个界面通过recordParam 创建
    var recordParam : CYJNewRECParam {
        return CYJRECBuildHelper.default.recordParam
    }
    
    var flag: Int = 0
    
    var evaluate: CYJNewRECParam.ChildEvaluate {
        return self.recordParam.info[flag]
    }
    var selectedNodes = [KYDynamicTreeNode]() {
        didSet{
            if let com = IamChangedHandler {
                com(selectedNodes.count > 0)
            }
        }
    }
    
    var IamChangedHandler: CYJCompleteHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.theme_backgroundColor = Theme.Color.ground
        // Do any additional setup after loading the view.
        
        self.makeData()
        
        if self.fatherNodes.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 35, y: 100, width: Theme.Measure.screenWidth - 70, height: 100))
            emptyLabel.text = "该年级园长未设置成评价指标，暂不能设置评分"
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.lineBreakMode = .byWordWrapping
            emptyLabel.theme_textColor = Theme.Color.textColorlight
            view.addSubview(emptyLabel)
        }else {
            // 健康维度滚动条
            var titles = [String]()
            self.fatherNodes.forEach { (domain) in
                titles.append(domain.name!)
            }
            //评比状态
            var markCounts = [Int]()
            self.fatherNodes.forEach { (domain) in
                markCounts.append(domain.markedCount)
            }
            
            //指标scroView高度
            let hearHight : CGFloat = 80
            evaluateScoreSegmentView = EvaluateScoreSegmentView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: hearHight), titles: titles, status: markCounts)
        
            dynamicTree = FQDynamicTree(frame: CGRect(x: 0, y: hearHight, width: view.frame.width, height: Theme.Measure.screenHeight - 64 - 58 - 8 - 44 - 44 ), nodes: self.fatherNodes[0].subNodes)
            dynamicTree.delegate = self
            dynamicTree.flag = self.flag
            view.addSubview(dynamicTree)
            
            // 避免循环引用
            evaluateScoreSegmentView.titleBtnOnClick = {[unowned self] (label: UILabel, index: Int) in
                self.currentIndex = index
                print("已选中选项数量:" + "\(self.fatherNodes[index].markedCount)")
                // 切换内容数据源
                self.dynamicTree.reloadData(nodes: self.fatherNodes[index].subNodes)
            }
            view.addSubview(evaluateScoreSegmentView)
            
            //监听是否选择已评论：增加flage配置区分多个幼儿情况，通知混乱
            NotificationCenter.default.addObserver(self, selector: #selector(changeMarkCount), name: NSNotification.Name(rawValue:"updataMarkCount" + "\(self.flag)"), object: nil)
            
        }
    }
    
    deinit {
        /// 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    func changeMarkCount(info:NSNotification)  {
        print(info.object ?? 0)
        let fatherNode = self.fatherNodes[self.currentIndex]
        //1为选择了选项 0为取消了选项
        if info.object as! Int == 0  {
            fatherNode.markedCount -= 1
        }else{
            fatherNode.markedCount += 1
        }
        self.evaluateScoreSegmentView.reloadMarkCount(markedCount: fatherNode.markedCount)
        
        var markedCount = 0
        self.fatherNodes.forEach { (dynamicTreeNode) in
            print(String(format: "第%d个学生:%d", self.flag,dynamicTreeNode.markedCount))
            markedCount += dynamicTreeNode.markedCount
        }
        print(markedCount)
        /// 发送是否已评状态,个人新头像上状态
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "updataHeaderMark"), object:nil, userInfo: ["mark" :markedCount ])
    }
    
    func makeData() {
        
        let evaluate = self.recordParam.info[self.flag]
        let allSelected = evaluate.lId
        let allSelectedDID = evaluate.dId
        let allSelectedDiID = evaluate.diId
        let allSelectedQid = evaluate.qId
        
        
        self.allDomains.forEach { (domain) in
            let dnode = KYDynamicTreeNode()
            dnode.shouldSelected = false
            dnode.fatherNodeId = nil
            dnode.nodeId = "domain-" + "\(domain.dId ?? 0)"
            dnode.name = domain.dName
            dnode.shouldOpen = true
            dnode.ext = ["name":"百旺科技有限公司", "count": "3"]
            dnode.markedCount = allSelectedDID.filter({ $0 == "\(domain.dId ?? 0)"}).count
            fatherNodes.append(dnode)
            
            //标题子节点列表
            domain.dimension?.forEach({ (dimension) in
                let dinode = KYDynamicTreeNode()
                dinode.floor = 0
                dinode.shouldOpen = true
                dinode.shouldSelected = false
                //此处fatherNodeId必须设置为nil，这样是为了判断,此处就为根节点，否者就报错
                dinode.fatherNodeId = nil
                dinode.nodeId = "dimension" + dimension.diId!
                dinode.name = dimension.diName
                dinode.ext = ["name":"任我行国际科技有限公司", "count": "3"]
                dinode.markedCount = allSelectedDiID.filter({ $0 == "\(dimension.diId ?? "0")"}).count
                

                //详情子节点列表
                dnode.subNodes.append(dinode)
                dimension.quota?.forEach({ (quota) in
                    let qunode = KYDynamicTreeNode()
                    qunode.floor = 1
                    qunode.shouldSelected = false
                    qunode.shouldOpen = true
                    qunode.fatherNodeId = dinode.nodeId
                    qunode.nodeId = "quota" + quota.qId!
                    qunode.name = quota.qTitle
                    qunode.markedCount = allSelectedQid.filter({ $0 == "\(quota.qId ?? "0")"}).count
                    //颜色FFFF00
                    qunode.nodeColor = UIColor(hex: quota.zbColo!, alpha: 1)
                    dnode.subNodes.append(qunode)
                    
                    
                    if !(quota.zbDes?.isEmpty)! || !(quota.zbGive?.isEmpty)!{
                        let lenode = KYDynamicTreeNode()
                        lenode.floor = 2
                        lenode.shouldOpen = false
                        lenode.shouldSelected = true
                        lenode.fatherNodeId = qunode.nodeId
                        lenode.haveDetail = true
                        //指标介绍、举例
                        lenode.nodeDetail = quota.zbDes
                        lenode.nodeDetailDemo = quota.zbGive
                        dnode.subNodes.append(lenode)
                    }
                    
                    
                    quota.level?.forEach({ (level) in
                        let lenode = KYDynamicTreeNode()
                        lenode.floor = 2
                        lenode.shouldOpen = false
                        lenode.shouldSelected = true
                        lenode.fatherNodeId = qunode.nodeId
                        lenode.nodeId = "level-" + level.lId!
                        lenode.name = level.lName
                        lenode.ext = ["lId": "\(level.lId!)"]
                        
                            if allSelected.contains("\(level.lId!)") {
                                lenode.isSelected = true
                                selectedNodes.append(lenode)
                            }
                        dnode.subNodes.append(lenode)
                    })
                })
            })
        }
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CYJRECBuildFirstViewController: FQDynamicTreeDelegate {
    func scroDynamicTree(directionUp: Bool) {
        
    }
    
    func dynamicTree(_ dynamicTree: FQDynamicTree, didSelectedRowWith node: KYDynamicTreeNode) {
        //
    }
    func dynamicTree(_ dynamicTree: FQDynamicTree, didSelectedStatusButtonWith node: KYDynamicTreeNode) {
        // 查找相同父id的内容，如果存在，那么更新，否则直接加！
        
        if node.isSelected { //选中当前
            if let index = selectedNodes.index(where: {$0.fatherNodeId == node.fatherNodeId}) {
                selectedNodes[index] = node
            }else
            {
                selectedNodes.append(node)
            }
        }else
        {
            //取消选中当前
            if let index = selectedNodes.index(where: {$0.fatherNodeId == node.fatherNodeId}) {
                selectedNodes.remove(at: index)
            }
        }
    }
}












