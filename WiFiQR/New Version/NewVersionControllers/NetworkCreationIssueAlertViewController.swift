//
//  DuplicateNetworkViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 03/10/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class NetworkCreationIssueAlertViewController: UIViewController {


    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var issueDescriptionLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    var issueDescription : String?
    
    //MARK: - Pointers
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let qrScannerController = CoreDataManagerWithSpotlight.shared.scanCont as! QRScannerViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
        guard let issue = issueDescription else {return}
        
        issueDescriptionLabel.text = issue
        
        backButton.setTitle(loc("DISMISS_BUTTON"), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //if we're coming from QRScanner we need to handle
        //AV Session
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        
        if tabBarController.selectedViewController == qrScannerController {
            print("SESSION DA DISMISSAL RIPARTITA")
            qrScannerController.resetUIforNewQrSearch()
            qrScannerController.collectionView.invertHiddenAlphaAndUserInteractionStatus()
            qrScannerController.findInputDeviceAndDoVideoCaptureSession()
        }
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
}
