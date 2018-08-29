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
    let context = CoreDataStorage.mainQueueContext()
    
   
    var isStatusBarHidden : Bool = false
    
    var wifiNetworks : [WiFiNetwork] = []
    var wifiNetwork : WiFiNetwork?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //FilePath CoreData
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        do {
            //l'array delle cose da fare corrisponderà
            //al risultato di tale richiesta
            wifiNetworks =  try self.context.fetch(WiFiNetwork.fetchRequest())
        } catch  {
            print("Errore durante il caricamento, problema: \(error)")
        }
        
        print(wifiNetworks.count)
        //aggiorniamo la table
        self.networksTableView.reloadData()
        
        //Istanza di test
//        let testNetwork = CoreDataManagerWithSpotlight.shared.createNewNetwork(in: context,
//                                           ssid: "RETELIBERACASA",
//                                           visibility: .visible,
//                                           isHidden: false,
//                                           requiresAuthentication: false,
//                                           chosenEncryption: .none,
//                                           password: "")
//
//        CoreDataManagerWithSpotlight.shared.addAndSaveToCoreDataAndSpotlight(new: testNetwork, to: &wifiNetworks,in: context)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Avendo comunicato all'applicazione che la barra è nascosta
        super.viewDidAppear(true)
        //prima che la view appaia facciamo si che la barra venga mostrata
        isStatusBarHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
}

//MARK: GESTIONE DELLA STATUS BAR

extension NetworkListViewController {
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        //la barra segue le nostre imposizioni
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        //tipo di animazione per apparizione sparizione della barra
        return .fade
    }
}

//NAVIGAZIONE

extension NetworkListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNetworkDetail" {
            if let destination = segue.destination as? NetworkDetailViewController {
                //modifichiamo la var
                isStatusBarHidden = true
                //animiamo la sparizione della status bar
                UIView.animate(withDuration: 0.5, animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            }
        }
    }
}

//TABLE VIEW DELEGATE E DATA SOURCE

extension NetworkListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiNetworks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkListCell", for: indexPath) as! NetworkListTableViewCell
        
        let network = wifiNetworks[indexPath.row]
        
    
        cell.backgroundColor = .clear
        
        cell.networkSsidLabel.text = network.ssid
        
        cell.networkProtectionLabel.text = network.chosenEncryption
        
        cell.networkIsHiddenLabel.text = network.visibility
        
        guard let qrCode = QRManager.shared.generateQRCode(from: network.wifiQRString) else {return cell}
        
        print("ImmagineQRCreataPerCella")
        cell.qrcodeImageView.image = qrCode
        
        return cell
        
    }
    
    
}

extension NetworkListViewController {
    
    func fetchData() {
        self.context.performAndWait{ () -> Void in
            let allNetworks = NSManagedObject.findAllForEntity("WiFiNetwork", context: self.context)
            print(allNetworks)
            if (allNetworks?.last != nil) {
                self.wifiNetwork = (allNetworks?.last as! WiFiNetwork)
                wifiNetworks.append(self.wifiNetwork!)
            }
            else {
                print("nessuna rete")
            }
            print(allNetworks!.count)
            //self.wifiNetworks = allNetworks as! [WiFiNetwork]
            print(wifiNetworks.count)
        }
    }
    
    
}

