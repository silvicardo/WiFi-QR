//
//  NetworkListViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import CoreData


class NetworkListViewController: UIViewController {
    
    @IBOutlet weak var networksTableView: UITableView!
    
    
    // MARK: - VARIABILI
    
    let networkCellIdentifier = "networkListCell"
    var isStatusBarHidden : Bool = false
    
    
    var wifiNetworks : [WiFiNetwork] = []
    var wifiNetwork : WiFiNetwork?
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    let context = CoreDataStorage.mainQueueContext()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //FilePath CoreData
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        CoreDataManagerWithSpotlight.shared.listCont = self
        

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Avendo comunicato all'applicazione che la barra è nascosta
        super.viewWillAppear(true)
        //prima che la view appaia facciamo si che la barra venga mostrata
        isStatusBarHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
    }
    
}


//TABLE VIEW DELEGATE E DATA SOURCE

extension NetworkListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManagerWithSpotlight.shared.storage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: networkCellIdentifier , for: indexPath) as! NetworkListTableViewCell
        
        let network = CoreDataManagerWithSpotlight.shared.storage[indexPath.row]
    
        cell.backgroundColor = .clear
        
        cell.networkSsidLabel.text = network.ssid
        
        cell.networkWcHrProtectionLabel.text = network.chosenEncryption
        
        cell.networkWcHrIsHiddenLabel.text = network.visibility
        
        cell.networkProtectionLabel.text = network.chosenEncryption
        
        cell.networkVisibilityLabel.text = network.visibility
        
        guard let qrCode = QRManager.shared.generateQRCode(from: network.wifiQRString!) else {return cell}
        
        print("ImmagineQRCreataPerCella")
        cell.qrcodeImageView.image = qrCode
        cell.qrcodewChRImageView.image = qrCode
        
        return cell
        
    }
    
    
}

//NAVIGAZIONE

extension NetworkListViewController {
    
    
    // aggiungiamo questo metodo per aprire via codice il DetailController
    func showDetailFromWidgetWith(_ index:Int) {
        print("About to show Detail with index : \(index)")
        print("Storage has \(CoreDataManagerWithSpotlight.shared.storage.count) instances")
        if CoreDataManagerWithSpotlight.shared.storage.count > 0 {
            print("Storage has \(CoreDataManagerWithSpotlight.shared.storage.count) instances")
            
            // invochiamo il segue manuale e gli passiamo index come sender (così lo possiamo leggere nel metodo prepareForSegue)
            performSegue(withIdentifier: "fromWidgetToDetail", sender: index)
        }
        
    }
    // questo metodo serve per aprire il dettaglio (DettaglioWiFiCOntroller) via codice
    // lo usiamo per aprire la rete da un rislultato della ricerca di Spotlight inrenete alla nostra App
    // affinche funzioni il controller nello storyboard è stato nominato "networkDetail" (nella carta di identità, campo Storyboard ID)
    func showDetailFromSpotlightSearch(_ index:Int) {
        // diciamo allo storyboard di caricarci in memoria RicettaController
        let detail = self.storyboard!.instantiateViewController(withIdentifier: "networkDetail") as! NetworkDetailViewController
        // in base all'indice passato al metodo in cui siamo (ovvero showDetailFromSpotlightSearch(index:Int) )
        // passiamo a RicettaController la ricetta giusta
        detail.wifiNetwork = CoreDataManagerWithSpotlight.shared.storage[index]
        // apriamo il controller
        tabBarController?.present(detail, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
            case "toNetworkDetail" :
                
                if let destination = segue.destination as? NetworkDetailViewController,
                    let indexPath = networksTableView.indexPathForSelectedRow {
                    
                    
                        let wifi = CoreDataManagerWithSpotlight.shared.storage[indexPath.row]
                        //RETE DA PASSARE
                        destination.wifiNetwork = wifi
                        destination.networkIndex = CoreDataManagerWithSpotlight.shared.storage.index(of: wifi)
                        //STATUS BAR
                        isStatusBarHidden = true
                        //animiamo la sparizione della status bar
                        UIView.animate(withDuration: 0.5, animations: {
                            self.setNeedsStatusBarAppearanceUpdate()
                        })
                    }
        case "fromWidgetToDetail":
            //*** MODIFICA TODAY ***\\
            
//            DataManager.shared.caricaDati()
            
            self.networksTableView.reloadData()
            
            // Nello storyboard è stato tirato un filo dalla caramella di ListController al corpo di DetailController
            // questo ha creato un segue manuale che ho chiamato "dawidget"
            // estraiamo dal segue il DetailController
            let destination = segue.destination as! NetworkDetailViewController
            // in questo caso è il widget che ha invocato l'App, quindi leggiamo l'Int passato come sender
            // e lo usiamo per passare la rete (istanza di WiFiModel con dentro i dati di una wifi) corretta
            // il downcast as! Int è necessario perchè sender è un AnyObject (è scritto qui sopra, var di prepareForSegue)
            destination.wifiNetwork = CoreDataManagerWithSpotlight.shared.storage[sender as! Int]
            destination.networkIndex = (sender as! Int)
            
            //STATUS BAR
            isStatusBarHidden = true
            //animiamo la sparizione della status bar
            UIView.animate(withDuration: 0.5, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
        default : break
        
        }
        }
    }

//MARK: GESTIONE DELLA STATUS BAR

extension NetworkListViewController {
    
    
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        
//        return .default
//    }
//    
//    override var prefersStatusBarHidden: Bool {
//        //la barra segue le nostre imposizioni
//        return isStatusBarHidden
//    }
//    
//    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
//        //tipo di animazione per apparizione sparizione della barra
//        return .fade
//    }
}

extension NetworkListViewController {
    
   
    
    func loadData(){
        
        self.context.performAndWait{ () -> Void in
            
            let networks = WiFiNetwork.findAllForEntity("WiFiNetwork", context: self.context)
            
            if (networks?.last != nil) {
                print("networks Found")
                CoreDataManagerWithSpotlight.shared.storage = networks as! [WiFiNetwork]
                
            }
            else {
                
                print("empty array")
//                addTestEntity()
            }
            
            
        }
    }

}
