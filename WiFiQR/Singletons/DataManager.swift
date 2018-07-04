//
//  DataManager.swift
//  ShowWifiList
//
//  Created by riccardo silvi on 19/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit

import SystemConfiguration.CaptiveNetwork
import AVFoundation
import NetworkExtension
// senza questi non si può indicizzare i contenuti in Spotlight
import CoreSpotlight
import MobileCoreServices

class DataManager : NSObject {
    
    //Bitbucket Test
    
    // MARK: - Singleton
    
    //singleton
    static let shared = DataManager()
    
    // MARK: - variabili globali
    
    //storage è un array di WiFiModel
    var storage : [WiFiModel] = []
    
    //stringa che incamera il percorso del file
    var filePath : String!
    
    //var  per il listController(per raggiungerlo)
    var listCont : UIViewController?
    
    // var per il Dettaglio (per raggiungerlo)
    var detCont : UIViewController?
    
    //var per QRScannerController(per raggiungerlo)
    var scanCont : UIViewController?
    
    //var per ADDController(per raggiungerlo)
    var addCont : UIViewController?
    
    //contatore accessi al controllerAdd
    var contatoreAccessiAddCont = 0
    
    //stringaDaWidget
    var widgetStringa = ""
    
    // MARK: - Metodi Gestione Dati

    
    ///FUNZIONE PER CARICAMENTO DATI DA PLIST
    func caricaDati() {
        //*** MODIFICA TODAY ***\\
        //va usata la sandbox condivisa per avere i dati nel today
        // per attivare la sandbox condivisa acceso lo switch AppGroup
        //nel pannello Capabilities su entrambi i target
        // premuto il + e aggiunto nome "group.RiccardoSilvi.wifiqr"
        guard let sharedSandbox = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.RiccardoSilvi.wifiqrgroup")?.path else { return }
        //definizione del nome del percorso del file
        filePath = sharedSandbox + "/retiWiFi.plist"
        //controllo esistenza file "retiWiFi.plist"
        //se il file con il suddetto nome esiste alla posizione...
        if FileManager.default.fileExists(atPath: filePath) {
    
            //allora dearchiviamo il contenuto dell'array nello storage
            //storage è uguale a un array di istanze di WiFiModel dearchiviato
            storage = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [WiFiModel]

      } else {
            let reteNonProtettaEsempio = WiFiModel(wifyQRStringa: "WIFI:S:RETE LIBERA CASA;;",
                                        ssid: "RETE LIBERA CASA",
                                        ssidNascosto: false,
                                        statoSSIDScelto: "Visible Network",
                                        richiedeAutenticazione: false,
                                        tipoAutenticazioneScelto: "La rete non è protetta",
                                        password: "",
                                        immagineQRFinale: #imageLiteral(resourceName: "RETELIBERACASA"))

            let reteNascostaProtettaEsempio = WiFiModel(wifyQRStringa: "WIFI:S:WIFINASCOSTAPROTETTA;T:WPA;P:testpassword;H:true;;",
                                                        ssid: "WIFINASCOSTAPROTETTA",
                                                        ssidNascosto: true,
                                                        statoSSIDScelto: "Hidden Network",
                                                        richiedeAutenticazione: true,
                                                        tipoAutenticazioneScelto: Encryption.wpa_Wpa2,
                                                        password: "testpassword",
                                                        immagineQRFinale: #imageLiteral(resourceName: "WIFINASCOSTAPROTETTA"))


            
            //mettiamo la rete esempio nell'array
            storage = [reteNonProtettaEsempio, reteNascostaProtettaEsempio]
            
            
            //salvataggio nel plist
            salvaRetiWiFiInPlist()
            //indicizzazione prime voci esempio in spotlight
            indicizzaElementiIn(storage)
        }
        
    }
   
    
    func getValuesInPlistAt(path: String) -> NSDictionary? {
        
        let dict = NSDictionary(contentsOfFile: path)
        print(dict!)
        return dict
        
    }
    
    ///FUNZIONE PER LA CREAZIONE NUOVA ISTANZA DI WiFiModel
    func nuovaReteWiFi (wifyQRStringa: String, ssid: String, ssidNascosto: Bool,statoSSIDScelto: String, richiedeAutenticazione: Bool, tipoAutenticazioneScelto: String, password: String, immagineQRFinale: UIImage) {
        let nuovaReteWiFiCreata = WiFiModel(wifyQRStringa: wifyQRStringa,
                                            ssid: ssid,
                                            ssidNascosto: ssidNascosto,
                                            statoSSIDScelto:  statoSSIDScelto,
                                            richiedeAutenticazione:  richiedeAutenticazione,
                                            tipoAutenticazioneScelto:  tipoAutenticazioneScelto,
                                            password: password,
                                            immagineQRFinale: immagineQRFinale)
        //la nuova reteWiFiCreata sarà aggiunta all'array delle reti
        storage.append(nuovaReteWiFiCreata)//*** MODIFICA TODAY***\\
        salvaRetiWiFiInPlist()
        //ricarica la table
        
    }
    
    func salvaEdIndicizzaInSpotlightNuovaReteWiFi(da wifi: WiFiModel){
        
        storage.append(wifi)
        
        salvaRetiWiFiInPlist()
        
        indicizza(reteWiFiSpotlight: storage.last!)
    }
    
    
    
    
    ///FUNZIONE PER LA CREAZIONE NUOVA ISTANZA DI WiFiModel e SALVATAGGIO IN ARRAY CUSTOM
    func creaNuovaReteWiFiEMetti(in array: inout [WiFiModel],wifyQRStringa: String, ssid: String, ssidNascosto: Bool,statoSSIDScelto: String, richiedeAutenticazione: Bool, tipoAutenticazioneScelto: String, password: String, immagineQRFinale: UIImage) {
        let nuovaReteWiFiCreata = WiFiModel(wifyQRStringa: wifyQRStringa,
                                            ssid: ssid,
                                            ssidNascosto: ssidNascosto,
                                            statoSSIDScelto:  statoSSIDScelto,
                                            richiedeAutenticazione:  richiedeAutenticazione,
                                            tipoAutenticazioneScelto:  tipoAutenticazioneScelto,
                                            password: password,
                                            immagineQRFinale: immagineQRFinale)
        //la nuova reteWiFiCreata sarà aggiunta all'array delle reti scelto dall'utente
        array.append(nuovaReteWiFiCreata)//*** MODIFICA TODAY***\\
        
        
    }
    
    ///FUNZIONE PER SALVATAGGIO RETE WIFI IN ARRAY PRINCIPALE "storage"
    func salvaRetiWiFiInPlist() {
        //salviamo il contenuto del''array dentro al file
        //l'archiviatore salva un oggetto contenuto in storage in filePath
        NSKeyedArchiver.archiveRootObject(storage, toFile: filePath)
    }
    
    ///FUNZIONE PER IL RECUPERO DELLA CARTELLA DOCUMENTS NELLA SANDBOX
    func cartellaDocuments() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //print(paths[0])
        return paths[0]
    }

}

// MARK: - FUNZIONI PER SPOTLIGHT RETE WIFI

extension DataManager {
    
