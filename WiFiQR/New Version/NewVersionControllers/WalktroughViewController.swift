//
//  IPhoneWalktroughViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class WalktroughViewController: UIViewController {
    
    @IBOutlet weak var headerLabel : UILabel!
    
    @IBOutlet weak var descriptionLabel : UILabel!
    
    @IBOutlet weak var imageView : UIImageView!
    
    @IBOutlet weak var pageControl : UIPageControl!

    @IBOutlet weak var nextButton : UIButton!
    
    @IBOutlet weak var startButton : UIButton!
    
    
    var index = 0 //page Index
    
    var headerText = ""
    var imageName = ""
    var descriptionText = ""
    
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.text = headerText
        descriptionLabel.text = descriptionText
        imageView.image = UIImage(named: imageName)
        
        //customize next and Start button
        startButton.isHidden = (index == 3) ? false : true
        nextButton.isHidden = (index == 3) ? false : true
        startButton.layer.cornerRadius = 5.0
        startButton.layer.masksToBounds = true
        
        //index for pageControl
        pageControl.currentPage = index
        
    }
    
    @IBAction func startButtonTapped(sender: AnyObject) {
        
        //changes the value on the end of tutorial
        //so if the user stops the app without completing it will
        //present again
        let userDefaults = UserDefaults.standard
        
        userDefaults.bool(forKey: "DisplayedWalktrough")
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject){
        
        let pageViewController = self.parent as! PageViewController
        pageViewController.nextPageWithIndex(index: index)
        
    }
    
    

}
