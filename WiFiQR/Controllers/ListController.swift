//
//  ListController.swift
//  WIFIQR
//
//  Created by riccardo silvi on 27/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit
import NetworkExtension
// aggiungiamo il delegato UIViewControllerPreviewingDelegate per il 3D Touch
class ListController: UITableViewController, UIViewControllerPreviewingDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
  // MARK: - Variabili
    
    var arrayRetiWiFi : [WiFiModel] = []
    
    var arrayRisultati : [WiFiModel] = []
    
    var reteWiFi : WiFiModel?
    
    //CREAZIONE DEL SEARCH
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Metodi standard del controller
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        //rendiamo raggiungibile questo controller da qualsiasi punto dell'App
        DataManager.shared.listCont = self
        //indicizzazione in spotlight da decommentare solo per aggiornare modifiche multiple
        //DataManager.shared.indicizzaElementiIn(DataManager.shared.storage)
        //popoliamo l'array delle reti
        arrayRetiWiFi = DataManager.shared.storage
        //print(arrayRetiWiFi)
    
        
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
        
        //*******CONFIGURAZIONE SCOPE BAR ********//
        searchController.searchBar.scopeButtonTitles = ["All", "Hidden Network","WPA/WPA2"]
        searchController.searchBar.delegate = self
        
        //*******BARRA DI NAVIGAZIONE********//
        // stile della barra
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        // tinta dei pulsanti nella barra
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //per inserire logo all'interno del titolo. ATTIVARE QUANDO SI HA IL LOGO
        //navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        
        //attiva il tasto edit per il riordino delle celle
		//self.navigationItem.leftBarButtonItem = self.editButtonItem // pulsante edit a sinistra
        //*** MODIFICA 3D TOUCH ***\\
        // controlliamo che il dispositivo abbia il 3D Touch
        if traitCollection.forceTouchCapability == .available {
            // nel caso diciamo al delegato che la è la table ad essere soggetta alla pressione forte
            registerForPreviewing(with: self, sourceView: tableView)
        }
   }
    
//    override func viewWillAppear(_ animated: Bool) {
//        DataManager.shared.caricaDati()
//        //popoliamo l'array delle reti
//        arrayRetiWiFi = DataManager.shared.storage
//        print("Reti trovate \(arrayRetiWiFi.count)")
//    }
    
	// MARK: - Table view data source
	
	// Quante sezioni?
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
    // Quante celle?
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //in base che siamo in modalità search o normale mostriamo i risultati
        
        if staFiltrando() {//vero
            return arrayRisultati.count
        }
            return DataManager.shared.storage.count
        
    }
	
	// Cosa metto nella cella numero ...?
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WiFiCell
		//in base che siamo in modalità search o normale mostriamo i risultati
        let wiFi : WiFiModel
        if staFiltrando() {//vero
        wiFi = arrayRisultati[indexPath.row]
        } else {//falso
            
		wiFi = DataManager.shared.storage[indexPath.row]//estrazione in base al numero della cella classica
            
        }
		cell.lblNomeReteWiFi.text = wiFi.ssid
        cell.lblCrittazionePass.text = wiFi.tipoAutenticazioneScelto
        cell.lblVisibilitaRete.text = wiFi.statoSSIDScelto
        cell.immagineQR.image =  wiFi.immagineQRFinale
		return cell
	}
	
	// Autorizza la modifica delle celle
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true // si
	}
	
    //METODO CONSIGLIATO: tableView(_:editActionsForRowAt:)

//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//    }

