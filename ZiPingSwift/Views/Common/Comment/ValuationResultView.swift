//
//  ValuationResultView.swift
//  ZiPingSwift
//
//  Created by fanqie on 2018/8/9.
//  Copyright © 2018年 Chinayoujiao. All rights reserved.
//

import UIKit

class ValuationResultView: UIView {
    
    fileprivate var tableView: UITableView!
    var tabelHeaderView :UIView!
    var headerTitleView : HeaderTitleView!
    var dataArray = [NSDictionary]()
    //空白情况界面数据
    var nodataView : NoPartakeViewController!
    var  teacherResultList = [TeacherResult]() {
        didSet{
            if teacherResultList.isEmpty {
                addSubview(nodataView.view)
            }else{
                addSubview(tableView)
                for teacherResult in teacherResultList {
                    let dict = getData(teacherResult: teacherResult)
                    dataArray.append(dict)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ValuationResultCell", bundle: nil), forCellReuseIdentifier: "ValuationResultCell")
        //        tableView.register(ValuationResultCell.self, forCellReuseIdentifier:  "ValuationResultCell")
        tableView.separatorStyle = .none
        
        //表头
        tabelHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 61))
        tableView.tableHeaderView = tabelHeaderView
        
        headerTitleView = HeaderTitleView(frame: CGRect(x: 0, y: 16, width: frame.width, height: 46));
        tabelHeaderView.addSubview(headerTitleView)
        headerTitleView.typeData = ["  \n总分","认知\n领域","语言\n领域","社会\n领域","学习\n品质",]
        //空白数据界面
        nodataView = NoPartakeViewController()
//        nodataView.titleLab.text = "本年级暂不参与专项测评哦~"
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ValuationResultView: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ValuationResultCell") as? ValuationResultCell
        cell?.selectionStyle = .none
        cell?.textLabel?.theme_textColor = Theme.Color.textColor
        cell?.dict = dataArray[indexPath.row]
        
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func  getData(teacherResult :TeacherResult) -> NSDictionary {
        let someArray : [String]=[teacherResult.scoreTotal!,teacherResult.part1!,teacherResult.part2!,teacherResult.part3!,teacherResult.part4!]
        let mutable1 : NSMutableDictionary = NSMutableDictionary()
        mutable1.setObject(teacherResult.title!, forKey:"title"  as NSCopying)
        mutable1.setObject(teacherResult.rangeTime!, forKey:"time"  as NSCopying)
        mutable1.setObject(someArray, forKey: "list"  as NSCopying)
        return mutable1
    }
}


