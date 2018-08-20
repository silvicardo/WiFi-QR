//
//  NetworkDetailViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 20/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class NetworkDetailViewController: UIViewController {

    @IBOutlet var panToClose: InteractionPanToClose!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
}
