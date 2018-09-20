//
//  NetworkListViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import NetworkExtension

class NetworkListViewController: UIViewController {
    
    @IBOutlet weak var networksTableView: UITableView!
    
    
    // MARK: - VARIABILI
    
    let detailSegueId = "toNetworkDetail"
    let editSegueId = "toNetworkEdit"
    let widgetSegueId = "fromWidgetToDetail"
    
    
    let networkCellIdentifier = "networkListCell"
    let textForGenericShare : [String] = ["I'm sending you this QR to access network with ssid:  ", ", password: " ]
    let textForKeepPressedForOptions = "\nKeep the QRCode pressed for two seconds to show import options"
    
    var isStatusBarHidden : Bool = false
    
    
    var wifiNetworks : [WiFiNetwork] = []
    
    var searchResults : [WiFiNetwork] = []
    
    var indexesInMainArray : [Int] = []
    
    var wifiNetwork : WiFiNetwork?
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    let context = CoreDataStorage.mainQueueContext()
    
    //CREAZIONE DEL SEARCH
    let searchController = UISearchController(searchResultsController: nil)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //FilePath CoreData
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        CoreDataManagerWithSpotlight.shared.listCont = self
        
        networksTableView.delegate = self
        networksTableView.dataSource = self
        
        //*******CONFIGURAZIONE BARRA SEARCH********//
        //delegato
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false //obscuresBackgroundDuringPresentation
        //Determines which parent view controller's view should be presented over for presentations of type
        //UIModalPresentationCurrentContext.  If no ancestor view controller has this flag set, then the presenter
        //will be the root view controller.
        definesPresentationContext = true
        // novità iOS 11
        // mettiamo il nostro UISearchController nella nuova var della item del navigation
        navigationItem.searchController = searchController
        // quando scrolliamno NON facciamo sparire la barra di ricerca
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.showsSearchResultsButton = true
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.tintColor = UIColor.white
        

     
        searchController.searchBar.delegate = self
    
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
        
        return  isFiltering() ? searchResults.count : CoreDataManagerWithSpotlight.shared.storage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: networkCellIdentifier , for: indexPath) as! NetworkListTableViewCell
        
        
        let network : WiFiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[indexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[indexPath.row]
        
        cell.wifiNetwork = network //this will serve delegate methods
        
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
        
        cell.delegate = self
    
        return cell
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
}

extension NetworkListViewController : NetworkListTableViewCellDelegate {
    
