//
//  NetworkDetailViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 20/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class NetworkDetailViewController: UIViewController {

    var wifiNetwork : WiFiNetwork?
    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var ssidWcHrLabel: DesignableLabel!
    
    @IBOutlet weak var ssidLabel: DesignableLabel!
    
    @IBOutlet weak var passwordLabel: DesignableLabel!
    
    @IBOutlet weak var chosenEncryptionLabel: DesignableLabel!
    
    @IBOutlet weak var visibilityLabel: DesignableLabel!
    
    @IBOutlet weak var qrCodeImageView: DesignableImageView!
    
    @IBOutlet weak var passwordDesignabileView: DesignableView!
    
    @IBOutlet weak var networkAndQRrStackView: UIStackView!
    
    @IBOutlet weak var networkStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
    
        guard let wiFiNetwork = wifiNetwork else {return}
        
        guard let qrCode = QRManager.shared.generateQRCode(from: wiFiNetwork.wifiQRString!) else {return}
        
        loadUIwith(wiFiNetwork, qr: qrCode)
            
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
    
    }
}

extension NetworkDetailViewController {
   
    //NASCONDE LA STATUS BAR
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


extension NetworkDetailViewController {
    
    func loadUIwith(_ wifiNetwork : WiFiNetwork,qr qrCode : UIImage ) {
        
        ssidLabel.text = wifiNetwork.ssid
        ssidWcHrLabel.text = wifiNetwork.ssid
        
        
        if wifiNetwork.password != "" {
            passwordLabel.text = wifiNetwork.password
        } else {
            
            passwordLabel.text = "No Password"
//            passwordDesignabileView.isHidden = true
//
//            networkAndQRrStackView.axis = .vertical
//
//            networkStackView.alignment = .center

        }
        
        chosenEncryptionLabel.text = wifiNetwork.chosenEncryption
        visibilityLabel.text = wifiNetwork.visibility
        
        // mettiamo a video l'immagine
        qrCodeImageView.image = qrCode
        //regolazione rotazione immagine
        if qrCode.size.width > qrCode.size.height {
            qrCodeImageView.image = UIImage(cgImage: qrCode.cgImage!,
                                           scale: 1.0,
                                           orientation: .right)
        }
    
    }
}
