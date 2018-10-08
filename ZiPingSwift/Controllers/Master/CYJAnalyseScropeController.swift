//
//  CYJAnalyseScropeController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/29.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON

class CYJAnalyseScropeController: KYBaseTableViewController {
    
    var dataS: [[KYDynamicTreeNode]] = []
    
    var nodes: [KYDynamicTreeNode] = []
    
    var domains: [CYJDomain] = []
    
    var selectedDids = [String]()
    var selectedDiids = [String]()
    
    var selectedNodes : [KYDynamicTreeNode] = []
    
    var completeClosure: ((_ domains: [String], _ demensions: [String])->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //input code here
        
        self.title = "选择分析范围"
        
        nodes = makeData()
        configRootNode()
        
        
        let button:UIButton = UIButton(type:.system)
        //设置按钮位置和大小
        button.frame = CGRect(x:(Theme.Measure.screenWidth - 120)/2, y:Theme.Measure.screenHeight - 60, width:120, height:40)
        button.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        button.theme_backgroundColor = Theme.Color.main
        button.setTitle("提 交", for:.normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(surebuttonClick), for: .touchUpInside)
        view.addSubview(button)
        
        
        tableView.register(UINib(nibName: "KYDynamicCell", bundle: nil), forCellReuseIdentifier: "KYDynamicCell")
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    fileprivate func configRootNode() -> Void {
        let rootNodes = nodes.filter {$0.isRoot}
        guard rootNodes.count > 0 else {
            fatalError("根结点不能为空")
        }
        let tmpDataSource = rootNodes.map { (node) -> [KYDynamicTreeNode] in
            return [node]
        }
        dataS.append(contentsOf: tmpDataSource)
    }
    
    func makeData() -> [KYDynamicTreeNode] {
        //北京大洋国际科技有限公司
        var arr = [KYDynamicTreeNode]()
        
        self.domains.forEach { (domain) in
            
            //财务部
            let dd = KYDynamicTreeNode()
            dd.shouldSelected = true
            dd.fatherNodeId = nil
            dd.nodeId = "domain-\(domain.dId ?? 0)"
            dd.name = domain.dName
            dd.ext = ["dId":"\(domain.dId ?? 0)"]
            dd.shouldOpen = true
            
            if self.selectedDids.contains(where: { $0 == "\(domain.dId ?? 0)" }) {
                dd.isSelected = true
                dd.isOpen = true
            }
            
            arr.append(dd)
            
            domain.dimension?.forEach({ (dimension) in
                let ddd = KYDynamicTreeNode()
                ddd.shouldSelected = true
                ddd.fatherNodeId = dd.nodeId
                ddd.nodeId = "demension-" + dimension.diId!
                ddd.name = dimension.diName
                ddd.ext = ["diId":"\(dimension.diId!)"]
                ddd.shouldOpen = false
                if self.selectedDiids.contains(where: { $0 == dimension.diId}) {
                    ddd.isSelected = true
                }
                arr.append(ddd)
            })
        }
        
        return arr
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //input code here
    }
}

//MARK: make UI
extension CYJAnalyseScropeController {
    
    func addSubNodes(by fatherNode: KYDynamicTreeNode, at indexPath: IndexPath) {
        
        var indexPaths = [IndexPath]()
        var notesArray = dataS[indexPath.section]
        let subNodes = nodes.filter {
            if $0.fatherNodeId == fatherNode.nodeId {
//                $0.originX = fatherNode.originX + 10
                $0.floor = fatherNode.floor + 1
                indexPaths.append(IndexPath(row: indexPath.row + 1, section: indexPath.section))
                return true
            }
            return false
        }
        if subNodes.count > 0 {
            fatherNode.isOpen = true
            fatherNode.subNodes = subNodes
            
            notesArray.insert(contentsOf: subNodes, at: indexPath.row + 1)
            dataS[indexPath.section] = notesArray
            tableView.reloadData()
        }
    }
    
    func getRootNode(by note: KYDynamicTreeNode) -> KYDynamicTreeNode {
        var root = note
        if root.fatherNodeId != nil {
            root =  getRootNode(by:root)
        }
        return root
    }
    
    func minusNodes(by node: KYDynamicTreeNode, at indexPath: IndexPath) -> Void {
        
        let tmpArray = dataS[indexPath.section]
        
        tmpArray.forEach {(targetNode) in
            if targetNode.fatherNodeId == node.nodeId {
                
                if targetNode.subNodes.count > 0 {
                    //先清除子节点信息，
                    self.minusNodes(by: targetNode, at: indexPath)
                }
                // 再清除当前节点信息
                let index = dataS[indexPath.section].index(of: targetNode)
                var notesArray = dataS[indexPath.section]
                notesArray.remove(at: index!)
                dataS[indexPath.section] = notesArray
            }
        }
        
        node.isOpen = false
    }
}
//MARK: click method
extension CYJAnalyseScropeController {
    
    func surebuttonClick() {
        
        let tmp = nodes.filter { $0.isSelected == true }
        
        print("result.count +++++++++=\(tmp.count)")
        if let completeClosure = self.completeClosure {
            
            var dids = [String]()
            var diids = [String]()
            tmp.forEach({ (nod) in
                if nod.fatherNodeId == nil {
                    dids.append((nod.ext?["dId"])!)
                }else
                {
                    diids.append((nod.ext?["diId"])!)
                }
            })
            
//            let domains = tmp.map({ (node) -> CYJDomain in
//                let domain = CYJDomain()
//                domain.dId = Int(node.nodeId!)
//                return domain
//            })
            
            completeClosure(dids, diids)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension CYJAnalyseScropeController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataS.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataS[section].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let node = dataS[indexPath.section][indexPath.row]
        
        return node.shouldSelected ? 38 : 44
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KYDynamicCell") as? KYDynamicCell
        let node = dataS[indexPath.section][indexPath.row]

        cell?.selectionStyle = .none
        cell?.node = node
        cell?.delegate = self
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = dataS[indexPath.section][indexPath.row]
        
        if node.isOpen {
            minusNodes(by: node, at: indexPath)
            
            tableView.reloadData()
            
        }else
        {
            addSubNodes(by: node, at: indexPath)
        }
    }
}

extension CYJAnalyseScropeController: KYDynamicCellDelegate {
    
    func dynamicCell(_ dynamicCell: KYDynamicCell, didClicked statusButton: UIButton) {
        print("didClicked")
        
        if let node = dynamicCell.node {
            node.isSelected = !node.isSelected
//            if self.selectedNodes.contains(where: <#T##(KYDynamicTreeNode) throws -> Bool#>)
        }
        
        tableView.reloadData()
    }
}
