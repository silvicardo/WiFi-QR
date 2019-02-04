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
    
    @IBOutlet weak var wChRImageView : UIImageView!
    
    @IBOutlet weak var landscapeImageView: UIImageView!
    
    @IBOutlet weak var pageControl : UIPageControl!

    @IBOutlet weak var nextButton : UIButton!
    
    @IBOutlet weak var nextButtonLabel : UILabel!
    
    @IBOutlet weak var nextButtonView : DesignableView!
    
    @IBOutlet weak var startButton : UIButton!
    
    @IBOutlet weak var startButtonLabel: UILabel!
    
    @IBOutlet weak var startButtonView: DesignableView!
    
    var index = 0 //page Index
    
    var maxIndex : Int = 0 //max pageIndex
    
    var headerText = ""
    var wChRimageName = ""
    var landscapeImageName = ""
    var descriptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        populateUIElements()
    
        maxIndex = UIDevice.current.userInterfaceIdiom == .phone ? 3 : 4
        
        descriptionLabel.numberOfLines = UIDevice.current.userInterfaceIdiom == .phone ? 3 : 2
        
        manageStartButton()
        
        managePageControl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func startButtonTapped(sender: AnyObject) {
        
        setKeyForTutorialCompletion()
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject){
        
        let pageViewController = self.parent as! PageViewController
        pageViewController.nextPageWithIndex(index: index)
        
    }

}

//MARK: viewDidLoad inner methods
extension WalktroughViewController {
    
    func populateUIElements() {
        headerLabel.text = headerText
        descriptionLabel.text = descriptionText
        wChRImageView.image = UIImage(named: wChRimageName)
        landscapeImageView.image = UIImage(named: landscapeImageName)
        startButtonLabel.text = loc("TUTORIAL_DONE")
    }
    
    func manageStartButton(){
        startButton.isHidden = (index == maxIndex) ? false : true
        startButtonView.isHidden = (index == maxIndex) ? false : true
        startButtonLabel.isHidden = (index == maxIndex) ? false : true
    }
    
    func manageNextButton(){
        nextButton.isHidden = (index == maxIndex) ? true : false
        nextButtonLabel.isHidden = (index == maxIndex) ? true : false
        nextButtonView.isHidden = (index == maxIndex) ? true : false
    }
    
    func managePageControl(){
        pageControl.isHidden = (index == maxIndex) ? true : false
        
        //index for pageControl
        pageControl.numberOfPages = maxIndex + 1
        pageControl.currentPage = index
    }

}

//MARK: Start Button tapped inner method
extension WalktroughViewController {
    
    func setKeyForTutorialCompletion() {
        //changes the value on the end of tutorial
        //so if the user stops the app without completing it will
        //present again
        let userDefaults = UserDefaults.standard
        
        //userDefaults.bool(forKey: "DisplayedWalktrough")
        userDefaults.set(true, forKey: "DisplayedWalkthrough")
        self.dismiss(animated: true, completion: nil)
        
    }
}
