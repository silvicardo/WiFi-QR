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
    
    @IBOutlet weak var wChRBorderUIView: UIView!
    
    @IBOutlet weak var landscapeBorderUIView: UIView!
    
    @IBOutlet weak var passwordFieldUIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
        guard let validString = wifiQrValidString  else {return}
        
        fillUIWith(from: validString)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }

    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion:  {
        
             (CoreDataManagerWithSpotlight.shared.scanCont as? QRScannerViewController)?.sessioneDiCattura.startRunning()
        })
    }
    
    @IBAction func acceptButtonPressed(_ sender : UIButton) {
        
        guard let validString = wifiQrValidString else { return }
        
        let newNetworkParameters = QRManager.shared.decodificaStringaQRValidaARisultatixUI(stringaInputQR: validString)
        
        
        let acquiredNetwork = createNewNetworkFromParameters(newNetworkParameters)
    
        
        CoreDataManagerWithSpotlight.shared.storage.append(acquiredNetwork)
        
        CoreDataManagerWithSpotlight.shared.indexInSpotlight(wifiNetwork: acquiredNetwork)
        
        CoreDataStorage.saveContext(self.context)
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
        
        dismiss(animated: true) {
            let tabBarController = self.appDelegate.window?.rootViewController as! UITabBarController
            
            tabBarController.selectedIndex = 1
        }
    
    }
    
    
}

extension QrCodeFoundViewController {
    
    func createNewNetworkFromParameters(_ params: (String, Bool, Bool, [String])) -> WiFiNetwork {
        
        let visible  = CoreDataManagerWithSpotlight.Visibility(rawValue: Visibility.hidden)!
        
        let hidden = CoreDataManagerWithSpotlight.Visibility(rawValue: Visibility.visible)!
        
        let visibility : (_ visibleStatus: String) -> CoreDataManagerWithSpotlight.Visibility = { visibleStatus in
            
            return visibleStatus == hidden.rawValue ? hidden : visible
        }
        
        let chosenAuth : (_ auth: String) -> CoreDataManagerWithSpotlight.Encryptions = { auth in
            
            var chosenAuth = CoreDataManagerWithSpotlight.Encryptions(rawValue: Encryption.none)!
            
            
            switch auth
            {
            case Encryption.wep:
                chosenAuth =  CoreDataManagerWithSpotlight.Encryptions(rawValue: Encryption.wep)!;
                print("Wep Network");
            case Encryption.wpa_Wpa2:
                chosenAuth =  CoreDataManagerWithSpotlight.Encryptions(rawValue: Encryption.wpa_Wpa2)!;
                print("Wpa Network");
            default:
                break
            }
            
            
            return chosenAuth
            
        }
        
        return CoreDataManagerWithSpotlight.shared.createNewNetwork(
            in: self.context,
            ssid: params.3[0],
            visibility: visibility(params.3[3]),
            isHidden: params.2,
            requiresAuthentication: params.1,
            chosenEncryption: chosenAuth(params.3[1]),
            password: params.3[2])
        
        
    }
    
    func fillUIWith(from validString: String){
        
        let params = QRManager.shared.decodificaStringaQRValidaARisultatixUI(stringaInputQR: validString)
        
        let ssid = params.3[0]
        let visibility = params.3[3]
        let chosenEncryption =  params.3[1]
        let password = params.3[2]
        
        ssidForSpotlightCheck = ssid
        
        ssidUIITextField.text = ssid
        
        visibilityUILabel.text = visibility
        
        chosenAuthenticationUILabel.text = chosenEncryption
        
        if chosenEncryption == "NONE" {
            chosenAuthenticationUILabel.text = "NO PASSWORD"
        }
        
        passwordUITextField.text = password
        
        if password.isEmpty || password == "" {
            wChRBorderUIView.isHidden = true
            landscapeBorderUIView.isHidden = true
            passwordFieldUIView.isHidden = true
        }
    }
}
