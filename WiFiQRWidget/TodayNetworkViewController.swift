//
//  TodayNetworkViewController.swift
//  WiFiQRWidget
//
//  Created by riccardo silvi on 08/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayNetworkViewController: UIViewController, NCWidgetProviding  {

    // MARK: - Variabili globali
    
    let context = CoreDataStorage.mainQueueContext()
    
    var timer = Timer()
    
    var contatore = 2
    
    var ssidReteAttuale = DataManager.shared.recuperaNomeReteWiFi()
    
    var reteWiFi: WiFiNetwork?

    var indiceIstanza: Int?
    
    var isMaiusc : Bool = false
    
    var tipoAutenticazione : String = Encryption.wep
    
    
    var altezza : CGFloat?
    
    
    @IBOutlet weak var ssidUILabel: UILabel!
    
    @IBOutlet weak var passwordUILabel: UILabel!
    
    @IBOutlet weak var qrCodeUIImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        context.performAndWait{ () -> Void in
            
            let networks = WiFiNetwork.findAllForEntity("WiFiNetwork", context: context)
            
            if (networks?.last != nil) {
                print("networks Found, Shared Container Loaded")
                
                CoreDataManagerWithSpotlight.shared.storage = networks as! [WiFiNetwork]
                
                print(CoreDataManagerWithSpotlight.shared.storage)
                
                
                if (CoreDataManagerWithSpotlight.shared.storage.last != nil) {
                    
                    if let ssidReteConnessa = ssidReteAttuale {
                        
                        for network in CoreDataManagerWithSpotlight.shared.storage {
                            if ssidReteConnessa == network.ssid! {
                                debugPrint("CONNECTED TO \(ssidReteConnessa)")
                                
                                guard let qr = QRManager.shared.generateQRCode(from: network.wifiQRString!) else {return}
                                
                                //mettiamo i dati a schermo
                                self.ssidUILabel.text = network.ssid!
                                self.qrCodeUIImageView.image = qr
                                self.passwordUILabel.text = network.password
                                
                                //trasmettiamo l'indice della rete rilevata alla nostra var
                                self.indiceIstanza = CoreDataManagerWithSpotlight.shared.storage.index(of: network)
                            }
                        }
                        
                    }
                }
            }
        }
        // impostiamo la misura del widget
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            // diciamo all'esxtension di aprire un url, e gli passiamo quello della nostra App
            extensionContext?.open(url!, completionHandler: nil)
        }
        
    }
    
    

    
    //MARK: - Dimensioni e Margini Widget
    
    //per l'espansione del widget
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200 ) : maxSize
    }
    
    
    // dice quanto deve essere il margine del nostro widget dai bordi
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // visto che abbiamo una collection view usiamo le sue funzioni per distanziare le celle
        // quindi restituiamo zero margine
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: - Aggiornamento Dati Widget
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }

}
