//
//  MultipleChoiceTableViewController.swift
//  test
//
//  Created by 番茄 on 7/24/18.
//  Copyright © 2018 fanqie. All rights reserved.
//

import UIKit
import HandyJSON
class ChoiceslParsam: CYJParameterEncoding, NSCopying{
    var title : String?
    var shijuanid : String?
    var historyid : Int = 0
    var isfinish : Int = 0
    var datiNums : Int = 0
    var spentTime : Int = 0
    var result_data : String?
    
    
    ///实现copyWithZone方法
    func copy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = ChoiceslParsam.init()
        
        theCopyObj.title = self.title
        theCopyObj.shijuanid = self.shijuanid
        theCopyObj.historyid = self.historyid
        theCopyObj.datiNums = self.datiNums
        theCopyObj.spentTime = self.spentTime
        theCopyObj.result_data = self.result_data
        return theCopyObj
    }
    
    
    
}


class ShiJuanModel: CYJBaseModel {
    var historyid : Int = 0
    var isfinish : Int = 0
    var shijuanid : String?
    var title : String?
    var content : String?
    var shitiData : [ShiTiDetailModel] = []
}

class ShiTiDetailModel: CYJBaseModel {
    var bigTitle : String?
    var catid1 : Int = 1
    var catid2 : Int = 2
    var catid3 : Int = 3
    var choices : [ChoicesDetailModel] = []
    var questioImg : String?
    var tiid : Int = 0
    var title : String?
    var type : Int = 0
    var yueduImg : String?
}

class ChoicesDetailModel : CYJBaseModel{
    var answer : Int = 0
    var chose : String?
    var scId : Int = 0
    var score : Int = 0
    var thumb : String?
}







class MultipleChoiceController: KYBaseViewController,UITableViewDataSource, UITableViewDelegate, MultipleChoiceDelegate {
    
    var shiJuanModel : ShiJuanModel?
    
    var dataSource : [ShiTiDetailModel] = []
    
    var table: UITableView!
    var bottmView: UIView!
    
    //要上传的参数
    var choiceslParsam = ChoiceslParsam()
    var optionSource = [Dictionary<String,Any>]()
    
    /// 操作bar
    var actionView: CYJActionsView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "问卷测评"
        
        self.dataSource = (self.shiJuanModel?.shitiData)!
        
        //获取到数据后处理下准备上传的数据
        self.assemblyData();
        