//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        <#code#>
//    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if !staFiltrando() {
        
        //conteggio a console network prima dell'azione
        print("Networks existing: \(DataManager.shared.storage.count)")
        //estrazione in base al numero della cella
         let wiFi = DataManager.shared.storage[indexPath.row]
        //***TASTO SHARE
        //si crea l'istanza "shareAction" e ne si definiscono lo stile,  il titolo, e il blocco di codice da eseguire
        let shareAction = UITableViewRowAction( //si crea un istanza di UitableViewRowAction
            style: UITableViewRowActionStyle.normal , //si assegna uno stile
            title: "Share",                            //si assegna un nome
            handler: {(action,indexPath) -> Void in    // codice da eseguire a comando
                let oggetti : [Any] = [ "Sharing to you this Wi-Fi Network. SSID: " + wiFi.ssid, wiFi.immagineQRFinale ] //messaggio da condividere
                    //si crea un instanza di "UIActivityViewController" che:
                    //invierà il testo e anche l'immagine sopra tramite il social prescelto
                    let activityController = UIActivityViewController(activityItems: oggetti, applicationActivities: nil)
                    //si procede a mostrare l'"UIActivityViewController" all'utente
                    self.present(activityController, animated: true, completion: nil)})
        
        //****TASTO "Delete",
        //si crea un istanza di UitableViewRowAction, si assegna uno stile,
        //si assegna un nome e si crea il codice da eseguire alla selezione del comando
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: {(action, indexPath) -> Void in
            // estraggo la rete dall'array
            let reteWiFiDaEliminare = DataManager.shared.storage[indexPath.row]
            // eliminiamo la rete da Spotlight
            DataManager.shared.eliminaReteDaSpotlight(reteWiFiDaEliminare)
            // togliamo l'elemento dall'array
            DataManager.shared.storage.remove(at: indexPath.row)
            DataManager.shared.salvaReteWiFi()
            // gestisce la cancellazione visiva della riga nell'interfaccia
            tableView.deleteRows(at: [indexPath], with: .fade)
            //controllo effettivi elementi rimasti nell'array
            print("Networks remaining: \(DataManager.shared.storage.count)")})
        
        //****TASTO "CONNECT",
        //si crea un istanza di UitableViewRowAction, si assegna uno stile,
        //si assegna un nome e si crea il codice da eseguire alla selezione del comando
        let connectAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Connect", handler: {(action, indexPath) -> Void in
            let wiFi = DataManager.shared.storage[indexPath.row] //estrazione in base al numero della cella
            //creiamo la configurazione hotspost in base alle proprietà della rete e
            //procediamo a connetterci alla rete chiedendo conferma all'utente
            self.connettiAReteWifiConAlert(configRete: DataManager.shared.creazioneConfigDiRete(nomeRete: wiFi.ssid, password: wiFi.password, passwordRichiesta: wiFi.richiedeAutenticazione, tipoPassword: wiFi.tipoAutenticazioneScelto))
            
            })
        //cambio colore bottoni azione "share" e "connect"
        shareAction.backgroundColor = UIColor.purple
        connectAction.backgroundColor = UIColor.orange
        //connectAction.backgroundColor = UIColor.darkText
    
        //restituiamo l'array delle azioni
        return [deleteAction, shareAction,connectAction]
            
        }
        return []
    }
	
	// Autorizza il riordino delle celle
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true // si
	}
	
	// Scatta quando l'utente riordina le celle
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
		DataManager.shared.storage.swapAt(fromIndexPath.row, to.row) // scambiamo gli elementi nell'array
        tableView.reloadData()
	}
    
    
   // MARK: - Navigazione
    
    //vai a scanLibraryController
    @IBAction func bottoneSettings(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "fromListToSearch", sender: nil)
    }
    
    //unwind da QRScannerController
    @IBAction func unwindAListContDaScanOrLibrary(segue:UIStoryboardSegue) { }
    
    //unwind da DettaglioWiFiController????
    @IBAction func unwindAListController(segue:UIStoryboardSegue) { }
   
    //unwind da AddViewController
    @IBAction func unwindFromAddItem(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
           
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DettaglioWifiController
            
                if staFiltrando(){
                    controller.reteWiFi = arrayRisultati[indexPath.row]
                } else {
                controller.reteWiFi = DataManager.shared.storage[indexPath.row]
            }
        }
        
        } else if segue.identifier == "dawidget" {
            //*** MODIFICA TODAY ***\\
            
            // Nello storyboard è stato tirato un filo dalla caramella di ListController al corpo di DetailController
            // questo ha creato un segue manuale che ho chiamato "dawidget"
            // estraiamo dal segue il DetailController
            let controller = segue.destination as! DettaglioWifiController
            // in questo caso è il widget che ha invocato l'App, quindi leggiamo l'Int passato come sender
            // e lo usiamo per passare la rete (istanza di WiFiModel con dentro i dati di una wifi) corretta
            // il downcast as! Int è necessario perchè sender è un AnyObject (è scritto qui sopra, var di prepareForSegue)
            controller.reteWiFi = DataManager.shared.storage[sender as! Int]
           
        }
    }
   
    // aggiungiamo questo metodo per aprire via codice il DetailController
    func mostraDettaglioConWiFiIndex(_ index:Int) {
        if let ultimaReteWiFiInArray = DataManager.shared.storage.last {
        print("Ultimo elemento rilevato nell'Array: \(ultimaReteWiFiInArray.ssid) , conteggio: \(DataManager.shared.storage.count)")
        
        // invochiamo il segue manuale e gli passiamo index come sender (così lo possiamo leggere nel metodo prepareForSegue)
        performSegue(withIdentifier: "dawidget", sender: index)
        }
        
    }
    
    
    // questo metodo serve per aprire il dettaglio (DettaglioWiFiCOntroller) via codice
    // lo usiamo per aprire la ricetta da un rislultato della ricerca di Spotlight inrenete alla nostra App
    // affinche funzioni il controller nello storyboard è stato nominato "visoreRicette" (nella carta di identità, campo Storyboard ID)
    func showDetailFromSpotlightSearch(_ index:Int) {
        // diciamo allo storyboard di caricarci in memoria RicettaController
        let detail = self.storyboard!.instantiateViewController(withIdentifier: "wifidetail") as! DettaglioWifiController
        // in base all'indice passato al metodo in cui siamo (ovvero showDetailFromSpotlightSearch(index:Int) )
        // passiamo a RicettaController la ricetta giusta
        detail.reteWiFi = DataManager.shared.storage[index]
        // apriamo il controller
        navigationController?.pushViewController(detail, animated: false)
    }
    
    //MARK: - Metodi 3DTouch
    
    //*** MODIFICA 3D TOUCH ***\\
    // questo è il metodo del delgato del 3D Touch che serve per capire che cella è stata toccata
    // x dire allo storyboard di caricarci dentro DetailController
    // e x passargli la pizza da mostrare
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        // questo è il modo per capire che cella è stata toccata
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) as? WiFiCell else { return nil }
        
        // qui abbiamo usato una novità di Swift 2, ovvero il guard che permette di fare una var solo se passa un test, altrimenti possiamo usare return per fermare tutto oppure restituire qulcosa di precotto
        
        // questo carica in memoria il controller
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "wifidetail") as? DettaglioWifiController else { return nil }
        
        // gli passiamo la pizza in base alla cella toccata (con forza)
        detailVC.reteWiFi = DataManager.shared.storage[indexPath.row]
        
        // ed anche l'indice della cella
        detailVC.indice = (indexPath as NSIndexPath).row
        
        // diciamo al 3D Touch da dove fare lo zoom (l'effetto)
        previewingContext.sourceRect = cell.frame
        
        // restituiamo il controller pronto da visualizzare
        return detailVC
    }
    
    // secondo metodo del delegato del 3D Touch che apre il controller dalla preview
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
 
    // MARK: - Metodi per la SearchBar
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filtraContenutiInBaseAlTestoCercato(searchController.searchBar.text!, scope: scope)
        
    }
    
    func staFiltrando() -> Bool {
        //se un segmento è selezionato o barraVuota non è vero restituisce true
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!barraVuota() || searchBarScopeIsFiltering)
    }
    
    func barraVuota() -> Bool {
        // restituisce vero se il testo è vuoto o è nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func filtraContenutiInBaseAlTestoCercato(_ testoCercato: String, scope: String = "All") {
        
        arrayRisultati = arrayRetiWiFi.filter({ (rete : WiFiModel) -> Bool in
            //ricerca da effettuare su parametri
            let doesCategoryMatch = (scope == "All" || (rete.statoSSIDScelto == scope) || (rete.tipoAutenticazioneScelto == scope))
            //se la barra è vuota
            if barraVuota() {
                //ricerca solo tra la categoria del segmento toccato
                return doesCategoryMatch
            } else {//se c'è qualcosa
                //restituisci risultato valido tra categoria e stringa digitata
                return doesCategoryMatch && rete.ssid.lowercased().contains(testoCercato.lowercased())
            }
        })
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //quando viene selezionato un categoria diversa nel segmento filtra i contenuti in base ad esso
        filtraContenutiInBaseAlTestoCercato(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    
    
    
    // MARK: - Metodi NEHOTSPOT
    
    //******FUNZIONE PER CONNESSIONE A CONFIGURAZIONE RETE NOTA CON ALERT******/
    //Dato profilo di connessione la funzione permette all'utente di scegliere se:
    //a) si tratta di una connessione singola(la rete non sarà memorizzata in icloud keychain)
    //b) si tratta di una connessione da ricordare(la rete sarà memorizzata in icloud keychain)
    func connettiAReteWifiConAlert(configRete: NEHotspotConfiguration) {
        //creiamo la configurazione hotspost in base alle proprietà della rete
        let hotspotConfig = configRete
        //MOSTRA L'ALERT PER DECIDERE SE CONNETTERSI UNA VOLA SOLA
        let fieldAlert = UIAlertController(title: "TIME TO CHOOSE", message: "Should this be a One Time Connection", preferredStyle: .alert)
        //connetti solo per questa volta
        fieldAlert.addAction( UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            print("solo una volta")
            hotspotConfig.joinOnce = true
            NEHotspotConfigurationManager.shared.apply(hotspotConfig) {[unowned self] (error) in
                if let error = error {
                    self.showError(error: error)
                }
                else {
                    self.showSuccess()
                }
            }
        }) )
        //connetti e memorizza
        fieldAlert.addAction( UIAlertAction(title: "No", style: .default, handler: { (action) in
            print("ricorda la rete")
            hotspotConfig.joinOnce = false
            NEHotspotConfigurationManager.shared.apply(hotspotConfig) {[unowned self] (error) in
                if let error = error {
                    self.showError(error: error)
                }
                else {
                    self.showSuccess()
                }
            }
        }) )
        //mostra alert
        self.present(fieldAlert, animated: true, completion: nil)
    }
    
    
    //Errore durante la connessione (ALERT)
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Darn", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //Connessione riuscita (ALERT)
    func showSuccess() {
        let alert = UIAlertController(title: "", message: "Connected", preferredStyle: .alert)
        let action = UIAlertAction(title: "Cool", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
