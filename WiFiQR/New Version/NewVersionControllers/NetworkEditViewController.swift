//
//  NetworkEditViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 30/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import CoreData


class NetworkEditViewController: UIViewController {
    
    var wifiNetwork : WiFiNetwork?
    
    var ssidForSpotlightCheck : String = ""
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = CoreDataStorage.mainQueueContext()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let ssidFieldPlaceholderText = "Input Network SSID"
    
    let passwordPlaceholderText = "Input Password"
    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var ssidTextField: UITextField!
    
    @IBOutlet weak var isHiddenUISwitch: UISwitch!
    
    @IBOutlet weak var isProtectedUISwitch: UISwitch!
    
    @IBOutlet weak var wepOrWpaUISegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var passwordUITextField: UITextField!
    
    @IBOutlet weak var EncryptionAndPasswordView: UIView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoreDataManagerWithSpotlight.shared.editCont = self
        
        // Do any additional setup after loading the view.
        
        panToClose.setGestureRecognizer()
        
        
        
        //White Placeholder
        ssidTextField.attributedPlaceholder = NSAttributedString(string: ssidFieldPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        passwordUITextField.attributedPlaceholder = NSAttributedString(string: passwordPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        //Testo protetto per campo passowrd
        passwordUITextField.isSecureTextEntry = true
        
        //Tasto clear attivo
        ssidTextField.clearButtonMode = .always
        passwordUITextField.clearButtonMode = .whileEditing
        
        guard let wifi = wifiNetwork else { return }
        
            ssidForSpotlightCheck = wifi.ssid!
            ssidTextField.text = wifi.ssid
            isHiddenUISwitch.isOn = wifi.isHidden
            isProtectedUISwitch.isOn = wifi.requiresAuthentication
            passwordUITextField.text = wifi.password
        
        if !wifi.requiresAuthentication {
            print("Nascondo")
            EncryptionAndPasswordView.isHidden = true
            EncryptionAndPasswordView.alpha = 0
        }
        
        if wifi.chosenEncryption == Encryption.wep {
            wepOrWpaUISegmentedControl.selectedSegmentIndex = 0
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
    
    
    @IBAction func isProtectedUISwitchValueChanged(_ sender: UISwitch) {
        
        UIView.animate(withDuration: 0.5) {
            self.EncryptionAndPasswordView.isHidden = !self.isProtectedUISwitch.isOn
            if self.EncryptionAndPasswordView.alpha == CGFloat(1) {
                self.EncryptionAndPasswordView.alpha = CGFloat(0)
            } else {
               self.EncryptionAndPasswordView.alpha = CGFloat(1)
            }
        }
        
        
    }
    
   
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        
        if let wifi = wifiNetwork {
            
            wifi.ssid = self.ssidTextField.text
            
            wifi.isHidden = self.isHiddenUISwitch.isOn
            
            if self.isHiddenUISwitch.isOn {
                wifi.visibility = Visibility.hidden
            } else {
                wifi.visibility = Visibility.visible
            }
            
            wifi.requiresAuthentication = self.isProtectedUISwitch.isOn
            
            if self.isProtectedUISwitch.isOn {
                
                switch wepOrWpaUISegmentedControl.selectedSegmentIndex
                {
                case 0:
                    wifi.chosenEncryption = Encryption.wep;
                    print("Wep Segment Selected");
                case 1:
                    wifi.chosenEncryption = Encryption.wpa_Wpa2;
                    print("Wpa Segment Selected");
                default:
                    break
                }

                } else {
                
                wifi.chosenEncryption = Encryption.none
            }
            
            wifi.password = self.passwordUITextField.text
            
            wifi.wifiQRString = QRManager.shared.createQRStringFromParameters(fieldSSID: wifi.ssid!, isProtected: wifi.requiresAuthentication, isHidden: wifi.isHidden, AutType: wifi.chosenEncryption!, password: wifi.password!)
            
            
            CoreDataStorage.saveContext(self.context)
            
            CoreDataManagerWithSpotlight.shared.updateItemInSpotlightWith(previous: ssidForSpotlightCheck, with: wifi)
            
            (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
            
            if let detCont = CoreDataManagerWithSpotlight.shared.detCont as? NetworkDetailViewController{
                
                detCont.ssidLabel.text = wifi.ssid
                detCont.ssidWcHrLabel.text = wifi.ssid
                detCont.visibilityLabel.text = wifi.visibility!
                detCont.chosenEncryptionLabel.text = wifi.chosenEncryption
                detCont.passwordLabel.text = wifi.password
                detCont.qrCodeImageView.image = QRManager.shared.generateQRCode(from: wifi.wifiQRString!)
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        
        
        
    }
    
}