    ///salvataggio Da Array Sorgente di WiFiModel in "storage" e indicizzazione SPOTLIGHT
    func salvaInStorageEindicizzaInSpotlightNuoveIstanze(da arraySorgente: [WiFiModel]) {
        //per ogni istanza nell'array sorgente
        for reteWiFi in arraySorgente {
            salvaInStorageEindicizzaInSpotlightNuovaIstanza(di: reteWiFi)
        }
    }
    
    ///salvataggio SINGOLA ISTANZA di WiFiModel in "storage" e indicizzazione SPOTLIGHT
    func salvaInStorageEindicizzaInSpotlightNuovaIstanza(di reteWiFi: WiFiModel) {
        
        storage.append(reteWiFi)
        //salvataggio nel plist
        salvaRetiWiFiInPlist()
        //indicizzazione SPOTLIGHT
        indicizza(reteWiFiSpotlight: reteWiFi)
    }
    
    ///metodo per indicizzare una rete per Spotlight
    func indicizza(reteWiFiSpotlight:WiFiModel) {
        // creiamo gli attributi dell'elemento cercabile in Spotlight
        let attributi = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        // diamogli un nome (ovvero il nome della rete)
        attributi.title = reteWiFiSpotlight.ssid
        
        // adesso serve la descrizione,
        //sarà composta da una stringa con i dettagli della rete e un immagineQR
        // prima di tutto creiamo la parte di testo iniziale
        var testoDettaglioRete: String {
            var statusAndAuthentication = "Status: \(reteWiFiSpotlight.statoSSIDScelto), Authentication: \(reteWiFiSpotlight.tipoAutenticazioneScelto),"
            if reteWiFiSpotlight.richiedeAutenticazione {
                statusAndAuthentication += "Password: \(reteWiFiSpotlight.password)"
            }
            return statusAndAuthentication
        }
        //aggiungiamo il QR
        attributi.thumbnailData = UIImageJPEGRepresentation(reteWiFiSpotlight.immagineQRFinale, 0.8)
        
        // aggiungiamo la descrizione
        attributi.contentDescription = testoDettaglioRete
        
        // creiamo la CSSearchableItem
        let item = CSSearchableItem(uniqueIdentifier: "WiFiList." + reteWiFiSpotlight.ssid,
                                    domainIdentifier: "com.RiccardoSilvi",
                                    attributeSet: attributi)
        
        // indicizziamo in Spotlight
        CSSearchableIndex.default().indexSearchableItems([item]) { (error:Error?) -> Void in
            print("rete WiFi indicizzata")
        }
    }
    
    
    ///metodo per indicizzare multiple istanze di WiFiModel per Spotlight
    func indicizzaElementiIn(_ gruppoRetiWiFiSpotlight: [WiFiModel]) {
        
        for rete in gruppoRetiWiFiSpotlight {
            indicizza(reteWiFiSpotlight: rete)
        }
        
    }
    
