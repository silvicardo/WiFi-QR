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
    
    
    //segues Id
    
    let toIssueAlert = "editToIssueAlert"
    
    //UI Components Strings
    let ssidFieldPlaceholderText = loc("INPUT_SSID")
    
    let passwordPlaceholderText = loc("INPUT_PASS")
    
    let visibilityText = loc("VISIBILITY_SWITCH")
    
    let protectionText = loc("PROTECTION_SWITCH")
    
    let dismissBtnText = loc("DISMISS_BUTTON")
    
    let acceptBtnText = loc("ACCEPT_BUTTON")
    
    let needPasswordToProceed = loc("PASS_NEEDED")
    
    let needSSIDToProceed = loc("SSID_NEEDED")
    
    let hasDuplicate = loc("DUPLICATE_FOUND")
    
    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var ssidTextField: UITextField!
    
    @IBOutlet weak var visibilitySwitchLabel: UILabel!
    
    @IBOutlet weak var protectionSwitchLabel: UILabel!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var isHiddenUISwitch: UISwitch!
    
    @IBOutlet weak var isProtectedUISwitch: UISwitch!
    
    @IBOutlet weak var wepOrWpaUISegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var passwordUITextField: UITextField!
    
    @IBOutlet weak var encryptionAndPasswordView: UIView!
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        CoreDataManagerWithSpotlight.shared.editCont = self
        
        panToClose.setGestureRecognizer()
        
        //localize Labels and Buttons
        visibilitySwitchLabel.text = visibilityText
        protectionSwitchLabel.text = protectionText
        dismissButton.setTitle(dismissBtnText, for: .normal)
        acceptButton.setTitle(acceptBtnText, for: .normal) 
        
        //White Placeholder
        ssidTextField.attributedPlaceholder = NSAttributedString(string: ssidFieldPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        passwordUITextField.attributedPlaceholder = NSAttributedString(string: passwordPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        //Testo non  protetto per campo passowrd
        passwordUITextField.isSecureTextEntry = false
        
        //Tasto clear attivo
        ssidTextField.clearButtonMode = .always
        passwordUITextField.clearButtonMode = .whileEditing
        
        guard let wifi = wifiNetwork else { return }
        
            ssidForSpotlightCheck = wifi.ssid!
            ssidTextField.text = wifi.ssid
            isHiddenUISwitch.isOn = wifi.isHidden
            isProtectedUISwitch.isOn = wifi.requiresAuthentication
            self.passwordUITextField.isEnabled = self.isProtectedUISwitch.isOn
            passwordUITextField.text = wifi.password
        
        if !wifi.requiresAuthentication {
          
            encryptionAndPasswordView.isHidden = true
            encryptionAndPasswordView.alpha = 0
        }
        
        if wifi.chosenEncryption == Encryption.wep {
            wepOrWpaUISegmentedControl.selectedSegmentIndex = 0
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
    
    
    @IBAction func isProtectedUISwitchValueDidChange(_ sender: UISwitch) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.encryptionAndPasswordView.isHidden = !self.isProtectedUISwitch.isOn
            
            self.passwordUITextField.isEnabled = self.isProtectedUISwitch.isOn
            
            self.passwordUITextField.text = ""
            
            if self.encryptionAndPasswordView.alpha == CGFloat(1) {
                self.encryptionAndPasswordView.alpha = CGFloat(0)
            } else {
               self.encryptionAndPasswordView.alpha = CGFloat(1)
            }
        }
        
        
    }
    
   
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        
        //Not accepted because ssidField must be filled
        guard  let newSsid = ssidTextField.text, !newSsid.isEmpty, newSsid != "" else { performSegue(withIdentifier: toIssueAlert, sender: needSSIDToProceed); return }
        
        guard let password = passwordUITextField.text else { return }
        
        //Not accepted because of password needed
        if isProtectedUISwitch.isOn && password.isEmpty  {
            performSegue(withIdentifier: toIssueAlert, sender: needPasswordToProceed)
            return
        }
    
        guard let wiFiToEdit = wifiNetwork, let ssidToEdit = wiFiToEdit.ssid else { return }
        
        if ssidToEdit != newSsid {
        
        if checkDuplicatesForNetwork(with: newSsid) == true {
            ssidTextField.text = ssidToEdit
            performSegue(withIdentifier: toIssueAlert, sender: hasDuplicate)
            return
            }
        }
        
        editCurrent(wiFiToEdit)
        
        
    }
    
}

extension NetworkEditViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == toIssueAlert {
            
            if let destination = segue.destination as? NetworkCreationIssueAlertViewController, let issue = sender as? String {
                
                destination.issueDescription = issue
                
            }
        }
    }
}

extension NetworkEditViewController {
    
    func checkDuplicatesForNetwork(with newSsid: String) -> Bool {
        
        for network in CoreDataManagerWithSpotlight.shared.storage {
            
            if let ssidToCheck = network.ssid {
                
                if newSsid == ssidToCheck {
                     debugPrint("FOUND DUPLICATE OF \(newSsid)")
                    //stops the function if a duplicte is found
                    return true
                }
            }
        }
        return false
    }

    
    func editCurrent(_ wifi: WiFiNetwork) {
        
            wifi.ssid = self.ssidTextField.text
            
            wifi.isHidden = self.isHiddenUISwitch.isOn
            
            wifi.visibility = self.isHiddenUISwitch.isOn ? Visibility.hidden : Visibility.visible
            
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
            
            wifi.password = (self.passwordUITextField.text == "") ?  "No Password" :  self.passwordUITextField.text
        
        
            wifi.wifiQRString = QRStringa.init(ssid: wifi.ssid!,
                                               authType: wifi.requiresAuthentication ? wifi.chosenEncryption! : "",
                                               password: wifi.password!,
                                               visibility: wifi.visibility!
                                                ).buildQRString()
            
            CoreDataStorage.saveContext(self.context)
            
            CoreDataManagerWithSpotlight.shared.updateItemInSpotlightWith(previous: ssidForSpotlightCheck, with: wifi)
            
            (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
            
            let index = IndexPath(item: CoreDataManagerWithSpotlight.shared.storage.firstIndex(of:wifi)!, section: 0)
            print(CoreDataManagerWithSpotlight.shared.storage[index.row])
            (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.scrollToRow(at: index, at: .top, animated: true)
            
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
