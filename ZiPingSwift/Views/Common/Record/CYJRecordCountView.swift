//
//  CYJRecordCountView.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/11/20.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

class CYJRecordCountView: UIView {
    
    enum FilterType: String {
        case none = "全部"
        case time = "时间"
        case domain = "领域"
        case teacher = "记录人"
        case child = "幼儿"
    }
    
    private var countLabel: UILabel!
    
    private var clearButton: UIButton!
    
    var count: Int = 0 {
        didSet{
            updateKeys()
        }
    }
    var keys: [FilterType] = [.none, .none, .none, .none] {
        didSet{
            updateKeys()
        }
    }
    
    var clearButtonClickHandler: CYJCompleteHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.theme_backgroundColor = Theme.Color.line
        
        countLabel = UILabel(frame: CGRect(x: 15, y: 0, width: Theme.Measure.screenWidth - 105, height: 30))
        countLabel.theme_textColor = Theme.Color.textColorlight
        countLabel.textAlignment = .left
        countLabel.font = UIFont.systemFont(ofSize: 12)
        
        addSubview(countLabel)
        
        clearButton = UIButton(frame: CGRect(x: Theme.Measure.screenWidth - 85, y: 0, width: 75, height: 30))
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        clearButton.theme_setTitleColor(Theme.Color.main, forState: .normal)
        clearButton.setTitle("显示全部记录", for: .normal)
        clearButton.addTarget(self, action: #selector(clearButtonClicked), for: .touchUpInside)
        
        addSubview(clearButton)
    }
    
    @objc private func clearButtonClicked() {
        guard let clear = clearButtonClickHandler else {
            return
        }
        clear(nil)
    }
    
    /// 如果存在，删除
    ///
    /// - Parameter key: <#key description#>
    func removeKey(key : FilterType) {
        if let index = keys.index(where: { $0 == key}){
            keys[index] = .none
        }
    }
    
    /// 如果不存在，那么删除
    ///
    /// - Parameter key: <#key description#>
    func addKey(key: FilterType) {
        
            guard !(keys.contains(key)) else{
                //忽略
                return
            }
        
        switch key {
        case .time:
            keys[0] = .time
        case .domain:
            keys[1] = .domain
        case .teacher:
            keys[2] = .teacher
        case .child:
            keys[3] = .child
        default: break
        }
    }
    
    private func updateKeys() {
        var keykey = ""
        let rowVals = keys.filter {$0 != .none}.map { $0.rawValue}
        if rowVals.count > 0 {
            keykey = "(已按 \(rowVals.joined(separator: " ")) 筛选)"
            clearButton.isHidden = false
        }else {
            keykey = ""
            clearButton.isHidden = true
        }

        countLabel.text = "共\(count)条 \(keykey)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
