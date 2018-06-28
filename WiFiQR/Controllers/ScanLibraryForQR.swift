//
//  ScanLibraryForQR.swift
//  WiFiQR
//
//  Created by riccardo silvi on 24/02/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import Photos
import AudioToolbox

class ScanLibraryForQR: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - Outlets
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var labelContatoreProgresso: UILabel!
    @IBOutlet var labelContatoreImmaginiEsaminate: UILabel!
    @IBOutlet var progressViewImmaginiEsaminate: UIProgressView!
    //@IBOutlet var barButtonEdit: UIBarButtonItem!
    @IBOutlet var viewComandi: UIView!
    @IBOutlet var stackRicerca: UIStackView!
    @IBOutlet var stackAzioniRisultati: UIStackView!
    @IBOutlet var stackAzioniSelezione: UIStackView!
    @IBOutlet var stackAzioneImportaTutti: UIStackView!
    @IBOutlet var bottoneStart: UIButton!

    //MARK: - Variabili
    
    var arrayImmaginiQR : [UIImage] = []
    
    var arrayStringheWiFiOK : [String] = []
    
    //var per abbreviare il codice relativo al singleton
    var dMan = DataManager.shared
    
    //var ponte
    var reteWiFi : WiFiModel?
    
    //array di WiFiModel Temporaneo
    var arrayRetiTrovate : [WiFiModel] = []
    
    //array risultati fetch su PhotoLibrary
    var allPhotos : PHFetchResult<PHAsset>?
    
    //indice ciclo richieste foto
    
    var requestIndex = 0 //partiamo da un indice richieste pari a zero
    
    //i valori con cui aggiorneremo la progressBar
    var valoriPerProgress: [Int:Int] = [:]
    
    //numeroViewsDaPopolare
    
    var indexViews = 0 //partiamo da un indice pari a 0
    
    //totale delle foto rilevate nella libreria
    var amountOfPhotosInLibrary = 0
    
    //per passare la dimensione della view alla lavorazione delle foto della libreria
    var viewFrameSize : CGSize?
    
    //MARK: - Metodi standard del Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

            impostazioneInizialeUI()
    }
}

//MARK: - Metodi CollectionView

extension ScanLibraryForQR {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //restituiremo le istanze di WiFiModel nell'array
        return arrayRetiTrovate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //celle istanze della classe addetta
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScannedCollectionViewCell", for: indexPath) as! ScanLibCollectionViewCell
        //array rete alla posizione....
        let arrayRetiTrovateAtIndex = self.arrayRetiTrovate[indexPath.row]
        //riempi le celle con...
        cell.labelSSID.text = arrayRetiTrovateAtIndex.ssid
        cell.imageWiFiQRCode.image = arrayRetiTrovateAtIndex.immagineQRFinale
        cell.labelAuthentication.text = arrayRetiTrovateAtIndex.tipoAutenticazioneScelto
        cell.labelPassword.text = arrayRetiTrovateAtIndex.password
        //la cella rispetta lo stato dettato dall'editingMode
        cell.isEditing = isEditing
        return cell
    }
    
    //per far funzionare l'editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        //ci assicurariamo che l'animazione avvenga
        super.setEditing(editing, animated: animated)
        self.viewComandi.alpha = 1
        self.stackAzioniRisultati.isHidden = false
        self.stackAzioniSelezione.isHidden = false
        self.stackAzioneImportaTutti.isHidden = true
        self.collectionView.isHidden = false
        self.editButtonItem.tintColor = .clear
        self.editButtonItem.isEnabled = false
        
        //permettiamo selezione multipla di celle
        collectionView.allowsMultipleSelection = editing
        //creiamo una classe ScanLibCollectionViewCell
        //attiviamo la modalità editing
        let indexes = collectionView.indexPathsForVisibleItems
        for index in indexes {
            let cell = collectionView.cellForItem(at: index) as! ScanLibCollectionViewCell
            cell.isEditing = editing
            
        }
        //sistemiamo il segue in modo che non avvenga se siamo in editing mode
        if !editing {
            
            UIView.animate(withDuration: 0.5) {
                self.viewComandi.alpha = 0
                self.stackAzioniRisultati.isHidden = true
                //self.collectionView.isHidden = true
            }
            
        }
        
    }
    
    func aggiornaCollectionView(con arrayWiFiModel: [WiFiModel]) {
        collectionView.performBatchUpdates({
            for _ in arrayWiFiModel {
                let index = IndexPath(row: arrayWiFiModel.count - 1, section: 0)
                collectionView.insertItems(at: [index])
            }
        }, completion: nil)
    }
}

