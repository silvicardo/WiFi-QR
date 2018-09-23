//
//  PageViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    var pageHeaders : [String] = []
    
    var pageImages : [String] = []
    
    var pageDescriptions : [String] = []

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
        
        if index == NSNotFound || index < 0 || index >= self.pageDescriptions.count {
            return nil
        }
        
        if let walktroughVC = storyboard?.instantiateViewController(withIdentifier: "WalktroughVC") as? WalktroughViewController {
            
            walktroughVC.imageName = pageImages[index]
            walktroughVC.headerText = pageHeaders[index]
            walktroughVC.descriptionText = pageDescriptions[index]
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
