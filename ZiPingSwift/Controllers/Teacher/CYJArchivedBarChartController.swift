//
//  CYJArchivedBarChartController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/20.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import HandyJSON
import Charts
import SwiftTheme

class CYJArchivedBarChartController: KYBaseViewController {
    
    /// 筛选列表的数据
    var grId: Int = 0
    
    /// 数据源
    var dataSource: CYJArchiveBarData?
    
    /// 表格数据
    var barChartData: BarChartData? {
        didSet{
            
            self.addLegendLabels()
        }
    }
    var legendLabels = [UILabel]()
    
    var chartView: BarChartView?
    
    let barChartViewHeight: CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.theme_backgroundColor = "Archived.archivedBackgroundColor"
        
        let backgroundImageView = UIImageView(frame: CGRect(x: 15, y: 20, width: Theme.Measure.screenWidth - 30, height: Theme.Measure.screenHeight - 64 - 40))
        backgroundImageView.backgroundColor = UIColor.clear
        backgroundImageView.image = #imageLiteral(resourceName: "dangandai-bg3")
        view.addSubview(backgroundImageView)
        requestChartData()
    }
    
    func requestChartData() {
        
        let chartParam: [String: Any] = ["token" : LocaleSetting.token, "gaId" : "\(self.grId)"]
        
        RequestManager.POST(urlString: APIManager.Archive.chartData, params: chartParam) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let chartDates = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<CYJArchiveBarData>.deserializeFrom(dict: chartDates)
                //FIXME: 创建Chart表
                self.dataSource = target
                
                self.formChartDate()
            }
        }
    }
    
    func formChartDate() {
        // 纬度
        var dataSets = [BarChartDataSet]()
        
        let mainColor = ThemeManager.color(for: "Nav.barTintColor")!

        var colors = [mainColor]
        
        if let axis = dataSource?.axis {
            for i in 0..<(axis.count) {
                
                let ax = axis[i]
                let entry = BarChartDataEntry(x: Double(i) , y: Double(ax.num) )
                let entries = [entry]
                
                let barChartDataSet = BarChartDataSet(values: entries , label: ax.title)
                barChartDataSet.colors = [colors[i % colors.count],UIColor.black]
                dataSets.append(barChartDataSet)
            }
            let barChartData = BarChartData(dataSets: dataSets)
            barChartData.barWidth = 0.5
            
            self.barChartData = barChartData
            
            self.makeCharts()
            
            self.addLegendLabels()
        }
    }
    
    
    func makeCharts() {
        
        let chartSize = CGSize(width: Theme.Measure.screenWidth - 50, height: barChartViewHeight)
        let chartOrigin = CGPoint(x: 25, y: 40)
        
        let chart = BarChartView(frame: CGRect(origin: chartOrigin, size: chartSize) )
        
        chart.setExtraOffsets(left: 10, top: 60, right: 40, bottom: 0)
        let chartDescription = Description()
        chartDescription.text = self.dataSource?.name
        chartDescription.position = CGPoint(x: (Theme.Measure.screenWidth - 30) * 0.5, y: 25)
        chartDescription.font = UIFont.systemFont(ofSize: 15)
        chartDescription.textColor = UIColor(hex6: 0x333333)
        chartDescription.textAlign = .center
        chartDescription.enabled = true
        
        let legend = chart.legend
        legend.enabled = false
        legend.direction = .leftToRight
        legend.form = .line
        
        chart.theme_backgroundColor = Theme.Color.ground
        chart.gridBackgroundColor = UIColor.white
        
        chart.chartDescription = chartDescription
        //        chart.delegate = self
        chart.dragDecelerationEnabled = false
        chart.noDataText = "noDataText"
        
        chart.drawValueAboveBarEnabled = true
        
        chart.drawBarShadowEnabled = false
        
        chart.fitBars = true
        
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        
        chart.leftAxis.axisMinimum = 0
        chart.rightAxis.axisMinimum = 0
        
        chart.pinchZoomEnabled = true
        chart.drawGridBackgroundEnabled = true
        
        let xAxisFormatter = CustomXAxisFormatter(decimals: 0)
        
        //设置Y轴，formater
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.numberStyle = .decimal
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.positiveFormat = "0.0"

        let valueFormatter = DefaultAxisValueFormatter(formatter: numberFormatter)
        chart.leftAxis.valueFormatter = valueFormatter
        chart.rightAxis.valueFormatter = valueFormatter
        
        //chart设置,x轴设置， 相应的可以设置左侧，右侧y轴
        let xAxis = chart.xAxis
        
        xAxis.labelPosition = .bottom //x轴的位置
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1.0
        
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.labelCount = 9
        //
        xAxis.drawLabelsEnabled = true
        xAxis.gridAntialiasEnabled = false
        xAxis.labelTextColor = UIColor(hex6: 0x666666)
        
        //        xAxis.labelCount = 12
        xAxis.valueFormatter = xAxisFormatter
        
        chart.data = self.barChartData
        
        self.chartView = chart
        view.addSubview(chart)
    }
    
    func addLegendLabels() {
        
        if let barChartData = barChartData {
            
            legendLabels.removeAll()
            
            for i in 0..<barChartData.dataSets.count {
                
                let leading = String(format: "%c", (65 + i))
                
                let trail = barChartData.dataSets[i].label
                
                let label = UILabel(frame: CGRect(x: 45, y: CGFloat(barChartViewHeight + 60 + CGFloat(21 * i)), width: Theme.Measure.screenWidth - 30, height: 21))
                label.font = UIFont.systemFont(ofSize: 12)
                label.theme_textColor = Theme.Color.textColorlight
                
                label.text = leading + " " + trail!
                view.addSubview(label)
                legendLabels.append(label)
            }
        }
    }
}
