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
    
    var iPhonePageHeaders : [String] = [loc("ADD_MANUALLY"),loc("GRAB_A_CODE"),loc("IMPORT_FROM_APPS"),loc("MANAGE_NETWORKS")]
    
    var iPhonePageDescriptions : [String] = [loc("ADD_DESCRIPTION"),loc("PHONE_CAMERA_DESCRIPTION"),loc("PHONE_IMPORT_DESCRIPTION"),loc("PHONE_MANAGE_DESCRIPTION")]
    
    var iPhonePagewChRImages : [String] = ["Real Space Grayadd","Real Space Graycamera","Real Space Grayimport","Real Space GrayList"]
    
    var iPhonePageLandscapeImages : [String] = ["Real Space GraylandscapeAdd","Real Space GraylandscapeCamera","Real Space GraylandscapeImport","Real Space GraylandscapeList"]
    
    //iPad
    
    var iPadPageHeaders : [String] = [loc("ADD_MANUALLY"), loc("GRAB_A_CODE"), "Multitasking", "Drag and Drop", loc("MANAGE_NETWORKS")]
    
    var iPadPageDescriptions : [String] = [loc("ADD_DESCRIPTION"),loc("PAD_CAMERA_DESCRIPTION"),loc("PAD_MULTITASK_DESCRIPTION"),loc("PAD_DRAG_DROP"),loc("PAD_MANAGE_NETWORKS")]
    
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
