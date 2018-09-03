//
//  QrCodeNotRecognizedViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 03/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class QrCodeNotRecognizedViewController: UIViewController {
    
    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panToClose.setGestureRecognizer()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (CoreDataManagerWithSpotlight.shared.scanCont as? QRScannerViewController)?.sessioneDiCattura.startRunning()
    }

}