    /// metodo per eliminate le retiWiFi indicizzate
    func eliminaReteDaSpotlight(_ reteWiFiSpotlight:WiFiModel) {
        // ricostruiamo l'identifier
        let identifier = "WiFiList." + reteWiFiSpotlight.ssid
        // cancelliamo da Spotlight
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { (error) -> Void in
            print("wifi deleted")
        }
    }
    
    ///salva in DataManager.shared.storage tutte le istanze presenti nell'arrayInput
    func salvaTutteLeIstanzeDa(_ arrayFinaleStringhe : [String]) {
        
        //Se l'array di reti non duplicate dal model non è vuoto
        if arrayFinaleStringhe.isEmpty != true {
            print("PROCEDIAMO AD AGGIUNGERE \(arrayFinaleStringhe.count) NUOVE RETI")
            //salviamo in DataManager.shared.storage tutte le istanze
            for stringaNonDoppia in arrayFinaleStringhe {
                //crea istanza di WiFiModel da stringa, salva in Storage e indicizza in Spotlight
                salvaIstanzaQRda(stringaNonDoppia, in: &storage)
            }
            print("pronti a caricare in table")
            
        } else {//se arrayFinale è vuoto non fare nulla e comunica in console
            print("Nessuna rete nuova da aggiungere")
        }
    }
    
    
    func salvaIstanzaQRda(_ stringaConforme: String, in arrayReti: inout [WiFiModel]) {
        
        guard let nuovaReteWiFi =  QRManager.shared.creaNuovaReteWiFiDa(stringa: stringaConforme) else { return }

        //la nuova reteWiFiCreata sarà aggiunta all'array delle reti scelto dall'utente
        arrayReti.append(nuovaReteWiFi)//*** MODIFICA TODAY***\\
        
        //solo se l'array input è "storage"
        if arrayReti == storage {
            salvaRetiWiFiInPlist()
            //*** MODIFICA SPOTLIGHT ***\\
            // indicizziamo in Spotlight
            indicizza(reteWiFiSpotlight:storage.last! )
        }
        
    }
    
    

}

// MARK: - Metodi Network WiFi

extension DataManager {
    ///FUNZIONE PER IL RECUPERO DEL NOME DELLA RETE WIFI,
    ///RICORDA: importare SystemConfiguration.CaptiveNetwork
    func recuperaNomeReteWiFi() -> String? {
        //la var ssid è una stringa vuota
        var ssidReteAttuale: String?
        //se la costante "interfacce" è un array che contiene una lista
        //di tutte le interfacce monitorate al momento da CaptiveNetworkSupport
        if let interfacce = CNCopySupportedInterfaces() as NSArray? {
            //per ogni "interfaccia" in "interfacce"
            for interfaccia in interfacce {
                //se "infoInterfaccia" = un oggetto di CNCopyCurrentNetworkInfo
                //che restituisce le info (Network Info dictionary)
                //del Network per la specifica interfaccia
                if let infoInterfaccia = CNCopyCurrentNetworkInfo(interfaccia as! CFString) as NSDictionary? {
                    //"ssidd" sarà la stringa corrispondente ala chiave di NetworkInfoDictionary per l'SSID (in formato CFString)
                    ssidReteAttuale = infoInterfaccia[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        //rilascia ssid
        return ssidReteAttuale
    }
    
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
    
    ///Funzione per recupero Lista Reti in dizionario e stampa in console
    func mostraListaReti() {
        var elencoRetiDisponibili = "";(CNCopySupportedInterfaces() as? [CFString])?.forEach({ elencoRetiDisponibili = (CNCopyCurrentNetworkInfo($0) as? [String : Any])?[kCNNetworkInfoKeySSID as String] as? String ?? ""})
        print(elencoRetiDisponibili)
    }
    
    ///Chiamata della disconnessione da una rete gestita dall'App
    func disconnect (nomeRete: String){
        
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: nomeRete)
    }
}

// MARK: - Metodi ProgressBar

extension DataManager {
    
    
    ///Data un certo tot foto genera un dizionario con il valore della progressBar
    ///da innescare quando si raggiunge un certo valore per indice di avanzamento
    ///foto esaminate
    func calcoloValoriPercentualiPerProgressBar(da amountOfPhotosInLibrary: Int ) -> [Int:Int] {
        //dato un valore pari all'1% delle foto in libreria
        let IndiceAvanzamento : Int = amountOfPhotosInLibrary / 100
        //dizionaro di valori secondo cui sarà aggiornata la progress bar
        var valoriPerProgress : [Int:Int] = [:]
        //popoliamo il dizionario di
        for rep in 1...100 {
            valoriPerProgress[IndiceAvanzamento * rep] = rep - 1
        }
        //stampa in console i valori del dizionario
        print(valoriPerProgress)
        
        //resituiamo il dizionario di valori
        return valoriPerProgress
        
    }
    ///dati i valori secondo cui la progressBar si aggiorna attua le modifiche visuali
    func aggiorna(_ progressBar : UIProgressView,da requestIndex: Int, secondo valoriProgressBar: [Int:Int]){
        for (nrFotoAttuale, percentuale) in valoriProgressBar{
            if nrFotoAttuale == requestIndex {
                //aggiorniamo la progressBar con la percentuale giusta
                progressBar.progress = Float(percentuale) / 100
            }
        }
        
    }
}
