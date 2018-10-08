//
//  RequestManager.swift
//  SwiftDemo
//
//  Created by 杨凯 on 2017/4/17.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation

import Alamofire
import HandyJSON


struct CustomResponds: HandyJSON{
    
    var status: Int?
    
    var message: String?
    
    var data: Any?
}
//创建一个闭包
typealias requestCompleteBlock = (Any?, NSError?)->Void

//类型
typealias FileData = (String, UIImage)


class RequestManager: NSObject {
    
    /// 单例
    static let `default` = RequestManager()
    /// alamofire
    var manager: SessionManager?
    
    
    /// 初始化
    override init() {
        
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = 10
//        urlSessionConfiguration.httpShouldSetCookies = true
        urlSessionConfiguration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
//        urlSessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
//
        manager = Alamofire.SessionManager(configuration: urlSessionConfiguration, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
        }
    
    /// POST
    ///
    /// - Parameters:
    ///   - urlString: <#urlString description#>
    ///   - params: <#params description#>
    ///   - complete: <#complete description#>
    class func POST(urlString: String, params: [String: Any]?, complete: @escaping requestCompleteBlock) {
        RequestManager.default.POST(urlString: urlString, params: params,callBackAll : false, complete: complete)
    }
    class func POST(urlString: String, params: [String: Any]?, callBackAll : Bool, complete: @escaping requestCompleteBlock) {
        RequestManager.default.POST(urlString: urlString, params: params,callBackAll : callBackAll, complete: complete)
    }
    
    /// UPLOAD
    ///
    /// - Parameters:
    ///   - urlString: <#urlString description#>
    ///   - files: <#files description#>
    ///   - params: <#params description#>
    ///   - complete: <#complete description#>
    class func UPLOAD(urlString: String, files: [FileData], params: [String: Any]?, complete: @escaping requestCompleteBlock) {
         RequestManager.default.UPLOAD(urlString: urlString, files: files, params: params, complete: complete)
    }
}


extension RequestManager
{
    fileprivate func POST(urlString: String, params: [String: Any]?, callBackAll: Bool , complete: @escaping requestCompleteBlock) {
        
        #if DEBUG
            //拼接路径--看起来清楚点
            var totalUrl = urlString + "?"
            
            params?.enumerated().forEach({ (offset: Int, element: (key: String, value: Any)) in
                
                totalUrl = totalUrl + "\(element.key)=\(element.value)"
                
                if offset < (params?.count)! - 1{
                    totalUrl += "&"
                }
            })
            
            DLog("请求地址：\(totalUrl)")
            
        #endif
        
//        var cookieJar = HTTPCookieStorage.shared.cookies
        
        
        _ = manager?.request(urlString, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (dataResponds) in
            
            DLog("返回值\(dataResponds)")

            switch dataResponds.result {
            case .success(let value):
                //根据返回值判断custom 错误
                let custom = JSONDeserializer<CustomResponds>.deserializeFrom(dict: value as? NSDictionary)
                print(custom?.message as Any)
                if custom?.status == 200 {
                    if callBackAll == true {
                        complete(value, nil)
                    }else{
                      complete(custom?.data, nil)
                    }
                    
                }
//                else if custom?.status == 201 {
//                    
//                }
                else if custom?.status == -1
                {
                    complete(value, nil)
                }else{
                    let error = NSError(domain: CYJErrorDomainName, code: (custom?.status)!, userInfo: [NSLocalizedDescriptionKey: custom?.message ?? "未知错误"])
                    
                    if error.code == 205 {
                        //TODO: 需验证--跳转到验证页面--如果最上面的页面已经是验证页面的话，什么也不做
                        let topMostController = UIApplication.shared.keyWindow?.topMostWindowController()
                        guard !(topMostController is CYJVerifyController) else {
                            return
                        }
                        let verify = CYJVerifyController()
                        verify.user = LocaleSetting.userInfo()!
                        topMostController?.present(verify, animated: true, completion: nil)
                    }else{
                        complete(custom?.data,error)
                    }
                }
            case .failure(let error):
                let error = error as NSError
                //TODO: 将所有服务器错误中文化为-- 连接服务器异常，请确认网络连接状态
                let cyjError = NSError(domain: "com.chinayoujiao.server", code: error.code, userInfo: [NSLocalizedDescriptionKey: "连接服务器异常，请确认网络连接状态"])
//                complete(nil,nsError)
             complete(nil,cyjError)

            }
        }
    }
    
    fileprivate func UPLOAD(urlString: String, files: [FileData], params: [String: Any]?, complete: @escaping requestCompleteBlock) {
        
        manager?.upload(multipartFormData: { (multipartFormData) in
            //
            for file in files
            {
                let fileName = file.0 + "\(Int(NSDate.timeIntervalSinceReferenceDate)).png";
                print("\(fileName)")
                multipartFormData.append(UIImageJPEGRepresentation(file.1, 0.3)!, withName: file.0, fileName: fileName, mimeType: "image/png")
            }
            if let params = params{
                for (name, content) in params
                {
                    multipartFormData.append(((content as? String)?.data(using: .utf8)!)!, withName: name)
                }
            }
            
        }, to: urlString, method: .post, headers: nil, encodingCompletion: { (encodingResult) in
            //
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //
                })
                
                upload.responseJSON { response in
                    
                    switch response.result {
                    case .success(_):
                        //根据返回值判断custom 错误
                        let custom = JSONDeserializer<CustomResponds>.deserializeFrom(dict: response.result.value as? NSDictionary)
                        
                        if custom?.status == 200 {
                            complete(custom?.data, nil)
                        }else
                        {
                            let error = NSError(domain: "com.chinayoujiao.yanxun", code: (custom?.status)!, userInfo: [NSLocalizedDescriptionKey: custom?.message ?? "未知错误"])
                            complete(custom?.data,error)
                        }
                        
                    case .failure(let error):
                        DLog(error)
                        complete(nil,error as NSError)
                    }
                }
            case .failure(let encodingError):
                complete(nil,encodingError as NSError)
            }
        })
    }
    
    func downloadFiles(urlString: String, complete: @escaping requestCompleteBlock) {
        
        manager?.download(URL(string : urlString)!, method: .get, to: { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            //
            
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            
            return (URL(fileURLWithPath: "\(paths.first!)/discuss/\(response.suggestedFilename ?? "defaultfile")"), DownloadRequest.DownloadOptions.createIntermediateDirectories)
        }).responseData(completionHandler: { (data) in
            //
            switch data.result {
            case .success(_):
                //根据返回值判断custom 错误
                print("success")
                complete(data.destinationURL,nil)

            case .failure(let error):
                DLog(error)
                complete(nil,error as NSError)
            }
        })
    }
}

