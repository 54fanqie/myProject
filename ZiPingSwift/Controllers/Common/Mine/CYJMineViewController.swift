//
//  CYJMineViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import SideMenu

import Photos
import HandyJSON

class MineControllerModel: CYJBaseModel {
    var nName: String? //''，//幼儿园名称
    var grade: Int = 0 //''，//年级 1 '大班', 2 '中班', 3 '小班', 4 '托班
    var cName: String? //''，//班级名称
    var count: Int = 0 //''，//优秀纪录个数
    
    var gradeDescription: String {
        switch grade {
        case 1: return "大班"
        case 2: return "中班"
        case 3: return "小班"
        case 4: return "托班"
        default:
            return "未入学"
        }
    }
}

class CYJMineViewController: KYBaseTableViewController {
    
    var role: CYJRole {
        return (LocaleSetting.userInfo()?.role)!
    }
    
    var teacherInfo: MineControllerModel?
    
    var examples: [KYTableExample] = []
    
    var headerView: CYJMineHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        examples.append(KYTableExample(key: "specialvaluation", title: "集中测评", selector: #selector(specialvaluation), image: #imageLiteral(resourceName: "leftbaar-ic-ceping") ))
        
        if role == .teacher  || role == .teacherL{
            examples.append(KYTableExample(key: "checkOtherClasses", title: "浏览其他班级记录", selector: #selector(otherClasses), image: #imageLiteral(resourceName: "leftbaar-ic-qitabanji")))
        }
        if role == .teacher  {
            examples.append(KYTableExample(key: "children", title: "管理本班幼儿", selector: #selector(showBabies), image: #imageLiteral(resourceName: "icon_deepblue_manage")))
        }
        
     
        
        examples.append(KYTableExample(key: "checkout", title: "切换账号", selector: #selector(showBoundUsers), image: #imageLiteral(resourceName: "icon_deepblue_user")))
        examples.append(KYTableExample(key: "info", title: "我的资料", selector: #selector(showMineInfo), image: #imageLiteral(resourceName: "icon_deepblue_paper")))
        examples.append(KYTableExample(key: "setting", title: "设置", selector: #selector(showSetting), image: #imageLiteral(resourceName: "icon_deepblue_setting")))
        examples.append(KYTableExample(key: "feedback", title: "意见反馈", selector: #selector(showFeedback), image: #imageLiteral(resourceName: "icon_deepblue_view")))
        
        
        if role == .child {
            examples.append(KYTableExample(key: "tellus", title: "告诉我们", selector: #selector(showTellUs), image: #imageLiteral(resourceName: "icon_deepblue_mail")))
        }
        
        
        
        headerView = CYJMineHeaderView(frame: CGRect(x: 0, y: 0, width: SideMenuManager.menuWidth, height: 220))
        headerView.user = LocaleSetting.userInfo()
        headerView.photoClickedHandler = { (imageView) in
            
            let alert = UIAlertController(title: "请选择相册或相机", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.popoverPresentationController?.sourceView = imageView
            alert.popoverPresentationController?.sourceRect = imageView.bounds
            
            alert.addAction(UIAlertAction(title: "相册", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in
                //打开相册
                AuthorizationManager.share.fetchAuthorityLibrary({ (authStatus) in
                    guard authStatus else {
                        return
                    }
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                        let picker = UIImagePickerController()
                        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                        picker.allowsEditing = true
                        picker.delegate = self
                        
                        self.present(picker, animated: true, completion: nil)
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "相机", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in
                //打开相机
                AuthorizationManager.share.fetchAuthorityCamera({ (authStatus) in
                    guard authStatus else {
                        return
                    }
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                        let picker = UIImagePickerController()
                        picker.sourceType = UIImagePickerControllerSourceType.camera
                        picker.allowsEditing = true
                        picker.delegate = self
                        
                        self.present(picker, animated: true, completion: nil)
                    }
                })
                
            }))
            alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: {(action) in
                //
            }))
            
            DispatchQueue.main.async {
                //                UIApplication.shared.keyWindow?.topMostController()?.present(alert, animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0 )
        
        //请求班级，年纪信息
        fetchDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goInfo() {
        let setting = CYJSettingViewController()
        
        self.navigationController?.pushViewController(setting, animated: true)
        
    }
    
    override func fetchDataSource() {
        RequestManager.POST(urlString: APIManager.Mine.teacherInfo, params: ["token": LocaleSetting.token]) { [unowned self] (data, error) in
            //如果存在error
            guard error == nil else {
                Third.toast.message((error?.localizedDescription)!)
                return
            }
            if let datas = data as? NSDictionary {
                //遍历，并赋值
                let target = JSONDeserializer<MineControllerModel>.deserializeFrom(dict: datas )
                self.teacherInfo = target
                
                self.headerView.gardenLabel.text = self.teacherInfo?.nName
                
                if self.teacherInfo?.gradeDescription == "未入学" {
                    self.headerView.classLabel.text = ""
                }else {
                    self.headerView.classLabel.text = (self.teacherInfo?.gradeDescription)! + "-" + (self.teacherInfo?.cName)!
                    
                }
                
                let imageA = NSTextAttachment()
                imageA.image = #imageLiteral(resourceName: "icon_red_jinghua")
                imageA.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: CGSize(width: 9,height : 12))
                
                let mutable = NSMutableAttributedString(string: "  优秀记录\(self.teacherInfo?.count ?? 0)个", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
                
                mutable.insert(NSAttributedString(attachment: imageA), at: 0)
                self.headerView.excellent.attributedText = mutable
            }
        }
    }
}


extension CYJMineViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MineCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "MineCell")
            cell?.theme_backgroundColor = Theme.Color.ground
            cell?.textLabel?.theme_textColor = Theme.Color.textColorDark
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        let example = examples[indexPath.row]
        cell?.textLabel?.text = example.title
        cell?.imageView?.image = example.image
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let example = examples[indexPath.row]
        
        perform(example.selector)
    }
}
extension CYJMineViewController {
    func specialvaluation(){
        //测评        
        if role == .master {
            let valuatiov = CheckValuationController()
            navigationController?.pushViewController(valuatiov, animated: true)
        }
        
        if role == .teacher ||  role == .teacherL{
            //请求数据查看是否完成
            RequestManager.POST(urlString: APIManager.Valuation.check, params: nil, complete: { [weak self] (data, error) in
                
                guard error == nil else {
                    Third.toast.message((error?.localizedDescription)!)
                    return
                }
                
                if let datas = data as? NSDictionary {
                    //遍历，并赋值
                    let target = JSONDeserializer<ValuationStatuModel>.deserializeFrom(dict: datas )
                    let  valuatiov = ValuationController()
                    valuatiov.target = target
                    self?.navigationController?.pushViewController(valuatiov, animated: true)
                }
            })
            
            
        }
        
        if role == .child {
            let valuatiov = QuestionnaireViewController()
            valuatiov.statue = 6
            //如果可以测评并且还未测评进入
            //            let valuatiov =  InstructionViewController()
            //            valuatiov.title = "问卷调查"
            navigationController?.pushViewController(valuatiov, animated: true)
        }   
    }
    //浏览其他班级
    func otherClasses(){
        //2=全部权限 ，1=同班级权限，0=无权限
        if  LocaleSetting.userInfo()?.lookAuth == 0{
            let noPermiss = NoPermissViewController()
            self.navigationController?.pushViewController(noPermiss, animated: true)
            
        }else{
            let  otherClas = OtherClassRecordController()
            otherClas.title = "浏览其他班级记录"
            self.navigationController?.pushViewController(otherClas, animated: true)
        }
        
        
    }
    
    func showMineInfo()  {
        let info = CYJUserInfoViewController()
        navigationController?.pushViewController(info, animated: true)
    }
    func showSetting() {
        let setting = CYJSettingViewController()
        self.navigationController?.pushViewController(setting, animated: true)
    }
    func showFeedback() {
        let setting = CYJFeedBackController(nibName: "CYJFeedBackController", bundle: Bundle.main)
        self.navigationController?.pushViewController(setting, animated: true)
    }
    
    func showBoundUsers() {
        let boundUser = CYJCheckoutViewController()
        self.navigationController?.pushViewController(boundUser, animated: true)
    }
    
    func showBabies() {
        //        let babies = CYJBabiesEditorController()
        let babies = CYJBabiesListController()
        babies.isWaited = false
        babies.title = "幼儿管理"
        
        self.navigationController?.pushViewController(babies, animated: true)
        
    }
    func showTellUs() {
        let tellUs = CYJTellUsController()
        self.navigationController?.pushViewController(tellUs, animated: true)
        
    }
}

extension CYJMineViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //        if picker.sourceType == .photoLibrary {
        
        let orginalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //            let pickedUrl = info[UIImagePickerControllerReferenceURL] as! URL
        let photoPath = CYJMediaUploader.default.photoSavePath() + "\(Date().timeIntervalSince1970).jpg"
        
        let imageData = UIImageJPEGRepresentation(orginalImage, 0.1)
        do {
            try imageData!.write(to: URL(fileURLWithPath: photoPath), options: Data.WritingOptions.atomic)
            
        }catch {
            DLog("文件夹创建失败")
        }
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        
        //上传图片
        if (fileManager.fileExists(atPath: photoPath)){
            //取得NSURL
            let imageURL = URL(fileURLWithPath: photoPath)
            
            let pickerName = "\(Date().timeIntervalSince1970)" + imageURL.lastPathComponent
            
            //使用Alamofire上传
            Third.toast.show {
            }
            
            CYJMediaUploader.default.uploadImage(path: photoPath, fileName: pickerName, dir: "avatar", complete: { (uploadedPath) in
                
                DLog(uploadedPath)
                RequestManager.POST(urlString: APIManager.Mine.avater, params: ["token": LocaleSetting.token, "photo": "\(uploadedPath.components(separatedBy: "/").last ?? "default")"]) { [unowned self] (data, error) in
                    //如果存在error
                    guard error == nil else {
                        Third.toast.message((error?.localizedDescription)!)
                        return
                    }
                    if let user = LocaleSetting.userInfo() {
                        user.avatar = uploadedPath
                        
                        LocaleSetting.saveLocalUser(userInfo: user)
                    }
                    
                    Third.toast.message("上传成功")
                    self.headerView.photoImageView.image = orginalImage
                }
            })
        }
        
        picker.dismiss(animated: true) {
            //
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
        picker.dismiss(animated: true, completion: nil)
    }
}


