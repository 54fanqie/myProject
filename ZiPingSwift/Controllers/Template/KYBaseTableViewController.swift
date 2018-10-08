//
//  KYBaseTableViewController.swift
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/12.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

import MJRefresh
import DZNEmptyDataSet

import SwiftTheme

/// 表格item类型
struct KYTableExample {
    var key: String?
    var title: String?
    
    var selector: Selector?
    var image: UIImage?
    

}

class KYBaseTableViewController: KYBaseViewController{
    
    /// 表格实体
    var tableView: UITableView!
    
    /// 页码
    lazy var page = 1
    
    /// 表格style
    var style: UITableViewStyle = UITableViewStyle.plain
    
    var haveTabBar :Bool = false
    
    /// controller数据加载情况
    var status: KYDateStatus = .firstLoad
    {
        didSet{
            guard oldValue == status else{
                return
            }
            self.tableView.reloadEmptyDataSet()
        }
    }
    
    /// 是否允许刷新，允许则创建MJ_header
    var shouldHeaderRefresh: Bool = false{
        didSet{
            if shouldHeaderRefresh {
                //创建刷新控件
                let header = MJRefreshNormalHeader(refreshingBlock: { [unowned self] in
                    //刷新数据
                    if let footer = self.tableView.mj_footer {
                        footer.resetNoMoreData()
                    }
                    
                    self.page = 1
                    self.fetchDataSource()
                })
                tableView.mj_header = header
            }
        }
    }

    /// 是否允许加载更多，允许则创建MJ_footer
    var shouldFooterRefresh: Bool = false {
        didSet{
            
            if shouldFooterRefresh {
                //创建刷新控件
                let footer = MJRefreshBackNormalFooter(refreshingBlock: {[unowned self] in
                    //加载更多
                    self.page = self.page + 1
                    self.fetchDataSource()
                })
//                let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] in
//                    //加载更多
//                    self.page = self.page + 1
//                    self.fetchDataSource()
//                })
//                footer?.stateLabel.textColor = UIColor(hex: "999999", alpha: 1.0)
                footer?.stateLabel.theme_textColor = Theme.Color.textColorlight

                footer?.stateLabel.font = UIFont.systemFont(ofSize: 12)
                footer?.isAutomaticallyHidden = true
                footer?.isAutomaticallyChangeAlpha = true
                
                tableView.mj_footer = footer
            }
        }
    }
    
    var enabledEmptyDataSet: Bool = true
    
    convenience init(_ style: UITableViewStyle) {
        self.init()
        
        self.style = style
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        创建表格
        tableView =  UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (haveTabBar ? Theme.Measure.tabBarHeight : 0)), style: style)
        view.addSubview(tableView)

        // 表格属性
        tableView.theme_backgroundColor = Theme.Color.ground
        tableView.theme_separatorColor = Theme.Color.line
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.showsVerticalScrollIndicator = false
//        设置代理
        tableView.delegate = self
        tableView.dataSource = self
        
        //设置数据为空或网络情况差
        if enabledEmptyDataSet {
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
        }
    }
    
    /// 子类重写数据源加载方法，refresh 时调用此方法刷新数据，
    dynamic func fetchDataSource() {
        DLog("加载数据\(page)")
    }
    
    /// 发生错误的时候，调用此方法，刷新数据错误显示
    func noticeNetWorkError() {
        status = .netWorkBad
        
        self.tableView.reloadEmptyDataSet()
    }
    
    /// 统一停止刷新----根据有无刷新，
    func endRefreshing() {
        if shouldHeaderRefresh {
            if tableView.mj_header.isRefreshing {
                tableView.mj_header.endRefreshing()
            }
        }
        if shouldFooterRefresh {
            if tableView.mj_footer.isRefreshing {
                tableView.mj_footer.endRefreshing()
            }
        }
    }
    
    /// 根据情况刷新当前页面的状态
    ///
    /// - Parameter success: <#success description#>
    func statusUpdated(success: Bool) {
        
        if success {
            status = .emptyDate
        }else
        {
            status = .netWorkBad
        }
    }
}

extension KYBaseTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    /// 表格section个数，需子类重写
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    /// section中row个数，需子类重写
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    /// cell实例化方法，需子类重写
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    /// 表格点击事件，需子类重写
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension KYBaseTableViewController: DZNEmptyDataSetSource{

    /// 空数据的标题，需子类重写
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        switch status {
        case .firstLoad:
            return nil
        case .emptyDate:
            let text = "暂无数据"
            let font = UIFont.systemFont(ofSize: 15)
            let textColor = UIColor(hex: "666666", alpha: 1.0)
            var attributes = [String:Any]()
            if text.isEmpty {
                return nil
            }
            attributes[NSFontAttributeName] = font
            attributes[NSForegroundColorAttributeName] = textColor
            
            return NSAttributedString(string: text, attributes: attributes)
        case .netWorkBad:
            let text = "失败了，再往下拉一下试试"
            let font = UIFont.systemFont(ofSize: 15)
            let textColor = UIColor(hex: "666666", alpha: 1.0)
            var attributes = [String:Any]()
            if text.isEmpty {
                return nil
            }
            attributes[NSFontAttributeName] = font
            attributes[NSForegroundColorAttributeName] = textColor
            
            return NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    /// emptyDataSet的图片，根据页面状态进行区分显示
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        switch status {
        case .firstLoad:
            return nil
        case .emptyDate:
            return ThemeManager.image(for: "Global.emptyImage")// UIImage(named: "pic_empty")
        case .netWorkBad:
            return ThemeManager.image(for: "Global.networkBadImage")//UIImage(named: "pic_network")
        }
    }
    
    /// emptyDataSet图片的动画属性
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = CATransform3DIdentity
        animation.toValue = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0)
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        
        return animation
    }
    
    /// emptyDataSet的背景颜色，
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.clear
    }
    /// emptyDataSet的高度---距centerY
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -(Theme.Measure.screenHeight * 0.125)
    }
    ///emptyDataSet每个item的距离
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0.0
    }
    
}


extension KYBaseTableViewController: DZNEmptyDataSetDelegate
{
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    func emptyDataSetShouldBeForced(toDisplay scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool {
        return status == .firstLoad
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapView: UIView) {
//        print("didtapContentview")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
//        print("didtapUIButton")
    }
}



