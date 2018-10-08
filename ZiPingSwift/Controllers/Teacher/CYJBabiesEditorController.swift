//
//  CYJBabiesEditorController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/23.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

import HandyJSON
import SwiftTheme

class CYJBabiesEditorController: KYBaseViewController {
 
    var scrollPageView : ScrollPageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "幼儿管理"
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = Theme.Color.ground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加", style: .plain, target: self, action: #selector(addNewBaby))
        
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        
        // 滚动条
        var style = SegmentStyle()
        style.showLine = true        // 颜色渐变
        style.gradualChangeTitleColor = true         // 滚动条颜色
//        style.scrollLineColor =  UIColor(red: 41/255.0, green: 167/255.0, blue: 158/255.0, alpha: 1)
        style.titleMargin = 30        //标题间距
        style.scrollTitle = true// s滚动标题
        style.titleAlignment = true  //整体剧中
        
        let color = ThemeManager.color(for: "Nav.barTintColor")!
        let normalColor = ThemeManager.color(for: "Global.textColorLight")!
        
        style.scrollLineColor =  color
        style.normalTitleColor = normalColor
        style.selectedTitleColor = color
        
//        style.normalTitleColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 235/255.0, alpha: 1)
        style.titleFont = UIFont.systemFont(ofSize: 17)
//        style.selectedTitleColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 235/255.0, alpha: 1)
        style.scrolledContentView = false
        
        
        scrollPageView = ScrollPageView(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: view.frame.width, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight), segmentStyle: style, titles: ["在班幼儿", "待验证幼儿"], childVcs: setChildVcs(), parentViewController: self)
        
        view.addSubview(scrollPageView)
    }
    
    /// swiperView 必须实现的
    func setChildVcs() -> [UIViewController] {
        
        var childVCs: [UIViewController] = []
        
        let vc1 = CYJBabiesListController()
        vc1.isWaited = false
        vc1.title = ""
        vc1.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 44 - Theme.Measure.navigationBarHeight)
        
        childVCs.append(vc1)
        
        let vc2 = CYJBabiesListController()
        vc2.isWaited = true
        vc2.view.backgroundColor = UIColor.white
        vc2.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 44 - Theme.Measure.navigationBarHeight )
        vc2.title = "待验证幼儿"
        
        childVCs.append(vc2)
        
        return childVCs
    }
    
    func addNewBaby() {
        let addNew = CYJAddBabyViewController()
        addNew.completeHandler = { (_) in
            // 添加成功
            self.scrollPageView.selectedIndex(1, animated: true)
            
            let vc = self.scrollPageView.getChildVC(at: 1) as? CYJBabiesListController
            
            vc?.page = 1
            vc?.fetchDataSource()
            
        }
        navigationController?.pushViewController(addNew, animated: true)
    }
}

class CYJBabiesListController: KYBaseTableViewController {
    
    var isWaited: Bool = true
    
    var dataSource: [CYJChild] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldHeaderRefresh = true
        self.shouldFooterRefresh = true
        
        view.theme_backgroundColor = Theme.Color.ground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加", style: .plain, target: self, action: #selector(addNewBaby))
        
        
        tableView.frame = CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight)
        tableView.register(UINib(nibName: "CYJUserTableViewCell", bundle: nil), forCellReuseIdentifier: "CYJUserTableViewCell")

        fetchDataSource()
    }
    
    override func fetchDataSource() {
        
        RequestManager.POST(urlString: APIManager.Baby.list, params: ["type": self.isWaited ? "2" : "1", "token": LocaleSetting.token, "page": self.page]) { [weak self] (data, error) in
            
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
                var tmpBabies = [CYJChild]()
                babies.forEach({
                    let target = JSONDeserializer<CYJChild>.deserializeFrom(dict: $0 as? NSDictionary)
                    tmpBabies.append(target!)
                })
                if tmpBabies.count < 10
                {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self?.dataSource.append(contentsOf: tmpBabies)
            }
            self?.tableView.reloadData()
            
        }
        
    }
}

extension CYJBabiesListController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let line = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5))
            line.theme_backgroundColor = Theme.Color.line
        return line
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJUserTableViewCell") as! CYJUserTableViewCell
    
        let child = self.dataSource[indexPath.row]
        if isWaited {
//            cell.photoImageView.kf.setImage(with: URL(string: child.avatar!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!)
            cell.photoImageView.kf.setImage(with: URL(fragmentString: child.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

            cell.nameLabel.text = child.realName
            cell.descriptionLabel.text = "验证状态："
            cell.nextLabel.text = (child.status! == 2) ? "未验证" : "拒绝加入"
        }else
        {
//            cell.photoImageView.kf.setImage(with: URL(string: child.avatar!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!)
            cell.photoImageView.kf.setImage(with: URL(fragmentString: child.avatar) ,placeholder: #imageLiteral(resourceName: "default_user"))

            cell.nameLabel.text = child.realName
            cell.descriptionLabel.text = "电话号码:"
            cell.nextLabel.text = child.username
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isWaited
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let child = self.dataSource[indexPath.row]

        let action1 = UITableViewRowAction(style: .destructive, title: "删除") {  [unowned self] (action, index) in
            
            RequestManager.POST(urlString: APIManager.Baby.delete, params: ["token": LocaleSetting.token, "uvId": (child.uvId)!]) { [unowned self] (data, error) in
                //如果存在error
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                
                self.dataSource.remove(at: index.row)
                self.tableView.deleteRows(at: [index], with: .fade)
            }

        }
        
        return [action1]
    }
    
    
    /// 添加新包包
    func addNewBaby() {
        let addNew = CYJAddBabyViewController()
        addNew.completeHandler = { [weak self](_) in
            // 添加成功
            
            self?.page = 1
            self?.fetchDataSource()
            
        }
        navigationController?.pushViewController(addNew, animated: true)
    }
}
