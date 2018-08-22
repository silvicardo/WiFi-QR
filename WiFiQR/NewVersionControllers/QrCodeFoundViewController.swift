//
//  QrCodeFoundViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 22/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class QrCodeFoundViewController: UIViewController {

    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }

}
