//
//  CYJThemeViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/30.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import SwiftTheme

class CYJThemeViewController: KYBaseCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "设置皮肤"
        // Do any additional setup after loading the view.
        
        collectionView.register(UINib(nibName: "CYJThemeDisplayCell", bundle: nil), forCellWithReuseIdentifier: "CYJThemeDisplayCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CYJThemeViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CYJThemes.maxCount.rawValue
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 75) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(22.5, 22.5, 10, 22.5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYJThemeDisplayCell", for: indexPath) as? CYJThemeDisplayCell
        
        let themeRawValue = UserDefaults.standard.integer(forKey: CYJUserDefaultKey.currentTheme)
        
        cell?.statusImageView.isHidden = themeRawValue != indexPath.row

        
        let theme = CYJThemes(rawValue: indexPath.row)
        
        let dictionary = ThemeManager.targetTheme(theme: theme!)
        
        cell?.background.backgroundColor = ThemeManager.color(for: dictionary, keyPath: "Nav.barTintColor")
//        cell?.titleLabel.textColor = ThemeManager.color(for: dictionary, keyPath: "Global.textColorDark")
//        cell?.subTitle.textColor = ThemeManager.color(for: dictionary, keyPath: "Global.textColorMid")
//        cell?.contentLabel.textColor = ThemeManager.color(for: dictionary, keyPath: "Global.textColorLight")

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        //更换主题
        CYJThemes.switchTo(CYJThemes(rawValue: indexPath.row)!)
        
        collectionView.reloadData()
    }

    
}
