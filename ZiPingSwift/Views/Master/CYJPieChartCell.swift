//
//  CYJPieChartCell.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/7.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Charts

import SnapKit

class CYJPieChartCell: UITableViewCell {
    
    var title: String? {
        didSet{
            pieChartView.chartDescription?.text = title
            pieChartView.chartDescription?.position = CGPoint(x: Theme.Measure.screenWidth * 0.5 - 40, y: 25)
        }
    }
    var pieChartData: PieChartData! {
        didSet{
            //晴空先
            pieChartView.clear()
            
            pieChartView.data = pieChartData
            
            if let dataSet = pieChartData.getDataSetByIndex(0) {
                if dataSet.entryCount > 0 {
                    emptyLabel.isHidden = true
                }else {
                    emptyLabel.isHidden = false
                    contentView.bringSubview(toFront: emptyLabel)
                }
            }
        }
    }
    
    var legendLabels = [UILabel]()
    
//    func addLegendLabels() {
//
//        if let barChartData = barChartData {
//
//            //TODO: 从父试图删除labels，并 擦除legendLabels
//            legendLabels.forEach({ (label) in
//                label.removeFromSuperview()
//            })
//
//            legendLabels.removeAll()
//
//            for i in 0..<barChartData.dataSets.count {
//
//                let leading = String(format: "%c", (65 + i))
//
//                let trail = barChartData.dataSets[i].label
//
//                let label = UILabel(frame: CGRect(x: 15, y: CGFloat(200 + 21 * i), width: Theme.Measure.screenWidth - 30, height: 21))
//                label.font = UIFont.systemFont(ofSize: 12)
//                label.theme_textColor = Theme.Color.textColorlight
//
//                label.text = leading + " " + trail!
//                addSubview(label)
//                legendLabels.append(label)
//            }
//        }
//    }
    
    /// 当评价领域为空时，直接显示emptyLabel，并设置默认文字
    var noDomainOrDimension: Bool = false {
        didSet{
            
            if noDomainOrDimension { // true  没有评价
                emptyLabel.frame = CGRect(x: 30, y: Theme.Measure.screenWidth * 0.26, width: Theme.Measure.screenWidth - 60, height: Theme.Measure.screenWidth * 0.48)
                emptyLabel.textColor = UIColor.gray
                emptyLabel.backgroundColor = UIColor.clear
                emptyLabel.font = UIFont.systemFont(ofSize: 15)
                emptyLabel.text = "该年级暂未设置评价指标"
                emptyLabel.textAlignment = .center
                emptyLabel.layer.cornerRadius = Theme.Measure.screenWidth * 0.24
                emptyLabel.layer.masksToBounds = true
                emptyLabel.isHidden = false
                self.pieChartView.isHidden = true
                
            }else {
                emptyLabel.frame = CGRect(x: Theme.Measure.screenWidth * 0.26, y: 60, width: (Theme.Measure.screenWidth - 40) * 0.48, height: (Theme.Measure.screenWidth - 40) * 0.48)
                emptyLabel.textColor = UIColor.gray
                emptyLabel.backgroundColor = UIColor(hex6: 0xE4E4E4)
                emptyLabel.font = UIFont.systemFont(ofSize: 26)
                emptyLabel.text = "暂未使用"
                emptyLabel.textAlignment = .center
                emptyLabel.layer.cornerRadius = (Theme.Measure.screenWidth - 40) * 0.48 * 0.5
                emptyLabel.layer.masksToBounds = true
                //                emptyLabel.isHidden = true
                self.pieChartView.isHidden = false
            }
        }
    }
    
    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel(frame: CGRect(x: Theme.Measure.screenWidth * 0.26, y: 60, width: (Theme.Measure.screenWidth - 40) * 0.48, height: (Theme.Measure.screenWidth - 40) * 0.48))
        emptyLabel.textColor = UIColor.gray
        emptyLabel.backgroundColor = UIColor(hex6: 0xE4E4E4)
        emptyLabel.font = UIFont.systemFont(ofSize: 26)
        emptyLabel.text = "暂未使用"
        emptyLabel.textAlignment = .center
        emptyLabel.layer.cornerRadius = Theme.Measure.screenWidth * 0.24
        emptyLabel.layer.masksToBounds = true
        emptyLabel.isHidden = true
        return emptyLabel
    }()
    
    var pieChartView: PieChartView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        let chartSize = CGSize(width: Theme.Measure.screenWidth - 40, height: frame.height)
        let chartOrigin = CGPoint(x: 20, y: 0)
        
        pieChartView = PieChartView(frame: CGRect(origin: chartOrigin, size: chartSize))
        
        let chartDescription = Description()
        chartDescription.text = "I'm chart description"
        
        pieChartView.chartDescription = chartDescription
        //        chart.delegate = self
        pieChartView.dragDecelerationEnabled = false
        pieChartView.noDataText = "未完成"
        
        //基本样式
        pieChartView.setExtraOffsets(left: 30 , top: 0, right: 30, bottom: 0)//饼状图距离边缘的间隙
        pieChartView.usePercentValuesEnabled = true;//是否根据所提供的数据, 将显示数据转换为百分比格式
        pieChartView.dragDecelerationEnabled = false;//拖拽饼状图后是否有惯性效果
        pieChartView.drawEntryLabelsEnabled = false;//是否显示区块文本
        //        //空心饼状图样式
        pieChartView.centerText = nil
        pieChartView.drawHoleEnabled = false;//饼状图是否是空心
        pieChartView.holeRadiusPercent = 0.5;//空心半径占比
        pieChartView.holeColor = UIColor.clear;//空心颜色
        pieChartView.transparentCircleRadiusPercent = 0.53;//半透明空心半径占比
        pieChartView.transparentCircleColor = UIColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 0.3);//半透明空心的颜色
        //实心饼状图样式
        //        pieChartView.drawHoleEnabled = false
        pieChartView.rotationEnabled = true //旋转
        
        //饼状图描述
        pieChartView.chartDescription?.font = UIFont.systemFont(ofSize: 15)
        pieChartView.chartDescription?.textColor = UIColor(hex6: 0x666666)
        pieChartView.chartDescription?.textAlign = .center
        
        //饼状图图例
        let legend = pieChartView.legend
