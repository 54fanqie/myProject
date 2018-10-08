//
//  CYJSideViewController.swift
//  ZiPingSwift
//
//  Created by kyang on 2017/8/31.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit
import SideMenu

class CYJSideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSideMenu()
        setDefaults()
    }
    
    fileprivate func setupSideMenu() {
        // Define the menus
        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightMenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    fileprivate func setDefaults() {
//        let modes:[SideMenuManager.MenuPresentMode] = [.menuSlideIn, .viewSlideOut, .menuDissolveIn]
//        presentModeSegmentedControl.selectedSegmentIndex = modes.index(of: SideMenuManager.menuPresentMode)!
//        
//        let styles:[UIBlurEffectStyle] = [.dark, .light, .extraLight]
//        if let menuBlurEffectStyle = SideMenuManager.menuBlurEffectStyle {
//            blurSegmentControl.selectedSegmentIndex = styles.index(of: menuBlurEffectStyle) ?? 0
//        } else {
//            blurSegmentControl.selectedSegmentIndex = 0
//        }
//        
//        darknessSlider.value = Float(SideMenuManager.menuAnimationFadeStrength)
//        shadowOpacitySlider.value = Float(SideMenuManager.menuShadowOpacity)
//        shrinkFactorSlider.value = Float(SideMenuManager.menuAnimationTransformScaleFactor)
//        screenWidthSlider.value = Float(SideMenuManager.menuWidth / view.frame.width)
//        blackOutStatusBar.isOn = SideMenuManager.menuFadeStatusBar
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
