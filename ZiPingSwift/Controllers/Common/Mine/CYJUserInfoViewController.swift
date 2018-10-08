//
//  CYJUserInfoViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJUserInfoViewController: KYBaseTableViewController {
    
    var examples: [[KYTableExample]] = []
    var extraInfo: CYJUserExtraInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "我的资料"
        
        
        if LocaleSetting.userInfo()?.role == .master {
            let arr = [[KYTableExample(key: "realName", title: "姓名", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "sex", title: "性别", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "birthday", title: "出生日期", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "jobName", title: "现任职务", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "workTime", title: "任现职时间", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "highestEdu", title: "学历", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "titleName", title: "职称", selector: #selector(didClick), image: nil)],
                       [KYTableExample(key: "phone", title: "手机号", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "email", title: "邮箱", selector: #selector(didClick), image: nil)]
            ]
            
            examples = arr
        }else if LocaleSetting.userInfo()?.role == .teacher || LocaleSetting.userInfo()?.role == .teacherL {
            let arr = [[KYTableExample(key: "realName", title: "姓名", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "sex", title: "性别", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "birthday", title: "出生日期", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "eduBackground", title: "初始学历", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "major", title: "初始学历专业", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "highestEdu", title: "最高学历", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "highestMajor", title: "最高学历专业", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "titleName", title: "职称", selector: #selector(didClick), image: nil)],
                       [KYTableExample(key: "phone", title: "手机号", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "email", title: "邮箱", selector: #selector(didClick), image: nil)]
            ]
            examples = arr
        }else
        {
            let arr = [[KYTableExample(key: "realName", title: "姓名", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "sex", title: "性别", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "birthday", title: "出生日期", selector: #selector(didClick), image: nil)],
                       [KYTableExample(key: "phone", title: "手机号", selector: #selector(didClick), image: nil),
                        KYTableExample(key: "email", title: "邮箱", selector: #selector(didClick), image: nil)]
            ]
            examples = arr
        }
        
        
        
        fetchDataSource()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didClick() {
        
    }
    
    
    func changeInfo(example: KYTableExample) {
        
        let nameC = CYJInputOutletController(title: "\(example.title!)", placeholder: "请输入\(example.title!)") {[weak self,example] ( inoutController,inputText) in
            
            RequestManager.POST(urlString: APIManager.Mine.update, params: ["token": LocaleSetting.token, "keyword": "\(example.key!)", "value": inputText]) { [weak self] (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                self?.extraInfo?.setValue(inputText, forKey: example.key!)
                self?.tableView.reloadData()
                
                inoutController.navigationController?.popViewController(animated: true)
            }
        }
        
        self.navigationController?.pushViewController(nameC, animated: true)
    }
    
    
    
    
    func changeOption(example: KYTableExample) {
        
        var options = [CYJOption]()
        
        var currentIndex: Int = 0
        
        switch (example.key)! {
        case "sex":
            let jobArr = ["男", "女"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.sex == option.opId {
                    currentIndex = i
                }
            }
        case  "jobName" :
            let jobArr = ["园长", "业务副园长", "保教主任", "其他"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.jobName == option.opId {
                    currentIndex = i
                }
            }
        case  "workTime":
            let jobArr = ["不到1年","1-3年", "4-8年", "9年以上"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.workTime == option.opId {
                    currentIndex = i
                }
            }
        case   "highestEdu":
            let jobArr = ["初中", "高中及中专", "大专", "本科", "硕士及以上"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.highestEdu == option.opId {
                    currentIndex = i
                }
            }
        case   "titleName":
            let jobArr = ["三级", "二级", "一级", "中学高级", "无职称"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.titleName == option.opId {
                    currentIndex = i
                }
            }
        case "eduBackground":
            let jobArr = ["初中", "高中及中专", "大专", "本科", "硕士及以上"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.eduBackground == option.opId {
                    currentIndex = i
                }
            }
        case "major":
            let jobArr = ["学前教育", "其他教育类专业", "心理教育", "非教育类专业"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.major == option.opId {
                    currentIndex = i
                }
            }
        case "highestMajor":
            let jobArr = ["学前教育", "其他教育类专业", "心理教育", "非教育类专业"]
            for i in 0..<jobArr.count {
                let option = CYJOption(title: jobArr[i], opId: i + 1)
                options.append(option)
                if self.extraInfo?.highestMajor == option.opId {
                    currentIndex = i
                }
            }
        default:
            return
        }
        
        let optionController = CYJOptionsSelectedController(currentIndex: currentIndex, options: options) { (op) in
            
            RequestManager.POST(urlString: APIManager.Mine.update, params: ["token": LocaleSetting.token, "keyword": "\(example.key!)", "value": "\(op.opId)"]) { [unowned self] (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                self.extraInfo?.setValue(op.opId, forKey: example.key!)
                self.tableView.reloadData()
            }
            print("\(op.title)")
        }
        optionController.title = example.title
        
        navigationController?.pushViewController(optionController, animated: true)
    }
    
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Mine.info, params: ["token": LocaleSetting.token]) { [weak self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let info = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<CYJUserExtraInfo>.deserializeFrom(dict: info)
                self?.extraInfo = target
                
                self?.tableView.reloadData()
            }
        }
    }
}

extension CYJUserInfoViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MineInfoCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "MineInfoCell")
        }
        let example = examples[indexPath.section][indexPath.row]
        cell?.textLabel?.text = example.title
        
        switch (example.key)! {
        case "realName":
            cell?.detailTextLabel?.text = extraInfo?.realName
            cell?.accessoryType = .none
        case "sex":
            cell?.detailTextLabel?.text = extraInfo?.sexDescription
            cell?.accessoryType = .disclosureIndicator
        case "birthday":
            cell?.detailTextLabel?.text = extraInfo?.birthday
            cell?.accessoryType = .none
        case  "jobName" :
            cell?.detailTextLabel?.text = extraInfo?.jobNameDescription
            cell?.accessoryType = .disclosureIndicator
            
        case  "workTime":
            cell?.detailTextLabel?.text = extraInfo?.workTimeDescription
            cell?.accessoryType = .disclosureIndicator
            
        case   "highestEdu":
            cell?.detailTextLabel?.text = extraInfo?.highestEduDescription
            cell?.accessoryType = .disclosureIndicator
            
        case   "titleName":
            cell?.detailTextLabel?.text = extraInfo?.titleNameDescription
            cell?.accessoryType = .disclosureIndicator
            
        case "phone":
            cell?.detailTextLabel?.text = LocaleSetting.userInfo()?.username
            cell?.accessoryType = .none
            
        case  "email":
            cell?.detailTextLabel?.text = extraInfo?.email
            cell?.accessoryType = .disclosureIndicator
        case "eduBackground":
            cell?.detailTextLabel?.text = extraInfo?.eduBackgroundDescription
            cell?.accessoryType = .disclosureIndicator
        case "major":
            cell?.detailTextLabel?.text = extraInfo?.majorDescription
            cell?.accessoryType = .disclosureIndicator
        case "highestMajor":
            cell?.detailTextLabel?.text = extraInfo?.highestMajorDescription
            cell?.accessoryType = .disclosureIndicator
        default:
            cell?.detailTextLabel?.text = nil
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
        return 8
        }
        return 0.5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let space = UIView()
            space.theme_backgroundColor = Theme.Color.viewLightColor
            return space
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let example = examples[indexPath.section][indexPath.row]
        
        switch (example.key)! {
        case "realName":
            Third.toast.message("暂未开放此功能")
        //            self.changeInfo(example: example)
        case "sex":
            self.changeOption(example: example)
        case "birthday":
            self.changeInfo(example: example)
        case  "jobName" :
            self.changeOption(example: example)
        case  "workTime":
            self.changeOption(example: example)
        case   "highestEdu":
            self.changeOption(example: example)
        case   "titleName":
            self.changeOption(example: example)
        case "phone":
            Third.toast.message("暂未开放此功能")
        //            self.changeInfo(example: example)
        case  "email":
            self.changeInfo(example: example)
        case "eduBackground":
            self.changeOption(example: example)
        case "major":
            self.changeOption(example: example)
        case "highestMajor":
            self.changeOption(example: example)
        default:
            break
        }
    }
}

