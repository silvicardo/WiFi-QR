//
//  MoreViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 01/10/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    @IBOutlet weak var supportLabel : UILabel!
    
    @IBOutlet weak var supportButton : UIButton!
    
    @IBOutlet weak var privacyButton : UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        supportLabel.text = loc("SUPPORT")
        supportButton.setTitle(loc("ASK_FOR_HELP"), for: .normal)
        privacyButton.setTitle(loc("READ_PRIVACY"), for: .normal)
        
    }
    
    @IBAction func readPolicyButtonTapped(_ sender : UIButton) {
        //open Policy Link in Safari
    }
    
    @IBAction func askSupportButtonTapped(_ sender: UIButton) {
        //Preconfigured Mail
        
    }

}
