//
//  TodayNetworkViewController.swift
//  WiFiQRWidget
//
//  Created by riccardo silvi on 08/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayNetworkViewController: UIViewController  {
    
    enum CurrentConnectionState {
        case connectedButNotInStorage
        case connectedAndInStorage
        case notConnected
        
    }

    //Localized Strings
    
    let copyPass = loc("COPY_PASS")
    
    let passCopied = loc("PASS_COPIED")
    
    let copyNetworkText = loc("COPY_NETWORK")
    
    let networkCopied = loc("COPIED_NETWORK")
    
    let copyQRText = loc("COPY_QR")
    
    let copiedQRText = loc("COPIED_QR")
    
    let textForGenericShare : [String] = [loc("SENDING_FROM_WIDG_WITH_NAME"), loc("WITH_PASSWORD") ]
    
    let textForKeepPressedForOptions = loc("LONG_PRESS_TO_IMPORT")
    
    let connectedToNetwork = loc("CONNECTED_TO_NET")
    
    let butNotRecognized = loc("BUT_NOT_RECOGNIZED")
    
    let notConnectedToWiFi = loc("NOT_CONNECTED_AT_ALL")
    
    
    //Timer UI Helper method
    var timerCompletionFunc : ()->Void = {}
    
    // MARK: - Variabili globali
    
    let context = CoreDataStorage.mainQueueContext()
    
    var coreDataNetworks = [WiFiNetwork]()
    
    var timer = Timer()
    
    var contatore = 1
    
    var ssidReteAttuale = WiFiConnectionManager.shared.retrieveConnectedNetworkSsid()
    
    var reteWiFi: WiFiNetwork?

    var indiceIstanza: Int?
    
    var isMaiusc : Bool = false
    
    var tipoAutenticazione : String = Encryption.wep
    
    
    var altezza : CGFloat?
    
    //Know networkView Outlets
    @IBOutlet weak var knownConnectedNetworkView: UIView!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var ssidUILabel: UILabel!
    
    @IBOutlet weak var passwordUILabel: UILabel!
    
    @IBOutlet weak var qrCodeUIImageView: UIImageView!
    
    @IBOutlet weak var copyPassToClipboardView: BorderView!
    
    @IBOutlet weak var copyPassButton : UIButton!
    
    @IBOutlet weak var copyPassLabel: UILabel!
    
    @IBOutlet weak var copyPassImageView: UIImageView!
    
    @IBOutlet weak var copyNetworkLabel: UILabel!
    
    @IBOutlet weak var copyQRCodeLabel: UILabel!
    
    @IBOutlet weak var copyNetworkButton: UIButton!
    @IBOutlet weak var copyNetworkView: BorderView!
    
    @IBOutlet weak var copyNetworkImageView: UIImageView!
    @IBOutlet weak var copyQRCodeButton: UIButton!
    @IBOutlet weak var copyQRCodeView: BorderView!
    
    @IBOutlet weak var copyQRCodeImageView: UIImageView!
    @IBOutlet weak var plusImageView : UIImageView!
    
    //Unknown NetworkViewOutlet
    @IBOutlet weak var unknownOrNotConnectedView: UIView!
    @IBOutlet weak var unknownOrNotConnectedImageView: UIImageView!
    @IBOutlet weak var unknownOrNotConnectedLabel: UILabel!
    @IBOutlet weak var addConnectedUnknownNetworkButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("widget viewDidLoadStarted")
        
        copyPassLabel.text = copyPass
        copyNetworkLabel.text = copyNetworkText
        copyQRCodeLabel.text = copyQRText
    
        buttonsStackView.isHidden = true
        
        searchForConnectedNetworkInCoreDataAndUpdateUI()
        
        print("widget viewDidLoadFinished")
    }
    

    @IBAction func viewNetworkButtonPressed(_ sender: UIButton) {
        //se indice non è vuoto, quindi se è stata trovata una rete
        if let indice = indiceIstanza {
            let indexPath = IndexPath(row: indice, section: 1)
            // per fare in modo che il widget possa aprire la sua App bisogna andare alla radice del progetto, tab Info
            // ed impostare un "URL Types", guarda questo esempio per capire, in un campo ho scritto pizzalist, tutto li
            // quindi adesso quest'App può essere invocata con openUrl e lo schema pizzalist://
            
            // l'url deve essere per forza fatto così wifiqr://?q= , la parte ?q= è importante se no la creazione dell'url fallise
            let url = URL(string: "wifiqr://?q=\(indexPath.row)")// else {return }
            
            debugPrint(url!)
            // diciamo all'esxtension di aprire un url, e gli passiamo quello della nostra App
            extensionContext?.open(url!, completionHandler: nil)
        }
        
    }
    
    @IBAction func addConnectedUnknownNetworkTapped(_ sender: UIButton) {
        
        let url = URL(string: "wifiqr://?q=addNetwork")
        
        debugPrint(url!)
        // diciamo all'esxtension di aprire un url, e gli passiamo quello della nostra App
        extensionContext?.open(url!, completionHandler: nil)
    }
    
    @IBAction func copyPasswordButtonTapped(_ sender: UIButton) {
        //controllo istanza
        if let retewifiOK = reteWiFi, let password = retewifiOK.password {
            
            invertIsUserEnabledStatusForButtons()
            copyToClipboard(text: password, animating: copyPassImageView, in: copyPassToClipboardView, changing: copyPassLabel, with: passCopied, withCompletionHandler: {
                //ripristiniamo gli elementi della view
                self.copyPassToClipboardView.backgroundColor = .black
                self.copyPassImageView.image = UIImage(named: "copycopyClipboard")
                self.copyPassLabel.text = self.copyPass
                self.copyPassLabel.textColor = .white
                self.invertIsUserEnabledStatusForButtons()
            })
            
        }
        
    }
    
    @IBAction func copyNetworkButtonTapped(sender: UIButton) {
       
        guard let wifiToShare = reteWiFi,
            let ssid = wifiToShare.ssid,
            let password = wifiToShare.password else {return}

            let passwordToShare = password != "" ? textForGenericShare[1] + password : ""
        
            let stringToShare = textForGenericShare[0] + ssid + passwordToShare
        
         invertIsUserEnabledStatusForButtons()
        
        copyToClipboard(text: stringToShare, animating: copyNetworkImageView, in: copyNetworkView, changing: copyNetworkLabel, with: networkCopied, withCompletionHandler: {
                //ripristiniamo gli elementi della view
                self.copyNetworkView.backgroundColor = .black
                self.copyNetworkImageView.image = UIImage(named: "wi-fiwifiwhite")
                self.copyNetworkLabel.text = self.copyNetworkText
                self.copyNetworkLabel.textColor = .white
                self.invertIsUserEnabledStatusForButtons()
            })

    }
    
    @IBAction func copyQrCodeButtonTapped(sender: UIButton) {
        
        guard let wiFiNetwork = reteWiFi,
            let qrString = wiFiNetwork.wifiQRString,
            let qrCode = QRManager.shared.generateQRCode(from: qrString) else {return}
        
            plusImageView.isHidden = true
           invertIsUserEnabledStatusForButtons()
        
        copyToClipboard(img: qrCode, animating: copyQRCodeImageView, in: copyQRCodeView , changing: copyQRCodeLabel, with: copiedQRText, withCompletionHandler: {
            
            //ripristiniamo gli elementi della view
            self.copyQRCodeView.backgroundColor = .black
            self.copyQRCodeImageView.image = UIImage(named: "RETELIBERACASA")
            self.copyQRCodeLabel.text = self.copyNetworkText
            self.copyQRCodeLabel.textColor = .white
            self.plusImageView.isHidden = false
            self.invertIsUserEnabledStatusForButtons()
        })
        
        
    }
    
    func copyToClipboard(text string : String? = nil, img image: UIImage? = nil, animating imageView : UIImageView, in view: UIView, changing label: UILabel, with text : String, withCompletionHandler completionHandler: @escaping ()->Void) {
        
        self.timerCompletionFunc = completionHandler
        
        //copia nel pasteboard
        let pasteboard = UIPasteboard.general
        
        if let imageToShare = image {
            pasteboard.image = imageToShare
        } else if let stringToShare = string {
            pasteboard.string = stringToShare
        }
        //Diamo all'utente un feedback
        view.backgroundColor = UIColor.blue
        
        //immagine settings con animazione rotazione
        imageView.image = UIImage(named: "settings")
        
        UIView.animate(withDuration: 0.5) { () -> Void in
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.45, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
        }, completion: nil)
        
        //regolazione colore e testo label
        label.textColor = UIColor.lightGray
        label.text = text
    
        
        //tramite un timer ripristiniamo dopo 2 secondi lo stato originale degli elementi appena modificati
        //timer per reazione della view
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(counterFunc), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func counterFunc() {
        //diminuiamo il timer di un unità
        self.contatore -= 1
        //e se il contatore raggiunge lo 0....
        if self.contatore == 0 {
            //blocchiamo il timer
            self.timer.invalidate()
            //contatore torna a 2
            self.contatore = 1
            //ripristiniamo gli elementi nel completionHandler del controller
            self.timerCompletionFunc()

        }
        
    }
    
    func invertIsUserEnabledStatusForButtons() {
        copyPassButton.isUserInteractionEnabled = !copyPassButton.isUserInteractionEnabled
        copyQRCodeButton.isUserInteractionEnabled = !copyQRCodeButton.isUserInteractionEnabled
        copyNetworkButton.isUserInteractionEnabled = !copyNetworkButton.isUserInteractionEnabled
    }
    
    
    func updateWidgetAppearance() {
        // We can extend the widget only if we found a network
        extensionContext?.widgetLargestAvailableDisplayMode = reteWiFi != nil ? .expanded : .compact
        
        self.unknownOrNotConnectedView.isHidden = (reteWiFi != nil)
        self.knownConnectedNetworkView.isHidden = !(reteWiFi != nil)
    }
    
    
    func updateNetworkUIFor(_ currentConnectionState : CurrentConnectionState) {
        
        switch currentConnectionState {
            
        case .connectedAndInStorage:
            guard let retewifi = reteWiFi ,
                let qrString = retewifi.wifiQRString,
                let qr = QRManager.shared.generateQRCode(from: qrString),
                let ssid = retewifi.ssid, let password = retewifi.password else {return}
            
            //mettiamo i dati a schermo
            self.ssidUILabel.text = ssid
            self.qrCodeUIImageView.image = qr
            print("network password: \(password)")
            self.passwordUILabel.text = password
            
        case .connectedButNotInStorage:
            debugPrint("we have network name but it's not stored in-app")
            guard let ssidReteConnessa = ssidReteAttuale else { return }
            unknownOrNotConnectedLabel.text = connectedToNetwork + ssidReteConnessa + butNotRecognized
            unknownOrNotConnectedImageView.image = UIImage(named: "Non")
            addConnectedUnknownNetworkButton.isUserInteractionEnabled = true
            
            
        case .notConnected :
            debugPrint("we are not connected to a wi-fi")
            unknownOrNotConnectedLabel.text = notConnectedToWiFi
            addConnectedUnknownNetworkButton.isUserInteractionEnabled = false
            
        }
        
    }
    func searchForConnectedNetworkInCoreDataAndUpdateUI(){
        
        context.performAndWait{ () -> Void in
            
            let networks = WiFiNetwork.findAllForEntity("WiFiNetwork", context: context)
            
            if (networks?.last != nil) {
                print("networks Found, Shared Container Loaded")
                
                coreDataNetworks = networks as! [WiFiNetwork]
                
//                print(coreDataNetworks)
                
                if (coreDataNetworks.last != nil) {
                    
                    if let ssidReteConnessa = ssidReteAttuale {
                        
                        for network in coreDataNetworks {
                            if ssidReteConnessa == network.ssid! {
                                debugPrint("CONNECTED TO \(ssidReteConnessa)")
                                
                                self.reteWiFi = network
                                
                                updateNetworkUIFor(.connectedAndInStorage)
                                
                                //trasmettiamo l'indice della rete rilevata alla nostra var
                                self.indiceIstanza = coreDataNetworks.firstIndex(of: network)
                                
                                return
                            }
                        }
                        updateNetworkUIFor(.connectedButNotInStorage)
                        
                    } else {
                        updateNetworkUIFor(.notConnected)
                        
                    }
                }
            }
       
            
        }
        updateWidgetAppearance()
    }

    
}

extension TodayNetworkViewController : NCWidgetProviding {

    
    //MARK: - Dimensioni e Margini Widget

    
    //per l'espansione del widget
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        let expanded = activeDisplayMode == .expanded
        
        preferredContentSize = { () -> CGSize in
            
            switch expanded {
                
            case true :
                
                self.buttonsStackView.isHidden = false
                return CGSize(width: maxSize.width, height: 190)
                
            case false : //.compact
                
                self.buttonsStackView.isHidden = true
                return  maxSize
            }
        }()
        
    }
    
    
    // dice quanto deve essere il margine del nostro widget dai bordi
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // visto che abbiamo una collection view usiamo le sue funzioni per distanziare le celle
        // quindi restituiamo zero margine
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: - Aggiornamento Dati Widget
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        print("widgetPerformUpdate")
        // Perform any setup necessary in order to update the view.
        searchForConnectedNetworkInCoreDataAndUpdateUI()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
        print("widgetPerformUpdateEnded")
    }

}



extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    func rotate720Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 4.0)
        rotateAnimation.duration = duration
        
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
