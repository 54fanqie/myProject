//
//  CYJMediaUploader.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/10/16.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import Photos

class CYJMediaImage: CYJParameterEncoding {
    var oldName: String? //": "a.jpg",
    var url: String? //": "b.jpg",
    var size: UInt8 = 0 //": "123",
    var suffix: String? //": "jpg"
    var videoPath: String? // 视频的图片
    var fileType: Int = 1 // 1. 视频，2 图片
    var minSize: Int = 0 // 1. 视频，2 图片
    
    
    var localPath: String?
    var localIdentifier: String?
    
    var ignorePropreties: [String] {
        return ["localPath", "localIdentifier", "fileType"]
    }
}

protocol CYJMediaUploaderDelegate: class {
    
    func imagesUploadComplete(mediaImage: [CYJMediaImage]? ,error: Error?) -> Void
    
    func videoUploadComplete(_ urlString: String) -> Void
}
extension CYJMediaUploaderDelegate {
    
    func imagesUploadComplete(mediaImage: [CYJMediaImage]? ,error: Error?) -> Void {}

    func videoUploadComplete(_ urlString: String) -> Void {}
}

class CYJMediaUploader: NSObject {
    
    weak var delegate: CYJMediaUploaderDelegate?
    
    var videoCachePath: String {
        let resourceCacheDir = NSHomeDirectory() + "/Library/Caches/UploadVideo/"
        if !FileManager.default.fileExists(atPath: resourceCacheDir) {
            do{
                try FileManager.default.createDirectory(atPath: resourceCacheDir, withIntermediateDirectories: true, attributes: nil)
            }catch
            {
                Third.toast.message("创建失败")
            }
        }
        return resourceCacheDir
    }
    
    static var `default`: CYJMediaUploader = CYJMediaUploader()
    
    var client: COSClient
    
//    var sign: String?
    
    var bucket = "ezp"
    
    private override init() {
        client = COSClient(appId: "1255326660", withRegion: "sh")
        client.openHTTPSrequset(true)
        COSClient.openLog(false)
        super.init()
    }
    
    func uploadImage(path: String, fileName: String, dir: String ,complete: @escaping (_ urlString: String)->Void) {
        
        RequestManager.POST(urlString: APIManager.Media.photoServer, params: ["token": LocaleSetting.token]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.hide {}
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            guard let sign = data as? String else{
                return
            }
//            self.sign = sign
            let task = COSObjectPutTask(path: path, sign: sign, bucket: self.bucket, fileName: fileName, customAttribute: "customAttribute", uploadDirectory: dir, insertOnly: true)
            
            self.client.completionHandler = { resp,context in
                
                if let rsp = resp as? COSObjectUploadTaskRsp {
                    if rsp.retCode == 0 { //成功
                        let text = rsp.sourceURL
                        complete(text!)
                    }else {
                        DLog(rsp.descMsg)
                        Third.toast.hide {}
                        Third.toast.message(rsp.descMsg)
                    }
                }
            }
            //put object
            self.client.putObject(task)
            
        }
    }
    
    func uploadAssets(assets: [PHAsset], dir: String) -> Void {
        
        RequestManager.POST(urlString: APIManager.Media.photoServer, params: ["token": LocaleSetting.token]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.hide {}
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            DLog("\(self.client)")
            guard let sign = data as? String else {
                return
            }
            
//            self.sign = data as? String
            var urlStrings = [String]()
            // 创建全部的回调
            
            let medias = self.saveMutipleImageLocal(assets: assets)
            
            medias.forEach({ (mediaImage) in
                let fileName = mediaImage.url

                let task = COSObjectPutTask(path: mediaImage.localPath!, sign: sign, bucket: self.bucket, fileName: fileName!, customAttribute: "customAttribute", uploadDirectory:  "pic", insertOnly: true)
                
                self.client.completionHandler = { resp,context in
                    
                    if let rsp = resp as? COSObjectUploadTaskRsp {
                        if rsp.retCode == 0 { //成功
//                            let text = rsp.sourceURL
//                            complete(text!)
                            DLog(mediaImage.localPath! + "-to-" + rsp.sourceURL)
                            urlStrings.append(rsp.sourceURL)
                            if urlStrings.count == medias.count {
                                if let delegate = self.delegate {
                                    //当上传之后的个数满足需要，那么给一个回调出去
                                    delegate.imagesUploadComplete(mediaImage: medias, error: nil)
                                }
                            }
                        }else {
                            DLog(rsp.descMsg)
                            
                            let error = NSError(domain: "com.chnyoujiao.zipingswift", code: Int(resp?.retCode ?? 0), userInfo: [kCFErrorDescriptionKey : rsp.descMsg])
//                            error.localizedDescription = rsp.descMsg
                            Third.toast.hide {}
                            Third.toast.message(rsp.descMsg)
                            //重新注册一下吧还是
                            self.client = COSClient(appId: "1255326660", withRegion: "sh")
                            self.client.openHTTPSrequset(true)
                            
                            if let delegate = self.delegate {
                                //当上传之后的个数满足需要，那么给一个回调出去
                                delegate.imagesUploadComplete(mediaImage: nil, error: error)
                            }
                        }
                    }
                }
                //put object
                self.client.putObject(task)
            })
        }
    }
    
    
    