    func networkListCell(_ cell: NetworkListTableViewCell, didTapShareButton button: DesignableButton, forNetwork wifiNetwork: WiFiNetwork) {
        
        guard let ssid = wifiNetwork.ssid,
            let password = wifiNetwork.password,
            let qr = QRManager.shared.generateQRCode(from: wifiNetwork.wifiQRString!) else { return }
        
        let itemsToShare : [Any] = [textForGenericShare[0] + ssid + textForGenericShare[1] + password , qr]
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
        
        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = button
            popOver.sourceRect = button.bounds
            popOver.permittedArrowDirections = .left
            popOver.backgroundColor = UIColor.lightGray
            
        }
        
    }
    
    func networkListCell(_ cell: NetworkListTableViewCell, didTapConnectButton button: DesignableButton) {
        
        guard let tappedIndexPath = networksTableView.indexPath(for: cell) else { debugPrint("non recognized") ; return }
        
        print("connection requested")
        
        let wiFi : WiFiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[tappedIndexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[tappedIndexPath.row]
        
        guard let ssid = wiFi.ssid,
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
    
    func networkListCell(_ cell: NetworkListTableViewCell, didTapEditButton button: DesignableButton, forNetwork wifiNetwork: WiFiNetwork) {
        guard let tappedIndexPath = networksTableView.indexPath(for: cell) else { debugPrint("non recognized") ; return }
        
        print("connection requested")
        
        performSegue(withIdentifier: editSegueId, sender: tappedIndexPath)
    }
    
    func networkListCell(_ cell: NetworkListTableViewCell, didTapDeleteButton button: DesignableButton, forNetwork wifiNetwork: WiFiNetwork) {
        
        print("deleteRequested")
        
        guard let tappedIndexPath = networksTableView.indexPath(for: cell) else { debugPrint("non recognized") ; return }
        
        let wiFi : WiFiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[tappedIndexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[tappedIndexPath.row]
        
        CoreDataManagerWithSpotlight.shared.deleteFromSpotlightBy(ssid: wiFi.ssid!)
        
        CoreDataStorage.mainQueueContext().delete(wiFi)
        
        CoreDataManagerWithSpotlight.shared.storage.remove(at: isFiltering() ? indexesInMainArray[tappedIndexPath.row] : tappedIndexPath.row)
        
        CoreDataStorage.saveContext(context)
        
        if isFiltering() {
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            
            filtraContenutiInBaseAlTestoCercato(searchController.searchBar.text!, scope: scope)
            
        } else {
            networksTableView.reloadData()
        }
    
    }
    
    func networkListCell(_ cell: NetworkListTableViewCell, didTapShareByMailButton button: DesignableButton, forNetwork wifiNetwork: WiFiNetwork) {
        guard let tappedIndexPath = networksTableView.indexPath(for: cell) else { return }
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
         let wifiToShare : WiFiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[tappedIndexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[tappedIndexPath.row]
        
            guard let ssid = wifiToShare.ssid,
            let password = wifiToShare.password,
            let qr = QRManager.shared.generateQRCode(from: wifiToShare.wifiQRString!),
            let qrData = qr.jpegData(compressionQuality: 1.0) else { return }
        
        let mailController = prepareMFMailComposeViewControllerWith(ssid: ssid, password: password, qrCode: qrData)
        
        present(mailController, animated: true, completion: nil)
    }
    
    func networkListCell(_ cell: NetworkListTableViewCell, didTapShareByMessageButton button: DesignableButton, forNetwork wifiNetwork: WiFiNetwork) {
       
        guard let tappedIndexPath = networksTableView.indexPath(for: cell) else { return }
        
        guard MFMessageComposeViewController.canSendText() else { return }
        
        let wifiToShare : WiFiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[tappedIndexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[tappedIndexPath.row]
        
        guard let ssid = wifiToShare.ssid,
            let password = wifiToShare.password,
            let qr = QRManager.shared.generateQRCode(from: wifiToShare.wifiQRString!),
            let qrData = qr.pngData() else { return }
        
        let smsController = prepareMFMessageComposeViewControllerWith(ssid: ssid, password: password, qrCode: qrData)
        
        present(smsController, animated: true, completion: nil)
        
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
            
        case detailSegueId :
            
            if let destination = segue.destination as? NetworkDetailViewController,
                let indexPath = networksTableView.indexPathForSelectedRow {
                
                 let wifi : WiFiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[indexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[indexPath.row]
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
        case widgetSegueId:
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
            
        case editSegueId :
            guard let destination = segue.destination as? NetworkEditViewController,
                let indexPath = sender as? IndexPath else {return}
            
                destination.wifiNetwork = isFiltering() ? CoreDataManagerWithSpotlight.shared.storage[indexesInMainArray[indexPath.row]] : CoreDataManagerWithSpotlight.shared.storage[indexPath.row]
            
            
        default : break
            
        }
        }
    }

//MARK: MAIL METHODS
extension NetworkListViewController : MFMailComposeViewControllerDelegate {
    
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

extension NetworkListViewController : MFMessageComposeViewControllerDelegate {
    
    
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
        
        
        //If sending sms is not possible proceeds with next statement
        if !MFMessageComposeViewController.canSendText() {
            
            controller.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    
}

extension NetworkListViewController {
    
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

extension NetworkListViewController : UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
    
        filtraContenutiInBaseAlTestoCercato(searchController.searchBar.text!)
        
    }
    
    func isFiltering() -> Bool {
        //se un segmento è selezionato o barraVuota non è vero restituisce true
        
        return searchController.isActive && !isSearchBarEmpty()
    }
    
    func isSearchBarEmpty() -> Bool {
        // restituisce vero se il testo è vuoto o è nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filtraContenutiInBaseAlTestoCercato(_ testoCercato: String, scope: String = "All") {
        
        indexesInMainArray = []
        
        searchResults = CoreDataManagerWithSpotlight.shared.storage.filter({ (rete : WiFiNetwork) -> Bool in
            
            if !isSearchBarEmpty() {
                
                let results : Bool  = rete.ssid!.lowercased().contains(testoCercato.lowercased())
                
                return results
            }
            
            return true
        })
        
        for result in searchResults {
            
            indexesInMainArray.append(CoreDataManagerWithSpotlight.shared.storage.index(of:result)!)
        }
        print(indexesInMainArray)
        networksTableView.reloadData()
    }

    
    
    
    
    
}


//MARK: - COREDATA STACK
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
