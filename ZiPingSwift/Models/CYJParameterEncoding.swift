//
//  CYJParameter.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/16.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

/// 必须实现的 协议
protocol CYJParameterEncoding{
    var ignorePropreties: [String] {get}
    var matchPropreties :[String: String] {get}
}

// MARK: - 提供一个空的实现
extension CYJParameterEncoding{
    /// $0 - class Key , $1 - DictionaryKey
    var matchPropreties :[String: String] {
        return [:]
    }
    var ignorePropreties: [String] {
        return []
    }
    
    func encodeToDictionary() -> [String : Any] {
        
        let mirror = Mirror(reflecting: self)
        var pp = [String : Any]()
        for attr in mirror.children {
            if let tmp = valueToProperty(attr) {
                pp[tmp.0] = tmp.1
            }
//            else
//            {
////                print("\(attr.label!)的value 为空")
//            }
        }
        return pp
    }
    
    private func valueToProperty(_ child: Mirror.Child) -> (String, Any)? {
        
        var key = child.label!
        
        if ignorePropreties.contains(key) { //忽略
            return nil
        }
        
        if  matchPropreties.count > 0 {
            if matchPropreties.contains(where: { $0.key == key }) {
                key = matchPropreties[key]!
            }
        }
        
        if let value = child.value as? String {
            return (key , value)
        }else if let value = child.value as? Int {
            return (key , "\(value)")
        }else if let value = child.value as? UInt8 {
            return (key , "\(value)")
        }else if let value = child.value as? UInt16 {
            return (key , "\(value)")
        }else if let value = child.value as? UInt32 {
            return (key , "\(value)")
        }else if let value = child.value as? UInt64 {
            return (key , "\(value)")
        }else if let value = child.value as? Float {
            return (key , "\(value)")
        }else if let value = child.value as? Double {
            return (key , "\(value)")
        }else if let value = child.value as? Bool {
            return (key , value ? "1" : "2")
        }else if let value = child.value as? [Any]{
            return (key , value)
        }else if let value = child.value as? [AnyHashable: Any]{
            let jsonValue = jsonStringFromJsonObject(value)
            return (key , jsonValue)
        }else
        {
            return nil
        }
    }

    func jsonStringFromJsonObject(_ object: Any) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            let strJson = String(data: data, encoding: .utf8)
            return strJson ?? ""
        }catch
        {
            return ""
        }
    }
}


