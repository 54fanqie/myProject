//
//  CYJStatisticView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/13.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

class XValue: NSObject {
    var text: String?
    var xId: Int = 0

}

class YValue: NSObject {
    var text: String?
    var yId: Int = 0
}
class SValue: NSObject {
    var text: String?
    var level: Int = 0
}

protocol CYJStatisticViewDelegate: class {
    
    func statisticView(_ statisticView: CYJStatisticView, XdidClickedAt index: Int) -> Void
    func statisticView(_ statisticView: CYJStatisticView, YdidClickedAt index: Int) -> Void
    func statisticView(_ statisticView: CYJStatisticView, didClickedAt indexPath: IndexPath) -> Void

}

class CYJStatisticView: UIView {
    
    let cellIdentifier: String = "CYJRECStatisticCVC"
    
    var xValues: [XValue] = []
    var yValues: [YValue] = []
    var sValues: [[SValue]] = []
    //线宽
    let lineWidth: CGFloat = 1
    
    var leftPadding: CGFloat = 8
    
    var maxXAries: Int {
        return min(xValues.count, 5) // 要比可以展示的领域多一个,还不能是0
    }
    
    var itemSize: CGSize {
        
        let allSep = self.lineWidth * CGFloat(self.maxXAries) + lineWidth
        
        let width = ((Theme.Measure.screenWidth - 2 * leftPadding) - allSep) / CGFloat(max(self.maxXAries, 1))
        return CGSize(width: Int(width), height: 37)
    }
    
    var tableSize: CGSize {
        let allSep = self.lineWidth * CGFloat(self.maxXAries) + lineWidth
        var height = CGFloat(yValues.count + 1) * (self.itemSize.height + lineWidth) + lineWidth
        
        if height > frame.height{
            height = frame.height
        }
        return CGSize(width: itemSize.width * CGFloat(maxXAries) + allSep, height: height)
    }
    
    lazy var collectionView: UICollectionView = {
        
        let layout =  UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        let collectionView = UICollectionView(frame: CGRect(x: self.itemSize.width + self.lineWidth, y: self.itemSize.height + 2*self.lineWidth, width: (self.tableSize.width - self.itemSize.width - self.lineWidth), height: 44), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.theme_backgroundColor = Theme.Color.line //表格的颜色
        
        collectionView.register(UINib(nibName: "CYJRECStatisticCVC", bundle: nil), forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.register(UINib(nibName: "CYJRECStatisticNameHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "namenamename")
        
        return collectionView
    }()
    
    lazy var xCollectionView: UICollectionView = {
        let xlayout =  UICollectionViewFlowLayout()
        xlayout.scrollDirection = .horizontal
        let xCollectionView = UICollectionView(frame: CGRect(x: 0 , y: 0 , width: self.tableSize.width, height: self.itemSize.height + 2*self.lineWidth) , collectionViewLayout: xlayout)
        
        xCollectionView.theme_backgroundColor = Theme.Color.line //表格的颜色
        xCollectionView.contentInset = UIEdgeInsetsMake(self.lineWidth, self.lineWidth, self.lineWidth, self.lineWidth)
        xCollectionView.delegate = self
        xCollectionView.dataSource = self
        
        xCollectionView.register(UINib(nibName: "CYJRECStatisticX", bundle: nil), forCellWithReuseIdentifier: "CYJRECStatisticX")
        
        return xCollectionView
    }()
    
    lazy var yTableView: UITableView = {
        
        let yTableView = UITableView(frame: CGRect(x: 0, y: self.itemSize.height + 2 * self.lineWidth, width: self.itemSize.width + self.lineWidth , height: self.tableSize.height - self.itemSize.height - 2 * self.lineWidth), style: .plain)
        yTableView.contentInset = UIEdgeInsetsMake(0, self.lineWidth, self.lineWidth, 0)
        
        yTableView.backgroundColor = UIColor.black
        yTableView.delegate = self
        yTableView.dataSource = self
        yTableView.theme_backgroundColor = Theme.Color.line //表格的颜色
        yTableView.separatorStyle = .none
        yTableView.isScrollEnabled = false
        yTableView.register(UINib(nibName: "CYJRECStatisticTVC", bundle: nil), forCellReuseIdentifier: "CYJRECStatisticTVC")
        
        return yTableView
    }()
    
    var data: ([XValue], [YValue], [[SValue]])? {
        didSet{
            guard let data = data else {
                return
            }
            
            xValues = data.0
            yValues = data.1
            sValues = data.2
            
            clearStatisticFrame()
            
            reloadStatisticView()
        }
    }
    
    weak var delegate: CYJStatisticViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(xCollectionView)
        addSubview(yTableView)
        addSubview(collectionView)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadStatisticView() {
        xCollectionView.reloadData()
        yTableView.reloadData()
        collectionView.reloadData()
    }
    
    func clearStatisticFrame() {
        

        xCollectionView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: tableSize.width, height: itemSize.height + 2*lineWidth))
        
        yTableView.frame = CGRect(x: 0, y: itemSize.height + 2 * lineWidth, width: itemSize.width + lineWidth, height: tableSize.height - itemSize.height - 2 * lineWidth)
        
        collectionView.frame = CGRect(x: itemSize.width + lineWidth, y: itemSize.height + 2*lineWidth, width: (tableSize.width - itemSize.width - lineWidth), height: tableSize.height - itemSize.height - 2 * lineWidth)
        collectionView.contentInset = UIEdgeInsetsMake(0, self.lineWidth, self.lineWidth, self.lineWidth)

    }
}

extension CYJStatisticView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == xCollectionView {
            return 1
        }
        return yValues.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == xCollectionView {
            return maxXAries
        }
        
        return max(maxXAries - 1, 0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == xCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYJRECStatisticX", for: indexPath) as? CYJRECStatisticX
            
            cell?.titleLabel.text = xValues[indexPath.item].text
            return cell!

        }else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CYJRECStatisticCVC
            cell?.textLabel.text = sValues[indexPath.section][indexPath.row].text
            cell?.level = sValues[indexPath.section][indexPath.row].level
            return cell!
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineWidth
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lineWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == xCollectionView {
            return UIEdgeInsets.zero
        }
        return UIEdgeInsetsMake(0, 0, lineWidth, 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == xCollectionView {
            if let del = delegate {
                del.statisticView(self, XdidClickedAt: indexPath.row)
            }
        }else
        {
            if let del = delegate {
                del.statisticView(self, didClickedAt: indexPath)
            }
        }
        
        
    }
}

extension CYJStatisticView: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return yValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYJRECStatisticTVC") as? CYJRECStatisticTVC
        cell?.selectionStyle = .none
        cell?.titleLabel.text = yValues[indexPath.section].text
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemSize.height
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return lineWidth
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let del = delegate {
            del.statisticView(self, YdidClickedAt: indexPath.section)
        }
    }
}

extension CYJStatisticView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            yTableView.contentOffset = collectionView.contentOffset
        }
//        if scrollView == yTableView {
//            collectionView.contentOffset = yTableView.contentOffset
//        }
    }
}

