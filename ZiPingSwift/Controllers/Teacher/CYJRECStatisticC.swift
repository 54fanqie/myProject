//
//  CYJRECStatisticC.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/11.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import HandyJSON

class CYJRECStatisticC: KYBaseViewController {

    let cellIdentifier: String = "CYJRECStatisticCVC"
    
    var statisticView: CYJStatisticView?
    
    var formatDatas: [CYJFormData] = []
    
    var allDomains: [CYJFormData.Domain] = []
    
    var currentFormatDatas: [CYJFormData] = []
    
    var currentData: ([XValue], [YValue], [[SValue]])?

    var nameSorted: Bool = false
    
    var domainSorted: Bool = false

    
    var selectedDomain: [CYJFormData.Domain] = [] {
        didSet{
            //MARK: 设置好选中的领域之后，刷新表格
            makeStatisticView()
        }
    }
    var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        let title = UILabel(frame: CGRect(x: 0, y: Theme.Measure.navigationBarHeight, width: Theme.Measure.screenWidth, height: 44))
        title.font = UIFont.systemFont(ofSize: 12)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.theme_backgroundColor = Theme.Color.viewLightColor
        
        let attributeString = NSAttributedString(string: "     注：色块颜色代表 ", attributes: [NSForegroundColorAttributeName: UIColor(hex6: 0x999999)])
        let greenString = NSAttributedString(string: " 高 ", attributes: [NSForegroundColorAttributeName: UIColor(hex6: 0x333333)])
        let yellowString = NSAttributedString(string: " 中 ", attributes: [NSForegroundColorAttributeName: UIColor(hex6: 0x333333)])
        let redString = NSAttributedString(string: " 低 ", attributes: [NSForegroundColorAttributeName: UIColor(hex6: 0x333333)])
        let trailString = NSAttributedString(string:  ";色块数字代表被评分次数", attributes: [NSForegroundColorAttributeName: UIColor(hex6: 0x999999)])

        let greenOne = NSTextAttachment()
        greenOne.image = #imageLiteral(resourceName: "icon_rectangle_green")
        let yellowOne = NSTextAttachment()
        yellowOne.image = #imageLiteral(resourceName: "icon_rectangle_yellow")
        let redOne = NSTextAttachment()
        redOne.image = #imageLiteral(resourceName: "icon_rectangle_orange")
        
        let piece = NSMutableAttributedString(attributedString: attributeString)
        piece.append(NSAttributedString(attachment: greenOne))
        piece.append(greenString)
        piece.append(NSAttributedString(attachment: yellowOne))
        piece.append(yellowString)
        piece.append(NSAttributedString(attachment: redOne))
        piece.append(redString)
        piece.append(trailString)
        
        title.attributedText = piece
        view.addSubview(title)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        emptyLabel = UILabel(frame: CGRect(x: 45, y: 200, width: view.frame.width - 90, height: 200))
        emptyLabel.text = "该年级园长暂未设置评价指标"
        emptyLabel.font = UIFont.systemFont(ofSize: 15)
        emptyLabel.textAlignment = .center
        emptyLabel.theme_textColor = Theme.Color.textColorlight
        
