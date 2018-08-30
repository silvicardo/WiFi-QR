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
    
    @IBOutlet weak var ssidTextField: UITextField!
    
    @IBOutlet weak var isHiddenUISwitch: UISwitch!
    
    @IBOutlet weak var isProtectedUISwitch: UISwitch!
    
    @IBOutlet weak var wepOrWpaUISegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var passwordUITextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        panToClose.setGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
   
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
    }
    
}

