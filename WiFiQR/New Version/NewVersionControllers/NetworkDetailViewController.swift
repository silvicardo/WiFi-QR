//
//  NetworkDetailViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 20/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import MessageUI
import NetworkExtension

class NetworkDetailViewController: UIViewController {
    
    // MARK: - VARIABLES
    
    var wifiNetwork : WiFiNetwork?
    
    var networkIndex : Int!
    
    let toEditSegueId = "ToEditNetwork"
    
    let textForGenericShare : [String] = ["I'm sending you this QR to access network with ssid:  ", ", password: " ]
    
    let textForKeepPressedForOptions = "\nKeep the QRCode pressed for two seconds to show import options"
    
    let noPassword = "No Password"
    
    // MARK: - OUTLETS
    
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
    @IBOutlet weak var shareNetworkView: DesignableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panToClose.setGestureRecognizer()
        
        CoreDataManagerWithSpotlight.shared.detCont = self
        
        guard let wiFiNetwork = wifiNetwork else {return}
        
        guard let qrCode = QRManager.shared.generateQRCode(from: wiFiNetwork.wifiQRString!) else {return}
        
        loadUIwith(wiFiNetwork, qr: qrCode)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
    
    // MARK: - IB ACTIONS
    
    @IBAction func shareNetworkButtonTapped(_ sender: Any) {
        
        guard let wifiToShare = wifiNetwork else { return }
        
        guard let ssid = wifiToShare.ssid,
            let password = wifiToShare.password,
            let qr = QRManager.shared.generateQRCode(from: wifiToShare.wifiQRString!) else { return }
        
        let itemsToShare : [Any] = [textForGenericShare[0] + ssid + textForGenericShare[1] + password , qr]
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
        
        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = self.shareNetworkView
            popOver.sourceRect = self.shareNetworkView.bounds
            popOver.permittedArrowDirections = .down
            popOver.backgroundColor = UIColor.lightGray
            
        }
        
    }
    
    @IBAction func shareBySmsButtonTapped(_ sender: Any) {
        
        guard MFMessageComposeViewController.canSendText() else { return }
        
        guard let wifiToShare = wifiNetwork else { return }
        
        guard let ssid = wifiToShare.ssid,
            let password = wifiToShare.password,
            let qr = QRManager.shared.generateQRCode(from: wifiToShare.wifiQRString!),
            let qrData = qr.pngData() else { return }
        
        let smsController = prepareMFMessageComposeViewControllerWith(ssid: ssid, password: password, qrCode: qrData)
        
        present(smsController, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func shareByEmailButtonTapped(_ sender : Any) {
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        guard let wifiToShare = wifiNetwork else { return }
        
        guard let ssid = wifiToShare.ssid,
            let password = wifiToShare.password,
            let qr = QRManager.shared.generateQRCode(from: wifiToShare.wifiQRString!),
            let qrData = qr.jpegData(compressionQuality: 1.0) else { return }
        
        let mailController = prepareMFMailComposeViewControllerWith(ssid: ssid, password: password, qrCode: qrData)
        
        present(mailController, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteNetworkButtonTapped(_ sender: Any) {
        
        CoreDataManagerWithSpotlight.shared.storage.remove(at: networkIndex)
        
        CoreDataStorage.mainQueueContext().delete(wifiNetwork!)
        
        CoreDataStorage.saveContext(CoreDataStorage.mainQueueContext())
        
        CoreDataManagerWithSpotlight.shared.deleteFromSpotlightBy(ssid: ssidLabel.text!)
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tryConnectionButtonTapped(_ sender: Any) {
        
        guard let wiFi = wifiNetwork,
              let ssid = wiFi.ssid,
              let password = wiFi.password,
              let encryption = wiFi.chosenEncryption else { return }
        
        let hotspotConfig : NEHotspotConfiguration = creazioneConfigDiRete(nomeRete: ssid,
                                                            password: password,
                                                            passwordRichiesta: wiFi.requiresAuthentication,
                                                            tipoPassword: encryption)
        
        hotspotConfig.joinOnce = false //connessione da ricordare
       
        NEHotspotConfigurationManager.shared.apply(hotspotConfig) { (error) in
            
            if let error = error {
                print("Error attempting connection, \(error.localizedDescription)")
                //self.showError(error: error)
            }
            else {
                print("connection OK!!")
                //self.showSuccess()
            }
        }
        
        
    }
    
}

//MARK: - UI FUNCTIONS
extension NetworkDetailViewController {
    
    func loadUIwith(_ wifiNetwork : WiFiNetwork,qr qrCode : UIImage ) {
        
        ssidLabel.text = wifiNetwork.ssid
        ssidWcHrLabel.text = wifiNetwork.ssid
        
        
        if wifiNetwork.password != "" {
            passwordLabel.text = wifiNetwork.password
        } else {
            
            passwordLabel.text = noPassword
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

// MARK: - NAVIGATION

extension NetworkDetailViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == toEditSegueId,
            let destination = segue.destination as? NetworkEditViewController,
            let wifi = wifiNetwork{
            
            destination.wifiNetwork = wifi
        }
        
    }
    
    
}

//MARK: MAIL METHODS
extension NetworkDetailViewController : MFMailComposeViewControllerDelegate {
    
    func prepareMFMailComposeViewControllerWith(ssid: String, password: String, qrCode: Data) -> MFMailComposeViewController {
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.addAttachmentData(qrCode, mimeType: "image/png", fileName: "myQrToAdd")
        controller.setSubject(ssid)
        controller.setMessageBody(textForGenericShare[0] +  ssid +  textForGenericShare[1] + password + textForKeepPressedForOptions, isHTML: false)
        controller.setMessageBody( textForGenericShare[0] +  ssid +  textForGenericShare[1] + password + textForKeepPressedForOptions, isHTML: false)
        
        return controller
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //chiudiamo il controller
        controller.dismiss(animated: true, completion: nil)
        //se l'invio è possibile e va a buon fine o viene annullato dall'utente OK,
        //altrimenti manda l'alert
        if result != MFMailComposeResult.sent && result != MFMailComposeResult.cancelled {
            
        }
    }
}

//MARK: SMS METHODS

extension NetworkDetailViewController : MFMessageComposeViewControllerDelegate {
    
    
    func prepareMFMessageComposeViewControllerWith(ssid: String, password: String, qrCode: Data) -> MFMessageComposeViewController {
        
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.addAttachmentData(qrCode, typeIdentifier: "image/.png", filename: "image.png")
        controller.body = textForGenericShare[0] +  ssid +  textForGenericShare[1] + password + textForKeepPressedForOptions
        
        return controller
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        //If sending sms is possible proceeds with actions.....
        controller.dismiss(animated: true, completion: nil)
        
        //chiusura automatica della modal dettaglio disabilitata
        //self.dismiss(animated: true, completion: nil)
        
        
        //If sending sms is not possible proceeds with next statement
        if !MFMessageComposeViewController.canSendText() {
            
            controller.dismiss(animated: true, completion: nil)
            
        }
        
        
    }

    
}


extension NetworkDetailViewController {
    
    ///CREA UNA NEHOTSPOTCONFIGURATION(DA UN ISTANZA DI WiFiModel o INPUT MANUALE)
    func creazioneConfigDiRete(nomeRete: String, password: String, passwordRichiesta: Bool, tipoPassword: String) -> NEHotspotConfiguration {
        
        //Se la rete richiede password procedi altrimenti restituisci
        //una configurazione libera
        guard passwordRichiesta  else { return NEHotspotConfiguration(ssid: nomeRete)}
        
        if tipoPassword == Encryption.wpa_Wpa2 {//WPA/WPA2
            
            return NEHotspotConfiguration(ssid: nomeRete, passphrase: password, isWEP: false)
        }
        //WEP
        return  NEHotspotConfiguration(ssid: nomeRete, passphrase: password, isWEP: true)
        
    }
}


