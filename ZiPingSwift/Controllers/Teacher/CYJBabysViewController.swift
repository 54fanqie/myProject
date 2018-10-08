//
//  CYJBabysViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/28.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJBabysViewController: KYBaseTableViewController {
    
    var dataSource: [CYJChild] = []
    
    override func viewDidLoad() {
        //在调用 super.viewDidLoad() 前给 haveTabBar 赋值
        haveTabBar = true
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.theme_backgroundColor = Theme.Color.ground
        tableView.separatorStyle = .singleLine
        tableView.register(UINib(nibName: "CYJUserTableViewCell", bundle: nil), forCellReuseIdentifier: "CYJBabiesCell")
        
        self.shouldHeaderRefresh = true
        self.shouldFooterRefresh = true
        
        fetchDataSource()
    }
    
    override func fetchDataSource() {
        RequestManager.POST(urlString: APIManager.Baby.list, params: ["type":"1", "token": LocaleSetting.token, "page": self.page]) { [weak self] (data, error) in
            
            self?.endRefreshing()

            //如果存在error
            guard error == nil else {
                self?.statusUpdated(success: false)

                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self?.statusUpdated(success: true)

            if let babies = data as? NSArray {
                if self?.page == 1 {
                    self?.dataSource.removeAll()
                }
                //遍历，并赋值
                var tmp = [CYJChild]()
                babies.forEach({
                    let target = JSONDeserializer<CYJChild>.deserializeFrom(dict: $0 as? NSDictionary)
                    tmp.append(target!)
                })
                if tmp.count < 10 {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self?.dataSource.append(contentsOf: tmp)
                
                self?.tableView.reloadData()
            }
            
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CYJBabysViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJBabiesCell") as! CYJUserTableViewCell
        cell.selectionStyle = .none
        let child = self.dataSource[indexPath.row]
        cell.separatorInset = UIEdgeInsets.zero
        cell.accessoryType = .disclosureIndicator
//        cell.photoImageView.kf.setImage(with: URL(string: child.avatar!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!)
        cell.photoImageView.kf.setImage(with: URL(fragmentString: child.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

        cell.nameLabel.text = child.realName
        cell.descriptionLabel.text = "本学期共\(child.grownRecordNum ?? 0)条记录  本周共\(child.weekRecordNum ?? 0)条记录"
        cell.nextLabel.text = "档案袋：\(child.archivesNum ?? 0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let page = CYJBabiesPageController()
        let child = self.dataSource[indexPath.row]
        page.uid = child.uId
        page.title = child.realName
        
        self.navigationController?.pushViewController(page, animated: true)
    }
}

