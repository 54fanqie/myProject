//
//  CYJTellUsController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/9.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJTellUsController: KYBaseTableViewController {
    
    var dataSource: [KYTableExample] = []
    
    var careList: [String] = ["请选择","养成良好的生活习惯","养成良好的学习习惯","读、写、算等知识技能学习","语言能力发展","思维能力发展","社会交往能力发展","身体健康和运动方面的发展","开心愉悦，快乐生活","其他"]
    var careOptions: [CYJOption] = []
    var careOption1: CYJOption = CYJOption(title: "请选择", opId: 0)
    var careOption2: CYJOption = CYJOption(title: "请选择", opId: 0)
    var careOption3: CYJOption = CYJOption(title: "请选择", opId: 0)
    var careOption4: CYJOption = CYJOption(title: "请选择", opId: 0)
    var careOption5: CYJOption = CYJOption(title: "请选择", opId: 0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //input code here
        self.title = "告诉我们"
        dataSource = [         KYTableExample(key: "careA", title: "关心第一位", selector: nil, image: nil),
                               KYTableExample(key: "careB", title: "关心第二位", selector: nil, image: nil),
                               KYTableExample(key: "careC", title: "关心第三位", selector: nil, image: nil),
                               KYTableExample(key: "careD", title: "关心第四位", selector: nil, image: nil),
                               KYTableExample(key: "careE", title: "关心第五位", selector: nil, image: nil)]
        
        
        self.careList.enumerated().forEach { [unowned self] (offset, title) in
            let option = CYJOption(title: title, opId: offset)
            self.careOptions.append(option)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(uploadCollection))
        
        fetchDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //input code here
    }
    
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Mine.getCare, params: ["token" : LocaleSetting.token] ) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let dataJson = data as? [String: Any] {
                //遍历，并赋值
                if let careAString = dataJson["careA"] as? String {
                    let careA = Int(careAString)!
                    self.careOption1 = CYJOption(title: self.careList[careA], opId: careA)
                }
                if let careBString = dataJson["careB"] as? String {
                    let careB = Int(careBString)!
                    self.careOption2 = CYJOption(title: self.careList[careB], opId: careB)
                }
                if let careCString = dataJson["careC"] as? String {
                    let careC = Int(careCString)!

                    self.careOption3 = CYJOption(title: self.careList[careC], opId: careC)
                }
                if let careDString = dataJson["careD"] as? String {
                    let careD = Int(careDString)!
                    self.careOption4 = CYJOption(title: self.careList[careD], opId: careD)
                }
                if let careEString = dataJson["careE"] as? String {
                    let careE = Int(careEString)!

                    self.careOption5 = CYJOption(title: self.careList[careE], opId: careE)
                }
                
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: make UI
extension CYJTellUsController {
    
}
//MARK: click method
extension CYJTellUsController {
    
    func uploadCollection() {
        

            let parem: [String: Any] = ["token": LocaleSetting.token,
                                        "careA": (careOption1.opId),
                         "careB": (careOption2.opId),
                         "careC": (careOption3.opId),
                         "careD": (careOption4.opId),
                         "careE": (careOption5.opId)]
            
            RequestManager.POST(urlString: APIManager.Mine.care, params: parem) { (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                Third.toast.message("保存成功")
            }
    }
}
extension CYJTellUsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "UITableViewCell")
            cell?.textLabel?.theme_textColor = Theme.Color.textColor
            cell?.detailTextLabel?.theme_textColor = Theme.Color.textColor
            cell?.accessoryType = .disclosureIndicator
            cell?.selectionStyle = .none
        }
        
        let example = dataSource[indexPath.row]
        
        cell?.textLabel?.text = example.title
        
        switch indexPath.row {
            
        case 0: cell?.detailTextLabel?.text = careOption1.title
        case 1: cell?.detailTextLabel?.text = careOption2.title
        case 2: cell?.detailTextLabel?.text = careOption3.title
        case 3: cell?.detailTextLabel?.text = careOption4.title
        case 4: cell?.detailTextLabel?.text = careOption5.title
        default:
            break
        }
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var targetOption: CYJOption = CYJOption(title: "请选择", opId: 0)
        
        switch indexPath.row {
        case 0:
            targetOption = self.careOption1
        case 1:
            targetOption = self.careOption2
        case 2:
            targetOption = self.careOption3
        case 3:
            targetOption = self.careOption4
        case 4:
            targetOption = self.careOption5
        default:
            break
        }
        
        let unselectedOptions = self.getUnselectedOptions(targetOption)
        
        var currentIndex: Int = 0
        currentIndex = unselectedOptions.index(where: { (op) -> Bool in
            return op.opId == targetOption.opId
        })!
        
        let optionController = CYJOptionsSelectedController(currentIndex: currentIndex, options: unselectedOptions) { (op) in
            print("\(op.title)")
            switch indexPath.row {
                
            case 0: self.careOption1 = op
            case 1: self.careOption2 = op
            case 2: self.careOption3 = op
            case 3: self.careOption4 = op
            case 4: self.careOption5 = op
            default:
                break
            }
            tableView.reloadData()
        }
        optionController.title = "请选择关心的方面"
        navigationController?.pushViewController(optionController, animated: true)
        
    }
    
    func getUnselectedOptions(_ option: CYJOption) -> [CYJOption] {
        
        var targetOptions = careOptions.filter { (op) -> Bool in
            return (op.opId != self.careOption1.opId && op.opId != self.careOption2.opId && op.opId != self.careOption3.opId && op.opId != self.careOption4.opId && op.opId != self.careOption5.opId) || op.opId == option.opId
        }
        if option.opId != 0 {
            targetOptions.insert(CYJOption(title: "请选择", opId: 0), at: 0)
        }
        return targetOptions
        
    }
    
}