        table = UITableView()
        table.separatorStyle = UITableViewCellSeparatorStyle.none
        table.showsVerticalScrollIndicator = false
        //设置数据源
        table.dataSource = self
        //设置代理
        table.delegate = self
        table.theme_backgroundColor = Theme.Color.viewLightColor
        self.view.addSubview(table)
        //设置estimatedRowHeight属性默认值
        table.estimatedRowHeight = 237;
        //rowHeight属性设置为UITableViewAutomaticDimension
        table.rowHeight = UITableViewAutomaticDimension;
        
        
        table.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.top.equalTo(view).offset(0)
            make.bottom.equalTo(view).offset(-44)
        }
        
        
        
        actionView = CYJActionsView(frame: CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44))
        actionView.innerPadding = 0.5
        actionView.isFull = true
        
        let saveButton = UIButton(type: .custom)
        saveButton.theme_setTitleColor(Theme.Color.textColorlight, forState: .normal)
        saveButton.theme_backgroundColor = Theme.Color.ground
        saveButton.setTitle("暂存", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        saveButton.tag = 0;
        saveButton.addTarget(self, action: #selector(updataAciton(button:)), for: .touchUpInside)
        
        let updataBtn = UIButton(type: .custom)
        updataBtn.theme_setTitleColor(Theme.Color.ground, forState: .normal)
        updataBtn.theme_backgroundColor = Theme.Color.main
        updataBtn.setTitle("提交并完成测评", for: .normal)
        updataBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        updataBtn.tag = 1;
        updataBtn.addTarget(self, action: #selector(updataAciton(button:)), for: .touchUpInside)
        actionView.actions = [saveButton, updataBtn]
        view.addSubview(actionView)
        
    }
    
    
    //暂存  或者提交
    @objc func updataAciton(button:UIButton) {
        var popMessaeg : String!
        if button.tag == 1 {
            popMessaeg = "提交成功"
            for item  in optionSource {
                let dict = item as NSDictionary
                if dict.object(forKey: "choice") as! Int == 0 {
                    let alert = ValuationAlertController()
                    alert.message = "您需将所有题目完成后提交，请检查是否有遗漏掉的题目~"
                    alert.completeHandler = { [] in
                        alert.dismiss(animated:true, completion: nil)
                    }
                    alert.showAlert()
                    return
                }
            }
        }else{//如果是暂存
            popMessaeg = "暂存成功"
            //如果没有暂存过 并且已经删除栈内的 controller
            if self.shiJuanModel?.historyid == 0 {
                self.navigationController?.viewControllers.remove(at: 2)
            }
            var noSelect : Bool = true
            for item  in optionSource {
                let dict = item as NSDictionary
                if dict.object(forKey: "choice") as! Int != 0 {
                    noSelect = false
                }
            }
            if noSelect == true{
                return
            }
        }
        choiceslParsam.isfinish =  button.tag
        var  dataDict = Dictionary<String,NSArray>();
        dataDict["data"] = optionSource as NSArray
        choiceslParsam.result_data = toJSONString(dict: dataDict)
        
        RequestManager.POST(urlString: APIManager.Valuation.addAnswer, params: choiceslParsam.encodeToDictionary() ) { [weak self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            
            
            if button.tag == 1{
                NotificationCenter.default.post(name: NSNotification.Name("QuestionnaireViewStatue"), object: nil)
                self?.navigationController?.popToViewController(self?.navigationController?.viewControllers[1] as! QuestionnaireViewController, animated: true)
            }else{
                //暂存或者上传成功返回histeryid 更新id
                if let histeryid = data as? String{
                    NotificationCenter.default.post(name: NSNotification.Name("ReloadHistoryID"), object: histeryid)
                }
                
            }
            Third.toast.message(popMessaeg)
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "ChoiceCell" + String(format: "%d%d", indexPath.row,indexPath.section)
        var cell:MultipleChoiceCell! = tableView.dequeueReusableCell(withIdentifier: indentifier)as?MultipleChoiceCell
        if cell == nil {
            cell = MultipleChoiceCell(style: .default, reuseIdentifier: indentifier, cellData:(self.shiJuanModel?.shitiData[indexPath.row])! , index : indexPath.row)
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.theme_backgroundColor = Theme.Color.viewLightColor
        cell.tag = indexPath.row
        return cell
    }
    //答案选择
    func selectResult(cellIndex : Int ,choesIndex : Int, score : String) {
        
        //        let result_data = getDictionaryFromJSONString(jsonString: choiceslParsam.result_data! )
        //        let dataArray = result_data["data"] as! NSArray
        
        var dict = optionSource[cellIndex]
        print(dict)
        dict["choice"] = choesIndex
        dict["score"] = Int(score)
        optionSource[cellIndex] = dict
    }
    
    
    //数据组装
    func assemblyData()  {
        
        //标题等基本信息数据
        choiceslParsam.title = self.shiJuanModel?.title
        choiceslParsam.shijuanid = (self.shiJuanModel?.shijuanid)!
        choiceslParsam.historyid = (self.shiJuanModel?.historyid)!
        choiceslParsam.isfinish = 0
        choiceslParsam.spentTime = 0
        choiceslParsam.datiNums = 10
        
        
        //选项数据
        for shiTiDetailModel in (self.shiJuanModel?.shitiData)! {
            var subDict = Dictionary<String,Int>()
            
            subDict["tiid"] = shiTiDetailModel.tiid
            subDict["catid1"] = shiTiDetailModel.catid1
            subDict["catid2"] = shiTiDetailModel.catid2
            subDict["catid3"] = shiTiDetailModel.catid3
            
            subDict["choice"] = 0
            subDict["score"] = 0
            for choicesDetailModel in shiTiDetailModel.choices{
                if choicesDetailModel.answer != 0{
                    subDict["choice"] = choicesDetailModel.scId
                    subDict["score"] = choicesDetailModel.score
                }
            }
            
            optionSource.append(subDict)
        }
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
    /// JSONString转换为字典
    ///
    /// - Parameter jsonString: <#jsonString description#>
    /// - Returns: <#return value description#>
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
