//
//  NetworkEditViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 30/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class NetworkEditViewController: UIViewController {
    
    var wifiNetwork : WiFiNetwork?
    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        panToClose.setGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
   

}
