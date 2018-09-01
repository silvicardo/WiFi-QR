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
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
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
            
            default : break
            
            }
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