        view.addSubview(emptyLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataFromServert()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchDataFromServert() {
        
        RequestManager.POST(urlString: APIManager.Tongji.grownpj, params: ["token": LocaleSetting.token]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            self.formatDatas.removeAll()
            if let datas = data as? NSArray {
                //遍历，并赋值
                datas.forEach({ [unowned self] in
                    let target = JSONDeserializer<CYJFormData>.deserializeFrom(dict: $0 as? NSDictionary)
                    
                    self.formatDatas.append(target!)
                })
                //初始化第一波数据
                self.currentFormatDatas = self.formatDatas
                
                self.formatDataToTable()
                
                self.makeStatisticView()
            }
        }
    }
    
    func formatDataToTable() {
        
        guard selectedDomain.count == 0 else {
//            self.makeStatisticView()
            return
        }
        
        if let child = formatDatas.first {
            allDomains = child.domain!
            emptyLabel.isHidden = true

            if allDomains.count > 4 {
                selectedDomain = [allDomains[0],allDomains[1],allDomains[2],allDomains[3]]
            }else if allDomains.count > 0
            {
                var tmp = [CYJFormData.Domain]()
                for i in 0..<allDomains.count {
                    tmp.append(allDomains[i])
                }
                selectedDomain = tmp
            }else {
                emptyLabel.isHidden = false
            }
        }
    }
    
    func makeStatisticView() {
        
        guard selectedDomain.count > 0 else{
            return
        }
        
        var xVals = [XValue]()
        var yVals = [YValue]()
        //1. 为 x 轴加入第一个姓名的项
        let xfirst = XValue()
        xfirst.text = "姓名"
        xVals.append(xfirst)
        //2. 创建其他y的轴
        for i in 0..<currentFormatDatas.count {
            let formatData = currentFormatDatas[i]
            let yVal = YValue()
            yVal.text = formatData.realName
            yVal.yId = formatData.uId
            yVals.append(yVal)
        }
        //3. 创建x的轴
        for j in 0..<selectedDomain.count {

            let domain = selectedDomain[j]
            
                let xVal = XValue()
                xVal.text = domain.dName
            xVal.xId = domain.dId
                xVals.append(xVal)
        }
        
        //4. 创建内容
        var sVals = [[SValue]]()
        for n in 0..<currentFormatDatas.count {
            //1. 拿到幼儿
            let formatData = currentFormatDatas[n]
            
            var ssValue = [SValue]()
            for m in 0..<selectedDomain.count{
                //获取 selectedDomain 的item
                let domain = selectedDomain[m]

                let domSimple = formatData.domain?.first(where: { $0.dId == domain.dId})
                
                let sssVal = SValue()
                sssVal.text = "\(domSimple?.gSum ?? 0)"
                sssVal.level = Int(roundf(domSimple?.gNum ?? 0))
                
                ssValue.append(sssVal)
            }
            sVals.append(ssValue)
            
        }
        
        //TODO: 如果 statisticView 为空，那么新建，否则更新
        if statisticView == nil {
            let sView = CYJStatisticView(frame: CGRect(origin: CGPoint(x: 8, y: Theme.Measure.navigationBarHeight+44), size: CGSize(width: view.frame.width - 16, height: view.frame.height - 44 - 49 - Theme.Measure.navigationBarHeight )))
            self.currentData = (xVals,yVals,sVals)
            sView.data = (xVals,yVals,sVals)
            sView.delegate = self
            view.addSubview(sView)
            
            statisticView = sView
        }else
        {
            self.currentData = (xVals,yVals,sVals)
            statisticView?.data = (xVals,yVals,sVals)
        }
    }
}

extension CYJRECStatisticC: CYJStatisticViewDelegate {
    
    func statisticView(_ statisticView: CYJStatisticView, XdidClickedAt index: Int) {
        //
        DLog("XdidClickedAt")
        
        if index == 0 {
            // 筛选姓名
            nameSorted = !nameSorted
            self.currentFormatDatas = nameSorted ? self.formatDatas : self.formatDatas.reversed()
            makeStatisticView()

        }else{
            let domain = selectedDomain[index - 1]
            
            self.domainSorted = !self.domainSorted
            
            let arr = formatDatas.sorted(by: { (A,B) in
                let adomS = A.domain?.first(where: { $0.dId == domain.dId})
                let bdomS = B.domain?.first(where: { $0.dId == domain.dId})
                return domainSorted ? (adomS?.gSum)! > (bdomS?.gSum)! : (adomS?.gSum)! < (bdomS?.gSum)!
            })
            
            self.currentFormatDatas = arr
            
            makeStatisticView()

        }
        
    }
    func statisticView(_ statisticView: CYJStatisticView, YdidClickedAt index: Int) {
        DLog("YdidClickedAt \(index)")
        
        if let yValues = self.currentData?.1 {
            
            let child = yValues[index]
            let childId = child.yId
            
            let vc1 = CYJRECListControllerParent()
            vc1.uid = childId
            vc1.title = child.text
            vc1.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            self.navigationController?.pushViewController(vc1, animated: true)
        }
    }
    func statisticView(_ statisticView: CYJStatisticView, didClickedAt indexPath: IndexPath) {
        DLog("didClickedAt  \(indexPath.section) \(indexPath.row)")
        
        if let yValues = self.currentData?.1 ,let xValues = self.currentData?.0 {
            
            let child = yValues[indexPath.section]
            let childId = child.yId
            
            let domain = xValues[indexPath.row + 1]
            
            let vc1 = CYJRECListControllerParent()
            vc1.uid = childId
            vc1.did = domain.xId
            vc1.title = child.text
            vc1.view.frame = CGRect(x: 0, y: 0.5, width: Theme.Measure.screenWidth, height: Theme.Measure.screenHeight - Theme.Measure.navigationBarHeight)
            self.navigationController?.pushViewController(vc1, animated: true)
        }
    }
}


