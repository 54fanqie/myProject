//
//  AttachManager.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/5/18.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Alamofire
import ImageIO

/// 附件类
class AttachFormat:  NSObject, NSCoding {
    var filename: String?
    var format: String?
    var serverPath: String?
    var localPath: String?
    //    var localPath: String?
    
    
    // MARK:- 处理需要归档的字段
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(filename, forKey:"filename")
        aCoder.encode(format, forKey:"format")
        aCoder.encode(serverPath, forKey:"serverPath")
        aCoder.encode(localPath, forKey:"localPath")
    }
    
    // MARK:- 处理需要解档的字段
    required init(coder aDecoder: NSCoder) {
        super.init()
        filename = aDecoder.decodeObject(forKey:"filename")as? String
        format = aDecoder.decodeObject(forKey:"format")as? String
        serverPath = aDecoder.decodeObject(forKey:"serverPath")as? String
        localPath = aDecoder.decodeObject(forKey:"localPath")as? String
        
    }
    
    override init() {
        super.init()
    }
}


/// 缓存的路径
var AttachCachePath: String = {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    
    return "\(paths.first!)/discuss"
}()

/// 附件管理类
class AttachManager {
    
    /// defalut
    static let `default` = AttachManager()
    
    let manager = FileManager.default
    /// 存放缓存文件的目录
    let AttachCatalogueName = "attachCatalogue.plist"
    
    /// 缓存的对象数组，懒加载
    lazy var cacheItems: [AttachFormat] = {
        //        print("只在首次访问输出")
        let path = "\(AttachCachePath)/\(self.AttachCatalogueName)"
        var array: [AttachFormat] = []
        
        let exist = FileManager.default.fileExists(atPath: path)
        
        if exist {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                array = (NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [AttachFormat])!
                return array
                
            } catch {
                return []
            }
        }
        return []
        
    }()
    
    /// 下载附件
    ///
    /// - Parameters:
    ///   - urlString: 路径
    ///   - complete: 完成事件
    func downloadAttachment(urlString: String, complete: @escaping (_ data: AttachFormat?)-> Void){
        
        if let contains = contants(urlString: urlString) {
            //如果能够找到文件
            DLog(contains)
            complete(contains)
        }else
        {
            
            let paths = urlString.components(separatedBy: "/")
            let folder = paths[paths.count - 3]
            let localFolder = folder
            
            //downLoadImage
            Alamofire.download(URLRequest(url: URL(string: urlString)!), to: { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                
                let url = URL(fileURLWithPath: "\(AttachCachePath)/\(localFolder)/\(response.suggestedFilename ?? "default")")
                DLog("url:" + url.path)
                
                return (url, DownloadRequest.DownloadOptions.createIntermediateDirectories)
                
                
            }).responseData(completionHandler: { (data) in
                switch data.result {
                case .success(_):
                    
                    
                    let attachFormat = AttachFormat()
                    attachFormat.filename = data.response?.suggestedFilename
                    attachFormat.format = data.response?.mimeType
                    attachFormat.serverPath = urlString
                    attachFormat.localPath = localFolder + "/" + (data.response?.suggestedFilename)!
                    //成功后写入plist
                    let _ = self.write2plist(attachFormat: attachFormat)
                    complete(attachFormat)
                    
                case .failure(let error):
                    DLog(error)
                    let nsError = error as NSError
                    if nsError.code == 516 // 已存在相同文件，那么直接用
                    {
                        if let contains = self.contants(urlString: urlString) {
                            //如果能够找到文件
                            DLog(contains)
                            complete(contains)
                        }
                    }
                }
            })
        }
        //        DLog("countAttach:\(countAttach())-")
    }
    
    
    
    func contants(urlString: String) -> AttachFormat? {
        
        let precidate = NSPredicate(format: "serverPath = $URLSTRING")
        precidate.withSubstitutionVariables(["URLSTRING" : urlString])
        
        let contains = cacheItems.filter { (format) -> Bool in
            
            if let spath = format.serverPath {
                return spath == urlString
            }else{
                return false
            }
        }
        if contains.count > 0 {
            return contains.first
        }else
        {
            return nil
        }
        
    }
    
    func write2plist(attachFormat: AttachFormat) -> Bool {
        
        cacheItems.insert(attachFormat, at: 0)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: cacheItems)
        let path = "\(AttachCachePath)/\(AttachCatalogueName)"
        
        do {
            try data.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.noFileProtection)
        }catch
        {
            return false
        }
        return true
    }
    /// 清空所有数据
    func clearAttachmentCache() {
        //删除文件，重新创建文件
        cacheItems.removeAll()
        if manager.fileExists(atPath: AttachCachePath){
            try! manager.removeItem(atPath: AttachCachePath)
            try! manager.createDirectory(atPath: AttachCachePath, withIntermediateDirectories: true,
                                         attributes: nil)
            
        }
    }
    
    func getImage(name: String) -> UIImage? {
        
        do {
            let path = "\(AttachCachePath)/\(name)"
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            let localImage = UIImage(data: data)
            
            return localImage!
        }catch{
            return nil
        }
    }
    func getGifImage(name: String) -> (Double, [UIImage])? {
        
        do {
            let path = "\(AttachCachePath)/\(name)"
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            let options: NSDictionary = [kCGImageSourceShouldCache as String: NSNumber(booleanLiteral: true), kCGImageSourceTypeIdentifierHint as String: "kUTTypeGIF"]
            
            if let imageSource = CGImageSourceCreateWithData(data as CFData, options){
                
                let frameCount = CGImageSourceGetCount(imageSource)
                var images = [UIImage]()
                var gifDuration = 0.0
                
                for i in 0..<frameCount {
                    guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, options) else {
                        return nil
                    }
                    if frameCount == 1 {
                        // 单帧
                        gifDuration = Double.infinity
                        
                    } else{
                        // gif 动画
                        // 获取到 gif每帧时间间隔
                        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) , let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                            let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else
                        {
                            return nil
                        }
                        //时间间隔
                        gifDuration += frameDuration.doubleValue
                        
                        // 获取帧的img
                        let  image = UIImage(cgImage: imageRef , scale: UIScreen.main.scale , orientation: UIImageOrientation.up)
                        
                        // 添加到数组
                        images.append(image)
                    }
                }
                return (gifDuration,images)
            }
            return nil
        }catch{
            return nil
        }
    }
    
    func countAttach() -> UInt
    {
        if !manager.fileExists(atPath: AttachCachePath){
            return 0
        }
        
        var fileSize:UInt = 0
        do {
            let files = try manager.contentsOfDirectory(atPath: AttachCachePath)
            for file in files {
                let path = AttachCachePath + "/\(file)"
                fileSize = fileSize + self.fileSizeAtPath(filePath: path)
            }
        }   catch {
        }
        print("\(fileSize)")
        return fileSize
    }
    
    func fileSizeAtPath(filePath:String) -> UInt {
        var fileSize:UInt = 0
        if manager.fileExists(atPath: filePath) {
            do {
                let attr = try manager.attributesOfItem(atPath: filePath)
                fileSize = attr[FileAttributeKey.size] as! UInt
                
            } catch {
            }
        }
        return fileSize
    }
    
}
//MARK: ImageView extension
extension UIImageView{
    
