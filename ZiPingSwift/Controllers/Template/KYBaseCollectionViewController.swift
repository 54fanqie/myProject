//
//  KYBaseCollectionViewController.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/6/1.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SwiftTheme
import MJRefresh

class KYBaseCollectionViewController: KYBaseViewController {
    
    /// 表格实体
    var collectionView: UICollectionView!
    
    /// 页面，初始 = 1
    var page: Int = 1
    
    /// controller数据加载情况
    var status: KYDateStatus = .firstLoad
    {
        didSet{
            guard oldValue == status else{
                return
            }
            self.collectionView.reloadEmptyDataSet()
        }
    }
    
    /// 是否允许刷新，允许则创建MJ_header
    var shouldHeaderRefresh: Bool = false{
        didSet{
            if shouldHeaderRefresh {
                //创建刷新控件
                let header = MJRefreshNormalHeader(refreshingBlock: {
                    //刷新数据
                    if let footer = self.collectionView.mj_footer {
                        footer.resetNoMoreData()
                    }
                    
                    self.page = 1
                    self.fetchDataSource()
                })
                collectionView.mj_header = header
            }
        }
    }
    
    /// 是否允许加载更多，允许则创建MJ_footer
    var shouldFooterRefresh: Bool = false {
        didSet{
            
            if shouldFooterRefresh {
                //创建刷新控件
                let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
                    //加载更多
                    self.page = self.page + 1
                    self.fetchDataSource()
                })
                footer?.stateLabel.theme_textColor = Theme.Color.textColorlight
                footer?.stateLabel.font = UIFont.systemFont(ofSize: 12)
                footer?.isAutomaticallyHidden = true
                footer?.isAutomaticallyChangeAlpha = true
                collectionView.mj_footer = footer
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = view.frame
        let scrollView = UIScrollView(frame: frame)

        view = scrollView
        // Do any additional setup after loading the view.
        makeCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// 子类重写数据源加载方法，refresh 时调用此方法刷新数据，
    func fetchDataSource() {
        DLog("加载数据\(page)")
    }
    
    /// 发生错误的时候，调用此方法，刷新数据错误显示
    func noticeNetWorkError() {
        status = .netWorkBad
        
        collectionView.reloadEmptyDataSet()
    }
    
    /// 统一停止刷新----根据有无刷新，
    func endRefreshing() {
        //只在停止刷新的时候调用一次，然后再次刷新的时间就不管了
        
        if shouldHeaderRefresh {
            collectionView.mj_header.endRefreshing()
        }
        if shouldFooterRefresh {
            collectionView.mj_footer.endRefreshing()
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
extension KYBaseCollectionViewController {
    /// 创建表格视图
    func makeCollectionView()  {
        let layout =  UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - 49), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.theme_backgroundColor = Theme.Color.ground
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        view.addSubview(collectionView)
    }
}

extension KYBaseCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension KYBaseCollectionViewController: DZNEmptyDataSetSource{
    
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
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = CATransform3DIdentity
        animation.toValue = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0)
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        
        return animation
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -(Theme.Measure.screenHeight * 0.25)
    }
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0.0
    }
    
}


extension KYBaseCollectionViewController: DZNEmptyDataSetDelegate
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


