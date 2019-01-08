//
//  MainTabBarViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 01/10/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate{
    
    let tabBarCapture = loc("TAB_BAR_CAPTURE")
    
    let tabBarList = loc("TAB_BAR_LIST")
    
    let tabBarAdd = loc("TAB_BAR_ADD")
    
    var netAddDelegate : NetworkAddViewControllerDelegate?
    
    var indexPathForTable : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        
        //localized titles
        self.tabBar.items![0].title = tabBarCapture
        self.tabBar.items![1].title = tabBarList
        self.tabBar.items![2].title = tabBarAdd
        
        

        // Do any additional setup after loading the view.
    }

    // called whenever a tab button is tapped
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("tabbarDelegate")
    
        //if list Controller was opened once transitioning to another tab will cause
        //listController's Search to reset its status
        if viewController as? UINavigationController == nil {
            
            print("Not ListController's Navigation")
            
            if let listController = (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController) {
            
                print("listControllerTabBarAction, removing text from searchBar")
                
                
                listController.tabBarShouldReset = true
                
                }
            }
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select")
        
        return true
    }
}
