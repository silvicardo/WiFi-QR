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
    
    //SeguesIds
    let toEditSegueId = "ToEditNetwork"
    let toDeleteSegueId = "detailToDelete"
    let connectionResultId = "netToConnectionResult"
    
    //Localized Strings
    let alreadyConnected = loc("NET_IS_ALREADY_ON")
    
    let textForGenericShare : [String] = [loc("SENDING_NET_WITH_NAME"), loc("WITH_PASSWORD") ]
    
    let textForKeepPressedForOptions = loc("LONG_PRESS_TO_IMPORT")
    
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
    
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectBtnImageView : UIImageView!
    
    @IBOutlet weak var connectBtnView: DesignableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panToClose.setGestureRecognizer()
        
        CoreDataManagerWithSpotlight.shared.detCont = self
        
        guard let wiFiNetwork = wifiNetwork else {return}
        
        guard let qrCode = QRManager.shared.generateQRCode(from: wiFiNetwork.wifiQRString!) else {return}
        
        loadUIwith(wiFiNetwork, qr: qrCode)
        
        
        
        //Possibile DRAGGARE DALL'APP AD UN ALTRA su ipad
        if UIDevice.current.userInterfaceIdiom == .pad {
        view.addInteraction(UIDragInteraction(delegate: self))
        qrCodeImageView.isUserInteractionEnabled = true
        }
        
        
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
        
        let passwordToShare = password != "" ? textForGenericShare[1] + password : ""
        
        let itemsToShare : [Any] = [textForGenericShare[0] + ssid + passwordToShare + textForKeepPressedForOptions  , qr]
        
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
        
        performSegue(withIdentifier: toDeleteSegueId, sender: nil)
        
    }
    
    @IBAction func tryConnectionButtonTapped(_ sender: Any) {
        
        guard let wiFi = wifiNetwork,
              let ssid = wiFi.ssid,
              let password = wiFi.password,
              let encryption = wiFi.chosenEncryption else { return }
        
        if ssid == DataManager.shared.retrieveConnectedNetworkSsid() {
            performSegue(withIdentifier: connectionResultId , sender: alreadyConnected + ssid)
            return
        }
        
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
        
        if let connectedNetworkSsid =  DataManager.shared.retrieveConnectedNetworkSsid(), let ssid =  wifiNetwork.ssid, connectedNetworkSsid == ssid {
            
            print("THIS IS THE ACTUALLY CONNECTED NETWORK, CHANGING CONNECT BUTTON")
            connectBtnImageView.image = UIImage(named: "Checked")
            connectButton.isUserInteractionEnabled = false
        
        }
        
        ssidLabel.text = wifiNetwork.ssid
        
        
        ssidWcHrLabel.text = wifiNetwork.ssid
        
        
        if wifiNetwork.password != "" {
            passwordLabel.text = wifiNetwork.password
        } else {
            
            passwordLabel.text = noPassword
            
        }
        
//        chosenEncryptionLabel.text = wifiNetwork.chosenEncryption
//        visibilityLabel.text = wifiNetwork.visibility
        
        visibilityLabel.text = { ()->(String) in
            switch wifiNetwork.visibility {
            case "HIDDEN": return loc("HIDDEN")
            case "VISIBLE": return loc("VISIBLE")
            default: return ""
            }
        }()
        
        //(visibility.lowercased()).firstCapitalized
        
        chosenEncryptionLabel.text = { ()->(String) in
            switch wifiNetwork.chosenEncryption {
            case "NONE" : return loc("FREE")
            default: return wifiNetwork.chosenEncryption!
            }
        }()
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
        
        
        switch segue.identifier {
            
        case toEditSegueId :
            
            let destination = segue.destination as? NetworkEditViewController
            if let wifi = wifiNetwork {
                destination?.wifiNetwork = wifi
            }
            
        case toDeleteSegueId :
            let destination = segue.destination as? ConfirmToDeleteNetworkViewController
            
            if let wifi = wifiNetwork {
                destination?.network = wifi
                destination?.index = self.networkIndex
                destination?.delegate = self
            }
            
        case connectionResultId :
            let destination =  segue.destination as?  ConnectionResultViewController
            
            destination?.resultText = sender as? String
            
        default : break
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
        let passwordToShare = password != "" ? textForGenericShare[1] + password : ""
        controller.setMessageBody(textForGenericShare[0] + ssid + passwordToShare + textForKeepPressedForOptions, isHTML: false)
       
        
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
        let passwordToShare = password != "" ? textForGenericShare[1] + password : ""
        controller.body = textForGenericShare[0] + ssid + passwordToShare + textForKeepPressedForOptions
        
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

extension NetworkDetailViewController : UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        
        //Ricaviamo il punto toccato dall'utente
        let touchedPoint = session.location(in: self.view)
        //se il cast ad ImageView dell'oggetto derivante dal punto toccato non fallisce
        if let touchedImageView = self.view.hitTest(touchedPoint, with: nil) as? UIImageView {
            
            //Estraimo la UIImage dall'ImageView
            let touchedImage = touchedImageView.image
            
            //Prepara un oggetto draggabile e lo aggiunge all'array
            let itemProvider = NSItemProvider(object: touchedImage!)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = touchedImageView//risaliremo a dragItem per la preview
            
            return [dragItem]
        }
        
        return []
    }
    
    //Ciò che accade al termine dell'operazione di drag
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        
        //Rimuove l'immagine dall'app di provenienza una volta
        //droppata nella destinazione
        animator.addCompletion { (position) in
            if position == .end {
                session.items.forEach { (dragItem) in
                    if (dragItem.localObject as? UIView) != nil {
//                        touchedImageView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    //Definisce la preview dell'oggetto draggato
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        //desideriamo solo l'immagine selezionata
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
    
    
    
    
    
}

extension NetworkDetailViewController : ConfirmToDeleteVCDelegate {
    
    func confirmToDelete(_ viewController: ConfirmToDeleteNetworkViewController, didTapDeleteButton button: UIButton) {
        print("delegate method for going back to NetworkList")
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

