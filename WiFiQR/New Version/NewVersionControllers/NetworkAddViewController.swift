//
//  AddNewNetworkViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 28/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class NetworkAddViewController: UIViewController {

    //Core Data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = CoreDataStorage.mainQueueContext()
    
    //Observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Localization Strings
    let ssidFieldPlaceholderText = loc("INPUT_SSID")
    
    let passwordPlaceholderText = loc("INPUT_PASS")
    
    let resetButtonText = loc("RESET_BUTTON")
    
    let acceptButtonText = loc("ACCEPT_BUTTON")
    
    let visibilityText = loc("VISIBILITY_SWITCH")
    
    let protectionText = loc("PROTECTION_SWITCH")
    

    
    let visible  = CoreDataManagerWithSpotlight.Visibility(rawValue: Visibility.visible)!
    
    let hidden = CoreDataManagerWithSpotlight.Visibility(rawValue: Visibility.hidden)!
    
    
    
    @IBOutlet weak var dialogView: DesignableView!
    
    @IBOutlet weak var ssidTextField: UITextField!
    
    @IBOutlet weak var isHiddenUISwitch: UISwitch!
    
    @IBOutlet weak var isProtectedUISwitch: UISwitch!
    
    @IBOutlet weak var isHiddenSwitchLabel: UILabel!
    
    @IBOutlet weak var isProtectedSwitchLabel: UILabel!
    
    @IBOutlet weak var wepOrWpaUISegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var passwordUITextField: UITextField!
    
    @IBOutlet weak var encryptionAndPasswordView: UIView!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Localization
        resetButton.setTitle(resetButtonText, for: .normal)
        acceptButton.setTitle(acceptButtonText, for: .normal)
        isProtectedSwitchLabel.text = protectionText
        isHiddenSwitchLabel.text = visibilityText
        
        
        dialogView.isHidden = true
        dialogView.alpha = 0
        
        CoreDataManagerWithSpotlight.shared.addCont = self
        
        prepareUIForNewInsertion(atFirstLaunch: true)
        
        UIView.animate(withDuration: 0.7, animations: {
            
            self.dialogView.alpha = 1
            self.dialogView.isHidden = false
            
            })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dialogView.isHidden = true
        dialogView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForConnectedNetworkAndAdjustSSIDTextField()
        
        UIView.animate(withDuration: 0.7, animations: {
            
            self.dialogView.alpha = 1
            self.dialogView.isHidden = false
            print(self.printNetworkList())
            
        })
        
    }
    
    
    
    @IBAction func isProtectedUISwitchValueChanged(_ sender: UISwitch) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.encryptionAndPasswordView.isHidden = !self.isProtectedUISwitch.isOn
            
            self.passwordUITextField.isEnabled = self.isProtectedUISwitch.isOn
            
            self.passwordUITextField.text = ""
            
            self.encryptionAndPasswordView.alpha = self.encryptionAndPasswordView.alpha == CGFloat(1) ? CGFloat(0) : CGFloat(1)
            
        }
        
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        prepareUIForNewInsertion()
        
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        
        guard  let ssid = ssidTextField.text, !ssid.isEmpty, ssid != "" else { return }
        
        guard let password = passwordUITextField.text else { return }
        
        if isProtectedUISwitch.isOn && password.isEmpty {
            return
        }
        
        let newNetwork = CoreDataManagerWithSpotlight.shared.createNewNetwork(in: self.context,
            ssid: ssid,
            visibility: self.isHiddenUISwitch.isOn ? self.hidden : self.visible,
            isHidden: self.isHiddenUISwitch.isOn,
            requiresAuthentication: self.isProtectedUISwitch.isOn,
            chosenEncryption: getChosenAuthentication(),
            password: passwordUITextField.text!)
        
        CoreDataManagerWithSpotlight.shared.storage.append(newNetwork)
        
        CoreDataManagerWithSpotlight.shared.indexInSpotlight(wifiNetwork: newNetwork)
        
        CoreDataStorage.saveContext(self.context)
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
        
        let index = IndexPath(item: CoreDataManagerWithSpotlight.shared.storage.index(of:newNetwork)!, section: 0)
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.scrollToRow(at: index, at: .top, animated: true)
        
        prepareUIForNewInsertion()
        
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        
        tabBarController.selectedIndex = 1
        
    }
}

extension NetworkAddViewController {
    
    func prepareUIForNewInsertion(atFirstLaunch firstLaunch : Bool = false) {
        
        //White Placeholders + Default Strings and empty text
    
        ssidTextField.attributedPlaceholder = NSAttributedString(string: ssidFieldPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
        checkForConnectedNetworkAndAdjustSSIDTextField()
        
        passwordUITextField.attributedPlaceholder = NSAttributedString(string: passwordPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordUITextField.text = ""
        
        //Testo protetto per campo passowrd
        passwordUITextField.isSecureTextEntry = true
        
        //PassField disabled
        passwordUITextField.isEnabled = false
        
        //Tasto clear attivo
        ssidTextField.clearButtonMode = .always
        passwordUITextField.clearButtonMode = .whileEditing
        
        //UISwitches off
        isHiddenUISwitch.isOn = false
        isProtectedUISwitch.isOn = false
        
        //Gestione della View WepOrWpa e PassField
        if !firstLaunch, !self.encryptionAndPasswordView.isHidden{
       
             UIView.animate(withDuration: 0.5) {
            //Hidden WEP or WPA Segment + PassField
            self.encryptionAndPasswordView.isHidden = true
            self.encryptionAndPasswordView.alpha = 0
            }
        }
    }
    
    func checkForConnectedNetworkAndAdjustSSIDTextField(){
        
        if let connectedNetworkSsid = getWiFiSsid() {
            
            print("Available Networks : \(printNetworkList())")
            
            print("Connected Network: \(connectedNetworkSsid)")
            
            ssidTextField.text = connectedNetworkSsid
            
        } else {
            
            ssidTextField.text = ""
            
        }
    }
    
    func getChosenAuthentication() -> CoreDataManagerWithSpotlight.Encryptions {
        
        
        var chosenAuth = CoreDataManagerWithSpotlight.Encryptions(rawValue: Encryption.none)!
        
        if self.isProtectedUISwitch.isOn {
            
            switch wepOrWpaUISegmentedControl.selectedSegmentIndex
            {
            case 0:
                chosenAuth =  CoreDataManagerWithSpotlight.Encryptions(rawValue: Encryption.wep)!;
                print("Wep Segment Selected");
            case 1:
                chosenAuth =  CoreDataManagerWithSpotlight.Encryptions(rawValue: Encryption.wpa_Wpa2)!;
                print("Wpa Segment Selected");
            default:
                break
            }
            
        }
        
            return chosenAuth
        
    }
}

extension NetworkAddViewController {
    
    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    func printNetworkList() -> [String] {
        
        var networks : [String] = []
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    if let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String {
                        networks.append(ssid)
                    }
                }
            }
        }
        return networks
    }
}
