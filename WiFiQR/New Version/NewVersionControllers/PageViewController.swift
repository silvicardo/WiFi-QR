//
//  PageViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    //iPhone
    
    var iPhonePageHeaders : [String] = ["Add manually","Grab a QR-Code","Manage Networks"]
    
    var iPhonePageDescriptions : [String] = ["Add to your collection manually, auto-detects connected wifi network","Requires your permissions. Shoot from camera with flash, pick from library or tap on previews","Manage with searchBar and quick-actions."]
    
    var iPhonePagewChRImages : [String] = ["Real Space Grayadd","Real Space Graycamera","Real Space GrayList"]
    
    var iPhonePageLandscapeImages : [String] = ["Real Space GraylandscapeAdd","Real Space GraylandscapeCamera","Real Space GraylandscapeList"]
    
    //iPad
    
    var iPadPageHeaders : [String] = ["Add manually", "Grab a QR-Code", "Multitasking", "Drag and Drop", "Manage your Networks"]
    
    var iPadPageDescriptions : [String] = ["Add to your collection manually, auto-detects connected wifi network"," Requires your authorization. Shoot from camera, pick from library, tap on previews.","Multitask in every orientation. Camera functionality fullScreen only","Drag and Drop side by side from another App or to dock","Manage with quick-actions, edit and search capability"]
    
    var iPadPagewChRImages : [String] = ["Real Space GraypadAdd","Real Space GraypadCamera","Real Space GraypadImport","Real Space GraypadDragDrop","Real Space GraypadLIst"]
    
    var iPadPageLandscapeImages : [String] = ["Real Space GraylandscapepadAdd","Real Space GraylandscapepadCamera","Real Space GraylandscapepadMulti","Real Space GraylandscapepadDragDrop","Real Space GraylandscapepadList"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        //instantiates on first load the first WalktroughVC
        if let startWalktroughVC = self.viewControllerAtIndex(index: 0) {
            setViewControllers([startWalktroughVC], direction: .forward, animated: true, completion: nil)
        
        }
    }
    

    func nextPageWithIndex(index: Int) {
        
        if let nextWalktroughVC = self.viewControllerAtIndex(index: index + 1) {
             setViewControllers([nextWalktroughVC], direction: .forward, animated: true, completion: nil)
        }
    }

    func viewControllerAtIndex(index: Int) -> WalktroughViewController? {
      
        let maxIndex = UIDevice.current.userInterfaceIdiom == .phone ? self.iPhonePageDescriptions.count: self.iPadPageDescriptions.count
        
        if index == NSNotFound || index < 0 || index >= maxIndex {
            return nil
        }
        
        if let walktroughVC = storyboard?.instantiateViewController(withIdentifier: "WalktroughVC") as? WalktroughViewController {
            
            switch UIDevice.current.userInterfaceIdiom   {
            case .phone :
                walktroughVC.wChRimageName = iPhonePagewChRImages[index]
                walktroughVC.landscapeImageName = iPhonePageLandscapeImages[index]
                walktroughVC.headerText = iPhonePageHeaders[index]
                walktroughVC.descriptionText = iPhonePageDescriptions[index]
                walktroughVC.index = index
                
            default : //Ipad Case
                walktroughVC.wChRimageName = iPadPagewChRImages[index]
                walktroughVC.landscapeImageName = iPadPageLandscapeImages[index]
                walktroughVC.headerText = iPadPageHeaders[index]
                walktroughVC.descriptionText = iPadPageDescriptions[index]
                walktroughVC.index = index
                
            }
           
            
            return walktroughVC
            
        }
        
        
        return nil
    }
}

extension PageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalktroughViewController).index
        
        index -= 1
        
        return self.viewControllerAtIndex(index: index)
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalktroughViewController).index
        
        index += 1
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    
}
