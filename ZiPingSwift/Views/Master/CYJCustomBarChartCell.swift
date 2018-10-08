//
//  CYJCustomBarChartCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/7.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Charts

class CYJCustomBarChartCell: UITableViewCell {
    
    var chartView: BarChartView!
    
    var isAnimated: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "CYJCustomBarChartCell")
        
        backgroundColor = UIColor.white
        
        let chartSize = CGSize(width: Theme.Measure.screenWidth, height: 200)
        let chartOrigin = CGPoint(x: 0, y: 0)
        
        let chart = BarChartView(frame: CGRect(origin: chartOrigin, size: chartSize) )
        
        chart.setExtraOffsets(left: 40, top: 60, right: 40, bottom: 0)
        
        //调整legend位置
        let legend = chart.legend
        legend.enabled = false
        legend.direction = .leftToRight
        legend.form = .line
        legend.form = .square
        legend.verticalAlignment = .center
        legend.yEntrySpace = 30
        
        chart.theme_backgroundColor = Theme.Color.ground
        chart.gridBackgroundColor = UIColor.white
        
        //        chart.delegate = self
        chart.dragDecelerationEnabled = false
        chart.noDataText = "该领域／维度下成长分析为空"
        
        chart.drawValueAboveBarEnabled = true
        
        chart.drawBarShadowEnabled = false
        
        chart.fitBars = true
        //line 设置为0
        chart.leftAxis.drawZeroLineEnabled = true
        chart.rightAxis.drawZeroLineEnabled = true
        chart.leftAxis.axisMinimum = 0
        chart.rightAxis.axisMinimum = 0
        
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        
        chart.pinchZoomEnabled = true
        chart.drawGridBackgroundEnabled = true
        
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.numberStyle = .decimal
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.positiveFormat = "0.0"
        
        let valueFormatter = DefaultAxisValueFormatter(formatter: numberFormatter)
        chart.leftAxis.valueFormatter = valueFormatter
        chart.rightAxis.valueFormatter = valueFormatter
        
        
        let xAxisFormatter = CustomXAxisFormatter(decimals: 0)
        
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
        
        contentView.addSubview(chart)
        chartView = chart
    }
    
    var title: String? {
        didSet{
            let chartDescription = Description()
            chartDescription.text = title
            chartDescription.position = CGPoint(x: Theme.Measure.screenWidth * 0.5, y: 25)
            chartDescription.font = UIFont.systemFont(ofSize: 15)
            chartDescription.textColor = UIColor(hex6: 0x333333)
            chartDescription.textAlign = .center
            
            chartDescription.enabled = true
            self.chartView.chartDescription = chartDescription
        }
    }
    var barChartData: BarChartData? {
        didSet{
            chartView.clear()
            chartView.data = barChartData
            
            self.addLegendLabels()
        }
    }
    var legendLabels = [UILabel]()
    
    func addLegendLabels() {
        
        if let barChartData = barChartData {
            
            //TODO: 从父试图删除labels，并 擦除legendLabels
            legendLabels.forEach({ (label) in
                label.removeFromSuperview()
            })
            
            legendLabels.removeAll()
            
            for i in 0..<barChartData.dataSets.count {
                
                let leading = String(format: "%c", (65 + i))
                
                let trail = barChartData.dataSets[i].label
                
                let label = UILabel(frame: CGRect(x: 15, y: CGFloat(200 + 21 * i), width: Theme.Measure.screenWidth - 30, height: 21))
                label.font = UIFont.systemFont(ofSize: 12)
                label.theme_textColor = Theme.Color.textColorlight
                
                label.text = leading + " " + trail!
                addSubview(label)
                legendLabels.append(label)
            }
        }
    }
    
    func animateOut() {
        guard !isAnimated else {
            return
        }
        isAnimated = true
        chartView.animate(xAxisDuration: 1.3, yAxisDuration: 1.3, easingOption: .easeInOutExpo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomXAxisFormatter: DefaultAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if block != nil
        {
            return block!(value, axis)
        }
        else
        {
            return String(format: "%c", (65 + Int(value)))
        }
    }
}
