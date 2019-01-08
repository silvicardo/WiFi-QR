//
//  ConnectionResultViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 22/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class ConnectionResultViewController: UIViewController {

    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var resultLabel: UILabel!

    @IBOutlet weak var dismissButton: UIButton!
    
    var resultText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissButton.titleLabel?.text = loc("DISMISS_BUTTON")
        resultLabel.text = resultText
        
        panToClose.setGestureRecognizer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
        
    }

}