    func photoSavePath() -> String {
        //FIXME: 需要清理缓存
        let resourceCacheDir = NSHomeDirectory() + "/Library/Caches/UploadPhoto/"
        if !FileManager.default.fileExists(atPath: resourceCacheDir) {
            do{
                try FileManager.default.createDirectory(atPath: resourceCacheDir, withIntermediateDirectories: true, attributes: nil)
            }catch
            {
            }
        }
        
        return resourceCacheDir
    }
    
    func saveMutipleImageLocal(assets: [PHAsset]) -> [CYJMediaImage] {
        
        let photoPath = self.photoSavePath()
        
        var savedImages = [CYJMediaImage]()
        
        let requestOpin = PHImageRequestOptions()
        requestOpin.deliveryMode = .highQualityFormat
        requestOpin.isSynchronous = true
        requestOpin.resizeMode = .exact
        
        assets.forEach { (asset) in
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1242, height: CGFloat(MAXFLOAT)), contentMode: .aspectFit, options: requestOpin, resultHandler: { (image, options) in
                
                let imageURL = options!["PHImageFileURLKey"] as! URL
                print("路径：",imageURL)
                print("文件名：",imageURL.lastPathComponent)
                
                let data = UIImageJPEGRepresentation(image!, 0.5)
                
//                print("图片：\(imageURL.lastPathComponent) 大小： ：\(data?.last)")
                
                let imageData = data
                do {
                    let filePath = photoPath + "\(Date().timeIntervalSince1970)" + imageURL.lastPathComponent
                    try imageData!.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomic)
                    let suffix = filePath.components(separatedBy: ".").last
                    
                    let dataImage = UIImage(data: imageData!)
                    
                    let mediaImage = CYJMediaImage()
                    mediaImage.oldName =  imageURL.lastPathComponent
                    mediaImage.url = "\(Date().timeIntervalSince1970)_" + imageURL.lastPathComponent
                    mediaImage.size = (imageData?.last)!
                    mediaImage.minSize = Int(min(dataImage?.size.width ?? 0, dataImage?.size.height ?? 0))
                    mediaImage.suffix = suffix!
                    mediaImage.localPath = filePath
                    mediaImage.localIdentifier = asset.localIdentifier
                    
                    
                    savedImages.append(mediaImage)
                }catch {
                    DLog("文件创建失败")
                }
                
                
            })
        }
        
        return savedImages
    }
    
    /// 保存相册的视频到本地路径
    func saveVideoToLocalPath(from asseUrl: URL) -> String {
        
        let fileManager = FileManager.default
        
        //如果文件存在就先删除
        if fileManager.fileExists(atPath: self.videoCachePath + asseUrl.lastPathComponent) {
            do {
                let _ = try fileManager.removeItem(atPath: self.videoCachePath + asseUrl.lastPathComponent)
            }catch
            {
                DLog("文件已存在--删除失败")
            }
        }
        //写入到本地
        do {
            let _ = try fileManager.copyItem(at: asseUrl, to: URL(fileURLWithPath: self.videoCachePath + asseUrl.lastPathComponent))
            return self.videoCachePath + asseUrl.lastPathComponent
            
        }catch
        {
            Third.toast.message("复制文件到本地路径 faild")
            return "上传失败了"
        }
    }
    
    //将视频保存到缓存路径中
    func uploadVideoToCOS(assetUrl: URL) {
        
        let videoPath = saveVideoToLocalPath(from: assetUrl)
        
        RequestManager.POST(urlString: APIManager.Media.videoServer, params: ["token": LocaleSetting.token]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            guard let sign = data as? String else {
                return
            }
//            self.sign = data as? String
            
            let publishParam = TXPublishParam()
            publishParam.coverImage = nil
            publishParam.signature = sign// self.sign
            publishParam.videoPath = videoPath
            
            let publish = TXUGCPublish(userID: "\(LocaleSetting.userInfo()?.username ?? "com.chinaxueqian")")
            publish?.delegate = self
            publish?.publishVideo(publishParam)
        }
        
        
        
    }
}

extension CYJMediaUploader: TXVideoPublishListener {
    
    func onPublishProgress(_ uploadBytes: Int, totalBytes: Int) {
        //
        DLog("\(uploadBytes)" + "\(totalBytes)")
    }
    
    func onPublishEvent(_ evt: [AnyHashable : Any]!) {
        //
    }
    
    func onPublishComplete(_ result: TXPublishResult!) {
        
        DLog(result.retCode)
        
        if result.retCode == 0 {
            if let delegate = self.delegate {
                delegate.videoUploadComplete(result.videoId)
            }
        }else {
            if let delegate = self.delegate {
                delegate.videoUploadComplete("error")
            }
        }
    }
}


