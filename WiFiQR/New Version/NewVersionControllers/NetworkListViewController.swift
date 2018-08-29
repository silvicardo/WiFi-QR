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
    
    var isStatusBarHidden : Bool = false
    
    var wifiNetworks : [WiFiNetwork] = []
    var wifiNetwork : WiFiNetwork?
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //FilePath CoreData
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        caricaDati()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Avendo comunicato all'applicazione che la barra è nascosta
        super.viewWillAppear(true)
        
        //COREDATA - Accediamo al containe e ne estraiamo tutte le istanze
        //riempiendo successivamente l'array locale
        do {
            wifiNetworks = try context.fetch(WiFiNetwork.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error) , \(error.userInfo)")
        }
        
        
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
        return wifiNetworks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkListCell", for: indexPath) as! NetworkListTableViewCell
        
        let network = wifiNetworks[indexPath.row]
    
        cell.backgroundColor = .clear
        
        cell.networkSsidLabel.text = network.ssid
        
        cell.networkProtectionLabel.text = network.chosenEncryption
        
        cell.networkIsHiddenLabel.text = network.visibility
        
        guard let qrCode = QRManager.shared.generateQRCode(from: network.wifiQRString!) else {return cell}
        
        print("ImmagineQRCreataPerCella")
        cell.qrcodeImageView.image = qrCode
        
        return cell
        
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
    
    func addTestEntity(){
    
    //Istanza di test
    let testNetwork = CoreDataManagerWithSpotlight.shared.createNewNetwork(in: context,
                                               ssid: "RETELIBERACASA",
                                               visibility: .visible,
                                               isHidden: false,
                                               requiresAuthentication: false,
                                               chosenEncryption: .none,
                                               password: "")
    
        wifiNetworks.append(testNetwork)
        
        salvaDati()
        
        CoreDataManagerWithSpotlight.shared.indexInSpotlight(wifiNetwork: testNetwork)
        
        networksTableView.reloadData()
    }
    
    func salvaDati() {
        //salva le modifiche nel context
        do {
            try context.save()
        } catch  {
            print("Errore durante il salvataggio nel Context, problema: \(error)")
        }
        
        //aggiorniamo la table
        self.networksTableView.reloadData()
    }
    
    func caricaDati(con request: NSFetchRequest<WiFiNetwork> = WiFiNetwork.fetchRequest()) {
        //data la fetchRequest di default o dell'utente
        //che produrrà un array di oggetti risultato
        //di tipo "WiFiNetwork"(la nostra Entity)
        do {
            //l'array delle cose da fare corrisponderà
            //al risultato di tale richiesta
            wifiNetworks =  try context.fetch(request)
        } catch  {
            print("Errore durante il caricamento, problema: \(error)")
        }
        //aggiorniamo la table
        self.networksTableView.reloadData()
    }

}