    func setImage(_downloadImage urlString: String) {
        
        AttachManager.default.downloadAttachment(urlString: urlString) { (attach) in
            
            if attach?.format == "image/jpeg" || attach?.format == "image/png"
            {
                guard let img = AttachManager.default.getImage(name: (attach?.localPath)!) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.image = img
                }
            }
            if attach?.format == "image/gif"
            {
                let path = "\(AttachCachePath)/\((attach?.localPath)!)"
                
                self.kf.setImage(with: URL(fileURLWithPath: path))
                
            }
        }
    }
    
    func setImage(_downloadImage urlString: String, complete: @escaping ()->Void ) {
        
        AttachManager.default.downloadAttachment(urlString: urlString) { (attach) in
            
            if attach?.format == "image/jpeg" || attach?.format == "image/png"
            {
                guard let img = AttachManager.default.getImage(name: (attach?.localPath)!) else {
                    return
                }
                self.image = img
            }
            if attach?.format == "image/gif"
            {
                let path = "\(AttachCachePath)/\((attach?.localPath)!)"
                
                self.kf.setImage(with: URL(fileURLWithPath: path))
            }
            
            complete()
        }
    }
}
//MARK: UIButton extension

extension UIButton{
    func setImage(_downloadImage urlString: String,for state: UIControlState ) {
        
        AttachManager.default.downloadAttachment(urlString: urlString) { (attach) in
            
            if attach?.format == "image/jpeg" || attach?.format == "image/png"
            {
                guard let img = AttachManager.default.getImage(name: (attach?.localPath)!) else {
                    return
                }
                self.setImage(img, for: state)
            }
            if attach?.format == "image/gif"
            {
                let path = "\(AttachCachePath)/\((attach?.localPath)!)"
                
                self.kf.setImage(with: URL(fileURLWithPath: path),for: state)
            }
            
        }
    }
}

