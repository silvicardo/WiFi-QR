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
    
    var wifiQrValidString : String?
    
    var ssidForSpotlightCheck : String = ""
    
    //let var di passaggio

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var qrScannerController = CoreDataManagerWithSpotlight.shared.scanCont as! QRScannerViewController
    
    let context = CoreDataStorage.mainQueueContext()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var ssidUIITextField : UITextField!
    
    @IBOutlet weak var visibilityUILabel : UILabel!
    
    @IBOutlet weak var chosenAuthenticationUILabel : UILabel!
    
    @IBOutlet weak var passwordUITextField : UITextField!
    
    @IBOutlet weak var wChRBorderUIView: UIView!
    
    @IBOutlet weak var landscapeBorderUIView: UIView!
    
    @IBOutlet weak var passwordFieldUIView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
        //localize Buttons
        dismissButton.setTitle(loc("DISMISS_BUTTON"), for: .normal)
        acceptButton.setTitle(loc("ACCEPT_BUTTON"), for: .normal)
        
        //Fill UI with found network datas
        guard let validString = wifiQrValidString  else {return}
        
        fillUIWith(from: validString)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        
        if tabBarController.selectedViewController == qrScannerController {
            print("SESSION DA DISMISSAL RIPARTITA")
            qrScannerController.resetUIforNewQrSearch()
            qrScannerController.collectionView.invertHiddenAlphaAndUserInteractionStatus()
            qrScannerController.findInputDeviceAndDoVideoCaptureSession()
            
        }
    }


    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender : UIButton) {
        
        guard let string = wifiQrValidString,
            let network = WiFiModel.init(stringaInput: string) else { return }
        
        CoreDataManagerWithSpotlight.shared.addNetwork(from: network,
                                                       
           noDuplicates: { newNetwork in
                let index = IndexPath(item: CoreDataManagerWithSpotlight.shared.storage.index(of:newNetwork)!, section: 0)
            
                self.dismiss(animated: true) {
                    guard let tabBarController = self.appDelegate.window?.rootViewController as? MainTabBarViewController else { return }
                    
                    CoreDataManagerWithSpotlight.shared.indexToScroll = index
                    
                    tabBarController.selectedIndex = 1
                    
                }
            
            })
        
    }
    
    func fillUIWith(from validString: String){
        
        guard let network = WiFiModel.init(stringaInput: validString) else { return }
        
        let ssid = network.ssid
        let visibility = network.statoSSIDScelto
        let chosenEncryption =  network.tipoAutenticazioneScelto
        let password = network.password
        
        ssidForSpotlightCheck = ssid
        
        ssidUIITextField.text = ssid
        
        visibilityUILabel.text = { ()->(String) in
            switch visibility {
            case "HIDDEN": return loc("HIDDEN")
            case "VISIBLE": return loc("VISIBLE")
            default: return ""
            }
        }()
        
        chosenAuthenticationUILabel.text = { ()->(String) in
            switch chosenEncryption {
            case "No Password Required" : return loc("FREE")
            default: return chosenEncryption
            }
        }()
        
        passwordUITextField.text = password
        
        if password.isEmpty || password == "" {
            wChRBorderUIView.isHidden = true
            landscapeBorderUIView.isHidden = true
            passwordFieldUIView.isHidden = true
        }
    }
    
}

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
}
