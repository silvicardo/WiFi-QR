//
//  PageViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

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
        
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone ? true : false
        
        let deviceData : PageViewControllerContent = isPhone ? iPhoneData() : iPadData()
      
        let maxIndex = deviceData.headers.count
        
        if index == NSNotFound || index < 0 || index >= maxIndex {
            return nil
        }
        
        if let walktroughVC = storyboard?.instantiateViewController(withIdentifier: "WalktroughVC") as? WalktroughViewController {
            
            walktroughVC.headerText = deviceData.headers[index]
            walktroughVC.wChRimageName = deviceData.wChRImages[index]
            walktroughVC.landscapeImageName = deviceData.landscapeImages[index]
            walktroughVC.descriptionText = deviceData.descriptions[index]
            walktroughVC.index = index
            
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

//Classe e Funzioni generazione dati

extension PageViewController {
    
    
    class PageViewControllerContent {
        var headers: [String]
        var descriptions: [String]
        var wChRImages: [String]
        var landscapeImages: [String]
        
        init(headers: [String],descriptions: [String],wChRImages: [String], landscapeImages: [String] ) {
            self.headers = headers
            self.descriptions = descriptions
            self.wChRImages = wChRImages
            self.landscapeImages = landscapeImages
        }
    }

    
    func iPhoneData() -> PageViewControllerContent {
        
        let iPhonePageHeaders : [String] = [loc("ADD_MANUALLY"),loc("GRAB_A_CODE"),loc("IMPORT_FROM_APPS"),loc("MANAGE_NETWORKS")]
        
        let iPhonePageDescriptions : [String] = [loc("ADD_DESCRIPTION"),loc("PHONE_CAMERA_DESCRIPTION"),loc("PHONE_IMPORT_DESCRIPTION"),loc("PHONE_MANAGE_DESCRIPTION")]
        
        let iPhonePagewChRImages : [String] = ["Iphone8wChRAdd","Iphone8wChRCamera","Iphone8wChRShare","Iphone8wChRNetworkList"]
        
        let iPhonePageLandscapeImages : [String] = ["IphoneLandscapeAdd","IphoneLandscapeCamera","IphoneLandscapeShare","IphoneLandscapeNetworkList"]
        
        
        return PageViewControllerContent(headers: iPhonePageHeaders,
                                        descriptions: iPhonePageDescriptions,
                                        wChRImages: iPhonePagewChRImages,
                                        landscapeImages: iPhonePageLandscapeImages)
    }
    
    func iPadData() -> PageViewControllerContent {
        
        let iPadPageHeaders : [String] = [loc("ADD_MANUALLY"), loc("GRAB_A_CODE"), "Multitasking", "Drag and Drop", loc("MANAGE_NETWORKS")]
        
        let iPadPageDescriptions : [String] = [loc("ADD_DESCRIPTION"),loc("PAD_CAMERA_DESCRIPTION"),loc("PAD_MULTITASK_DESCRIPTION"),loc("PAD_DRAG_DROP"),loc("PAD_MANAGE_NETWORKS")]
        
        let iPadPagewChRImages : [String] = ["iPadPortraitAdd","iPadPortraitCamera","iPadPortraitMultitasking","iPadPortraitDragDrop","iPadPortraitNetworkList"]
        
        let iPadPageLandscapeImages : [String] = ["iPadLandscapeAdd","iPadLandscapeCamera","iPadLandscapeMultitasking","iPadLandscapeDragDrop","iPadLandscapeNetworkList"]
        
        return PageViewControllerContent(headers: iPadPageHeaders,
                                         descriptions: iPadPageDescriptions,
                                         wChRImages: iPadPagewChRImages,
                                         landscapeImages: iPadPageLandscapeImages)
    }
}