//        legend.enabled = false
        //horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
        legend.horizontalAlignment = .left        //图例在饼状图中的位置
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.direction = .leftToRight
        legend.drawInside = true
        
        legend.maxSizePercent = 0.95;           //图例在饼状图中的大小占比, 这会影响图例的宽高
        legend.formToTextSpace = 10;            //文本间隔
        legend.font = UIFont.systemFont(ofSize: 12) //字体大小
        legend.textColor = UIColor.gray                    //字体颜色
        legend.form = .circle                       //图示样式: 方形、线条、圆形
        legend.formSize = 12                        //图示大小
        //        legend.yOffset = 20
        contentView.addSubview(pieChartView)
        contentView.addSubview(emptyLabel)
        
        pieChartView.snp.makeConstraints { (maker) in
            maker.top.equalTo(contentView.snp.top).offset(-10)
            maker.left.equalTo(contentView.snp.left).offset(32)
            maker.right.equalTo(contentView.snp.right).offset(-32)
            maker.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func legendSize(piedata: PieChartData) -> CGFloat {
        let chartSize = CGSize(width: Theme.Measure.screenWidth - 80, height: 300)
        let chartOrigin = CGPoint(x: 0, y: 0)
        
        let pie = PieChartView(frame: CGRect(origin: chartOrigin, size: chartSize))
        
        let chartDescription = Description()
        chartDescription.text = "I'm chart description"
        
        pie.chartDescription = chartDescription
        //        chart.delegate = self
        pie.dragDecelerationEnabled = false
        pie.noDataText = "未完成"
        
        //基本样式
        pie.setExtraOffsets(left: 20 , top: 0, right: 20, bottom: 0)//饼状图距离边缘的间隙
        pie.usePercentValuesEnabled = true;//是否根据所提供的数据, 将显示数据转换为百分比格式
        pie.dragDecelerationEnabled = false;//拖拽饼状图后是否有惯性效果
        pie.drawEntryLabelsEnabled = false;//是否显示区块文本
        //        //空心饼状图样式
        pie.centerText = nil
        pie.drawHoleEnabled = false;//饼状图是否是空心
        pie.holeRadiusPercent = 0.5;//空心半径占比
        pie.holeColor = UIColor.clear;//空心颜色
        pie.transparentCircleRadiusPercent = 0.53;//半透明空心半径占比
        pie.transparentCircleColor = UIColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 0.3);//半透明空心的颜色
        //实心饼状图样式
        //        pieChartView.drawHoleEnabled = false
        pie.rotationEnabled = true //旋转
        
        //饼状图描述
        pie.chartDescription?.font = UIFont.systemFont(ofSize: 15)
        pie.chartDescription?.textColor = UIColor(hex6: 0x666666)
        pie.chartDescription?.textAlign = .center
        
        //饼状图图例
        let legend = pie.legend
        //        legend.enabled = false
        //horizontalAlignment`, `verticalAlignment`, `orientation`, `drawInside`, `direction`.")
        legend.horizontalAlignment = .left        //图例在饼状图中的位置
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.direction = .leftToRight
        legend.drawInside = true
        
        legend.maxSizePercent = 0.95;           //图例在饼状图中的大小占比, 这会影响图例的宽高
        legend.formToTextSpace = 10;            //文本间隔
        legend.font = UIFont.systemFont(ofSize: 12) //字体大小
        legend.textColor = UIColor.gray                    //字体颜色
        legend.form = .circle                       //图示样式: 方形、线条、圆形
        legend.formSize = 12                        //图示大小
        
        pie.data = piedata
        
        return legend.neededHeight
    }
    
}

//MARK: 设置饼状图的文字
/// 设置饼状图的文字
class DigitValueFormatter: NSObject, IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let valueWithoutDecimalPart = String(format: "%.2f%%", value)
        return valueWithoutDecimalPart
    }
}
