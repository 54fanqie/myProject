//
//  CYJTheme.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/9/7.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import SwiftTheme


let theme_NavTitleAttributes = ThemeDictionaryPicker.pickerWithDicts([
    [NSForegroundColorAttributeName: UIColor.white],
    [NSForegroundColorAttributeName: UIColor.white],
    [NSForegroundColorAttributeName: UIColor.white],
    [NSForegroundColorAttributeName: UIColor.white]])

let theme_ButtonTitleAttributes = ThemeDictionaryPicker.pickerWithDicts([
    [NSForegroundColorAttributeName: UIColor.white],
    [NSForegroundColorAttributeName: UIColor.white],
    [NSForegroundColorAttributeName: UIColor.white],
    [NSForegroundColorAttributeName: UIColor.white]])

enum CYJThemes: Int {
    
//    case yello
    case pink = 0
    case blue
    case green

    
//    case night
//    case red

    case maxCount
    
    // MARK: -
    
    static var current: CYJThemes = .pink

    static var before  = CYJThemes.pink
    
    // MARK: - Switch Theme
    
    static func switchTo(_ theme: CYJThemes) {
        before  = current
        current = theme
        
//        ThemeManager.setTheme(index: theme.rawValue)
        
        UserDefaults.standard.set(theme.rawValue, forKey: CYJUserDefaultKey.currentTheme)
        switch theme {
        case .pink   :
            ThemeManager.setTheme(plistName: "Pink", path: .mainBundle)
        case .blue  :
            ThemeManager.setTheme(plistName: "Blue", path: .mainBundle)
        case .green   :
            ThemeManager.setTheme(plistName: "Green", path: .mainBundle)
        
//        case .red   : ThemeManager.setTheme(plistName: "Red", path: .mainBundle)
//        case .yello : ThemeManager.setTheme(plistName: "Yellow", path: .mainBundle)
//        case .night : ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
        default: break
        }
    }
    
    static func switchToNext() {
        var next = current.rawValue + 1
        let max  = 2 // without Blue and Night
        
        //        if isBlueThemeExist() { max += 1 }
        if next >= max { next = 0 }
        
        switchTo(CYJThemes(rawValue: next)!)
    }
    
    /**
    // MARK: - Switch Night
    static func switchNight(_ isToNight: Bool) {
        switchTo(isToNight ? .night : before)
    }
    
    static func isNight() -> Bool {
        return current == .night
    }
    */
    // MARK: - Download
    
    //    static func downloadBlueTask(_ handler: @escaping (_ isSuccess: Bool) -> Void) {
    //
    //        let session = URLSession.shared
    //        let url = "https://github.com/jiecao-fm/SwiftThemeResources/blob/master/20170128/Blue.zip?raw=true"
    //        let URL = Foundation.URL(string: url)
    //
    //        let task = session.downloadTask(with: URL!, completionHandler: { location, response, error in
    //
    //            guard let location = location , error == nil else {
    //                DispatchQueue.main.async {
    //                    handler(false)
    //                }
    //                return
    //            }
    //
    //            let manager = FileManager.default
    //            let zipPath = cachesURL.appendingPathComponent("Blue.zip")
    //
    //            _ = try? manager.removeItem(at: zipPath)
    //            _ = try? manager.moveItem(at: location, to: zipPath)
    //
    //            let isSuccess = SSZipArchive.unzipFile(atPath: zipPath.path,
    //                                                   toDestination: unzipPath.path)
    //
    //            DispatchQueue.main.async {
    //                handler(isSuccess)
    //            }
    //        })
    //
    //        task.resume()
    //    }
    //
    //    static func isBlueThemeExist() -> Bool {
    //        return FileManager.default.fileExists(atPath: blueDiretory.path)
    //    }
    //
    //    static let blueDiretory : URL = unzipPath.appendingPathComponent("Blue/")
    //    static let unzipPath    : URL = libraryURL.appendingPathComponent("Themes/20170128")
    
}

/// 获取目标主题的各种颜色
extension ThemeManager {
    
    class func targetTheme(theme: CYJThemes) -> NSDictionary? {
        
        var plistName: String
        let path = ThemePath.mainBundle
        switch theme {
//        case .white : plistName = "White"
//        case .red   : plistName = "Red"
//        case .yello : plistName = "Yellow"
        case .pink  : plistName = "Pink"
        case .blue  : plistName = "Blue"
        case .green  : plistName = "Green"

//        case .night : plistName = "Night"
        default: plistName = "White"
        }
        guard let plistPath = path.plistPath(name: plistName)         else {
            print("SwiftTheme WARNING: Not find plist '\(plistName)' with: \(path)")
            return nil
        }
        guard let plistDict = NSDictionary(contentsOfFile: plistPath) else {
            print("SwiftTheme WARNING: Not read plist '\(plistName)' with: \(plistPath)")
            return nil
        }
        return plistDict
    }
    
    class func color(for target: NSDictionary?, keyPath: String) -> UIColor? {
        
        guard let rgba = string(for: target, withKeyPath: keyPath) else { return nil }
        guard let color = try? UIColor(rgba_throws: rgba) else {
            print("SwiftTheme WARNING: Not convert rgba \(rgba) at key path: \(keyPath)")
            return nil
        }
        return color
    }
    
    class func string(for target: NSDictionary?, withKeyPath: String) -> String? {
        guard let string = target?.value(forKeyPath: withKeyPath) as? String else {
            print("SwiftTheme WARNING: Not found string key path: \(withKeyPath)")
            return nil
        }
        return string
    }
    
}