//MARK: - IBActions

extension ScanLibraryForQR {
    
    @IBAction func deleteSelected (){
        if isEditing {
        //recuperiamo la posizione delle celle selezionate per la cancellazione
        if let selected = collectionView.indexPathsForSelectedItems {
            //tramite la funzione map mettiamo in un array i valori degli oggetti di "selected"
            //l'array verrà messo al contrario per cancellare dall'ultimo al primo oggetto
            //così facendo non si rischierà di cancellare oggetti sbagliati
            let items = selected.map{$0.item}.sorted().reversed() //si potrebbe anche mettere row al posto di item
            //per ogni componente dell'array item, togli voce nell'array collectionData
            for item in items {
                self.arrayRetiTrovate.remove(at: item)
            }
            //cancelliamo gli elementi dalla view  a seguito della cancellazione dalla base di dati
            collectionView.deleteItems(at: selected)
            
        }
       }
    }
    
    
    @IBAction func importSelected(_ sender: UIButton) {
        
        //recuperiamo la posizione delle celle selezionate per la cancellazione
        if let selected = collectionView.indexPathsForSelectedItems {
            //tramite la funzione map mettiamo in un array i valori degli oggetti di "selected"
            //l'array verrà messo al contrario per cancellare dall'ultimo al primo oggetto
            //così facendo non si rischierà di cancellare oggetti sbagliati
            let items = selected.map{$0.item}.sorted().reversed() //si potrebbe anche mettere row al posto di item
            //per ogni rispettivo componente nell'array di WiFiModel
            for item in items {
               dMan.salvaInStorageEindicizzaInSpotlightNuovaIstanza(di: arrayRetiTrovate[item])
            }
            //ricarichiamo la table
            (dMan.listCont as? ListController)?.tableView.reloadData()
            //per ogni componente dell'array item, togli voce nell'array collectionData
            for item in items {
                self.arrayRetiTrovate.remove(at: item)
            }
            //cancelliamo gli elementi dalla view  a seguito della cancellazione dalla base di dati
            collectionView.deleteItems(at: selected)
            //Ritorno al List Controller
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func importAll(_ sender: UIButton) {
        //salviamo le istanze presenti nell'array nel Model
        //NOTA: Verifica duplicati già effettuata prima di riempire arrayRetiTrovate
        dMan.salvaInStorageEindicizzaInSpotlightNuoveIstanze(da: arrayRetiTrovate)
        //ricarichiamo la table
        (dMan.listCont as? ListController)?.tableView.reloadData()
        //Ritorno al List Controller
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bottoneIniziaScan(sender: UIButton) {
        
        nascondiTastoInizioRicerca()
        
        resetValoriInterfacciaEDisabilitaBackSuNavigation()
        
        ottieniFotoPerControllo()
        
        //Se il totale foto è un valore valido ed è maggiore di zero
        if let tutteLeFoto = allPhotos, tutteLeFoto.count > 0 {
            
            //passiamo alla var globale
            amountOfPhotosInLibrary = tutteLeFoto.count
            
            //Comunichiamo all'utente la quantità totale di foto trovate
            self.labelContatoreImmaginiEsaminate.text = "We can look on \(tutteLeFoto.count) photos in your library"
            
            //e calcoliamo i valori con cui aggiorneremo la progressBar
            valoriPerProgress = dMan.calcoloValoriPercentualiPerProgressBar(da: amountOfPhotosInLibrary)
            
            //In un THREAD SECONDARIO eseguiamo il ciclo di ricerca QR-VALIDI
            DispatchQueue.global(qos: .background).async {
                //CICLO WHILE
                //cicla finchè l'indice della foto in esame è inferiore del totale foto presenti
                self.controllaSeTroviWiFiQRIn(tutteLeFoto)
                //FINITO IL CICLO WHILE
                //ESEGUIAMO LE OPERAZIONI FINALI
                DispatchQueue.main.async {//NEL MAIN THREAD
                    //se l'arrayGenerato non è vuoto
                    self.arrayStringheWiFiOK.isEmpty != true ? self.controllaIstanzeDuplicateEaggiornaCollectionView() : print("Nessuna nuova rete da importare!")
                    //aggiorniamo e riattiviamo la view e il back sul controller
                    self.aggiornaViewPerTermineRicercaQR(); self.riattivaViewEBackSulNavigation()
                }//SI CHIUDE IL LAVORO NEL MAIN THREAD
            }//SI CHIUDE IL LAVORO DEL THREAD SECONDARIO
        } else  {//se la libreriaFoto è VUOTA
            //riattiviamo la view e il back sul controller
            riattivaViewEBackSulNavigation()
            print("Libreria Foto Vuota, Nessuna nuova rete da importare!")
        }
    }
}
    
//MARK: - Metodi recupero foto da libreria

extension ScanLibraryForQR {
    
    ///definiamo le opzioni di Fetch delle foto in Libreria e
    ///otteniamo il totale delle foto ordinate dalla più recente alla più vecchia
    func ottieniFotoPerControllo(){
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
    }
    
    ///Con ciclo while controlla cerca tra le foto codici QR
    ///e nel MAIN THREAD aggiorna la view per tenere informato l'utente del progresso
    func controllaSeTroviWiFiQRIn(_ tutteLeFoto: PHFetchResult<PHAsset>){
        
        //CICLO WHILE
        //finchè l'indice della foto in esame è inferiore di 1 del totale foto presenti
        while self.requestIndex < self.amountOfPhotosInLibrary {
            //CODICE SPECIALE per rilascio memoria ad ogni esecuzione del while loop
            autoreleasepool{
                //settiamo le opzioni di esecuzione della richiesta immagine da library
                //con sincrona otteniamo solo la thumbnail
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                //estraiamo all'indice "requestIndex" il fetchResult come PHAsset
                let photoAssetDaEsaminare = tutteLeFoto.object(at: self.requestIndex)
                //per ottenerne l'immagine e controllare la validità come qr
                self.controllaValidita(per: photoAssetDaEsaminare, requestOptions: requestOptions)
                //aumentiamo l'indice Richiesta
                self.requestIndex += 1
            }
            //AGGIORNIAMO LA VIEW NEL THREAD PRINCIPALE
            DispatchQueue.main.async {
                self.labelContatoreImmaginiEsaminate.text = "Looking Photo \(self.requestIndex) of \(self.amountOfPhotosInLibrary)"
                self.dMan.aggiorna(self.progressViewImmaginiEsaminate, da: self.requestIndex, secondo:self.valoriPerProgress )
            }
            //si ripassa all'inizio del CICLO WHILE
        }
    }
    

    ///estrae immagine da un FetchResult della libreria foto
    /// e verifica se una data immagine ha un QR importabile dall'App
    func controllaValidita(per fetchResult: PHAsset, requestOptions: PHImageRequestOptions ) {
        
        // Esegue la image request una volta
        PHImageManager.default().requestImage(for: fetchResult, targetSize: self.viewFrameSize!, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            //se abbiamo un immagine valida
            if image != nil {
                print("Request \(self.requestIndex) OK!!!")
                //Esaminiamo l'immagine e otteniamo una stringa Risultato
                let stringaControllata = QRManager.shared.esaminaSeImmagineContieneWiFiQR(image!)
                //se l'esame dell'immagine conferma che è una stringa leggibile dal programma
                //e non è un duplicato di altri valori in arrayStringhe
                if stringaControllata != "NoWiFiString", self.arrayStringheWiFiOK.contains(stringaControllata) != true {
                    //aggiungi la Stringa all'array di Stringhe
                    self.arrayStringheWiFiOK.append(stringaControllata)
                    //comunichiamo in console il successo
                    print("TrovatoQR a: \(self.requestIndex) e controllato se duplicato")
                }
            }})
    }
 
}

    
//MARK: Metodi relativi aggiornamento componenti Interfaccia

extension ScanLibraryForQR {
    
    func impostazioneInizialeUI() {
        
        //popoliamo l'array delle view con tutte le view presenti nelle stack
        
        //azzeriamo la barra progresso
        progressViewImmaginiEsaminate.progress = 0.0
        //Comunichiamo all'utente che siamo pronti
        labelContatoreImmaginiEsaminate.text = "Ready To Scan"
        viewFrameSize = view.frame.size
        //disabilitiamo il bottone edit da mostrare solamente quando
        //si saranno ottenuti i risultati della ricerca
        //mostriamo la stackRicerca e nascondiamo la stackAzioniRisultati
        stackRicerca.isHidden = false
        stackAzioniRisultati.isHidden = true
        stackAzioniSelezione.isHidden = true
        //SCELTA QUANTITà DI COLONNE PER LE CELLE DELLA COLLECTION
        //per ottenere delle celle uniformemente presentate per tot colonne indipendemente dai dispositivi
        //1.otteniamo la larghezza della view meno gli spazi tra le celle (2 celle quindi di spazi da 10 quindi 20) + spazi della collection dal lato della view diviso le colonne desiderate(2)
        let width = (view.frame.size.width - 40) / 2
        //2. otteniamo l'accesso all'item size property
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        //3.e la modifichiamo
        layout.itemSize = CGSize(width: width, height: width)
        //e nascondiamo la toolbar fino alla fine della ricerca
        
        //disattiviamo il tasto Edit
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.tintColor = .clear
        
        //disattiviamo l'interattivita' del tocco della cella
    }
    
    func controllaIstanzeDuplicateEaggiornaCollectionView() {
        
        //Rimuoviamo i duplicati interni all'array risultato e comunichiamo le istanze rimanenti
        
        self.arrayStringheWiFiOK = self.arrayStringheWiFiOK.removeDuplicates() //TODO: Probabile riga inutile
        print("Istanze in arrayFotoDaLibreria \(self.arrayStringheWiFiOK.count)")

        //creiamo l'array vuoto per la scrematura definitiva
        //depositiamo in arrayFinale solo istanze che non siano già presenti nel Model
//        let arrayFinaleStringhe : [String] = self.dMan.eliminaDuplicati(di: self.dMan.storage, in: self.arrayStringheWiFiOK)
        let arrayFinaleStringhe : [String] = QRManager.shared.eliminaDuplicati(di: self.dMan.storage, in: self.arrayStringheWiFiOK)
        //per ogni stringa nell'arrayFinale
        for stringaConforme in arrayFinaleStringhe {
            //salviamo nell'[WiFiModel] tutte le istanze ricavate dalla stringa
            self.dMan.salvaIstanzaQRda(stringaConforme, in: &self.arrayRetiTrovate)
        }
        //e ci aggiorniamo la collectionView
        self.aggiornaCollectionView(con: self.arrayRetiTrovate)
    }
    
    func aggiornaViewPerTermineRicercaQR() {
        //mostriamo la toolbar alla fine della ricerca
        navigationController?.isToolbarHidden = true
        editButtonItem.tintColor = .white
        //la barra progresso sarà piena
        self.progressViewImmaginiEsaminate.progress = 1.00
        //aggiorniamo la label che comunica la fine del Ciclo
        self.labelContatoreImmaginiEsaminate.text = "Done , Found \(self.arrayStringheWiFiOK.count) Valid QR-Codes in \(self.amountOfPhotosInLibrary) Photos"
        //segnaliamo in console  il successo del ciclo
        print("Tutte le immagini esaminate")
        //azzeriamo i contatori
        self.indexViews = 0
        self.requestIndex = 0
        delay(2) {
            //modifichiamo la dimensione della view con animazione
            UIView.animate(withDuration: 0.5, animations: {
            self.stackRicerca.alpha = 0
            self.stackRicerca.isHidden = true
            self.stackAzioniRisultati.isHidden = false
            })
        }
    }

    func nascondiTastoInizioRicerca(){
        UIView.animate(withDuration: 0.2, animations: {
            
            self.bottoneStart.backgroundColor = .black
        })
        
        UIView.animate(withDuration: 1.0) {
            
            self.bottoneStart.isHidden = true
    
        }
    }
    
    func aggiornaTableDiListController(per nrRetiAggiunte: Int){
        
        (dMan.listCont as? ListController)?.tableView.reloadData()
        //e notifica in console
        print("AGGIUNTE CON SUCCESSO \(nrRetiAggiunte) NUOVE RETI")
        
    }
    
    func resetValoriInterfacciaEDisabilitaBackSuNavigation() {
        //azzeriamo il progresso della barra
        self.progressViewImmaginiEsaminate.progress = 0.00
        //disabilitiamo l'indietro sul navigation
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.navigationController?.view.isUserInteractionEnabled = false
        
        //svuotiamo l'array Immagini
        arrayImmaginiQR = []
        
        //aggiorniamo la label per l'inizio del ciclo
        self.labelContatoreImmaginiEsaminate.text = "Loading Photo Library"
    }
    
    func riattivaViewEBackSulNavigation(){
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.navigationController?.view.isUserInteractionEnabled = true
    }
    
}

