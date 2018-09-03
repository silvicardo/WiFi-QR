//
//  QrCodeFoundViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 22/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class QrCodeFoundViewController: UIViewController {
    
    // MARK: - VARIABLES
    
    var wifiNetwork : WiFiNetwork?
    
    var ssidForSpotlightCheck : String = ""
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = CoreDataStorage.mainQueueContext()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var ssidUIITextField : UITextField!
    
    @IBOutlet weak var visibilityUILabel : UILabel!
    
    @IBOutlet weak var chosenAuthenticationUILabel : UILabel!
    
    @IBOutlet weak var passwordUITextField : UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
        guard let wifi = wifiNetwork else { return }
            
            ssidForSpotlightCheck = wifi.ssid!
        
            ssidUIITextField.text = wifi.ssid!
        
            visibilityUILabel.text = wifi.visibility!
        
            chosenAuthenticationUILabel.text = wifi.chosenEncryption
        
            passwordUITextField.text = wifi.password!
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }

    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender : UIButton) {
        
        guard let newNetwork = wifiNetwork else {return}
        
        CoreDataManagerWithSpotlight.shared.storage.append(newNetwork)
        
        CoreDataManagerWithSpotlight.shared.indexInSpotlight(wifiNetwork: newNetwork)
        
        CoreDataStorage.saveContext(self.context)
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
        
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        
        tabBarController.selectedIndex = 1
    
    }
}
