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
        // premuto il + e aggiunto nome "group.silvicardo.wifiqr"
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
                                                        tipoAutenticazioneScelto: "WPA/WPA2",
                                                        password: "testpassword",
                                                        immagineQRFinale: #imageLiteral(resourceName: "WIFINASCOSTAPROTETTA"))


            
            //mettiamo la rete esempio nell'array
            storage = [reteNonProtettaEsempio, reteNascostaProtettaEsempio]
            
            
            //salvataggio nel plist
            salvaReteWiFi()
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
        salvaReteWiFi()
        //ricarica la table
        //listCont?.tableView.reloadData()   //*** MODIFICA TODAY***\\
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
        salvaReteWiFi()
        //indicizzazione SPOTLIGHT
        indicizza(reteWiFiSpotlight: reteWiFi)
    }
    
    //***FUNZIONI PER SPOTLIGHT RETE WIFI**//
    
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
    
 
    
    
    
    ///FUNZIONE PER SALVATAGGIO RETE WIFI IN ARRAY PRINCIPALE "storage"
	func salvaReteWiFi() {
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
    
    // MARK: - Metodi QRCode
    
    /**************************************************************************************************/
    /************FUNZIONI RICONOSCIMENTO-LETTURA-DECODIFICA-CREAZIONE QR CODE**************************/
    /**************************************************************************************************/
    
    
    func salvaIstanzaQRdaStringaConforme(_ stringaConforme: String, in arrayReti: inout [WiFiModel]) {
        
        // si procede alla decodifica della stringa sicuri di non ricevere errori
        let StringaDecodeRisultati = DataManager.shared.decodificaStringaQRValidaARisultatixUI(stringaInputQR: stringaConforme)
        //creazioneQRdaStringa e assegnazione a costante immagine
        //guardia per evitare di far crashare l'app se fallisce l'ottenimento di una immagine QR di nostra fattura
        guard let immaXNuovaReteWifi = DataManager.shared.generateQRCodeFromStringV3(from: StringaDecodeRisultati.0, x: 9, y: 9) else {return}
        //OTTENUTA UNA STRINGA E I PARAMETRI NECESSARI A CREARE UNA NUOVA RETE....
        //creazioneNuovaReteWifiDaDatiEstratti, aggiunta all'array scelto
        
        DataManager.shared.creaNuovaReteWiFiEMetti(in: &arrayReti, wifyQRStringa: StringaDecodeRisultati.0, ssid: StringaDecodeRisultati.3[0], ssidNascosto: StringaDecodeRisultati.2, statoSSIDScelto: StringaDecodeRisultati.3[3], richiedeAutenticazione: StringaDecodeRisultati.1, tipoAutenticazioneScelto: StringaDecodeRisultati.3[1], password: StringaDecodeRisultati.3[2], immagineQRFinale: immaXNuovaReteWifi)
        
        //solo se l'array input è "storage"
        if arrayReti == DataManager.shared.storage {
        salvaReteWiFi()
        //*** MODIFICA SPOTLIGHT ***\\
        // indicizziamo in Spotlight
        DataManager.shared.indicizza(reteWiFiSpotlight:DataManager.shared.storage.last! )
        }
        
    }
    
    
    
    ///FUNZIONE PER LA CONVERSIONE DEI PARAMETRI IMMESSI DALL'UTENTE A STRINGA PER CODICE QR
    func createQRStringFromParameters(fieldSSID: String, isProtected: UISwitch, isHidden: UISwitch, AutType: String, password: String) -> String {
        //creiamo una stringa vuota per elaborazione
        var qrStringTemp = ""
        print("inizio lavorazione Stringa Temp")
        //aggiungiamo il nome della rete alla stringa
        qrStringTemp.append("WIFI:S:" + fieldSSID + ";")
        //se la rete è nascosta
        if isHidden.isOn == true {
            //se la rete è nascosta e protetta
            if isProtected.isOn == true {
                //aggiungi tipo autenticazione e password alla stringa
                if AutType == "WPA/WPA2"{//WPA
                    qrStringTemp.append("T:WPA;P:" + password + ";" )
                } else {//WEP
                    qrStringTemp.append("T:" + AutType + ";P:" + password  + ";")
                }
                qrStringTemp.append("H:true;;")
            } else {
                //se la rete è nascosta ma non protetta
                qrStringTemp.append("H:true;;")
            }
        } else {
            //la rete non è nascosta
            //se la rete è protetta
            if isProtected.isOn == true {
                //aggiungi tipo autenticazione e password alla stringa
                if AutType == "WPA/WPA2"{
                    qrStringTemp.append("T:WPA;P:" + password + ";;")
                } else {
                    qrStringTemp.append("T:" + AutType + ";P:" + password + ";;")
                }
            } else {
                //se la rete non è nascosta e non è protetta
                qrStringTemp.append(";")
            }
            
        }
        //Stampa in console stringa finita
        print("La stringa completa è : " + qrStringTemp)
        //la passiamo al valore d'uscita
        let qrStringFinale = qrStringTemp
        
        return qrStringFinale
    }
    ///FUNZIONE PER LA CONVERSIONE DEI PARAMETRI IMMESSI DALL'UTENTE A STRINGA PER CODICE QR NEL WIDGET
    func createQRStringFromWidgetParameters(fieldSSID: String, isHidden: UISwitch, AutType: String, password: String) -> String {
        //creiamo una stringa vuota per elaborazione
        var qrStringTemp = ""
        print("inizio lavorazione Stringa Temp")
        //aggiungiamo il nome della rete alla stringa
        qrStringTemp.append("WIFI:S:" + fieldSSID + ";")
        //la rete è protetta
        //aggiungi tipo autenticazione e password alla stringa
        if AutType == "WPA/WPA2"{//WPA
            qrStringTemp.append("T:WPA;P:" + password + ";" )
        } else {//WEP
            qrStringTemp.append("T:" + AutType + ";P:" + password  + ";")
        }
        //se la rete è nascosta
        if isHidden.isOn == true {
            
                qrStringTemp.append("H:true;;")
            
        } else {//se non è nascosta
            qrStringTemp.append(";")
                }
        
        //Stampa in console stringa finita
        print("La stringa completa è : " + qrStringTemp)
        //la passiamo al valore d'uscita
        let qrStringFinale = qrStringTemp
        
        return qrStringFinale
    }
    
    ///FUNZIONE DECODIFICA STRINGAQR GENERICA NON CONFORME A SCHEMA DEFAULT
    func stringaGenericaAStringaConforme (stringaGenerica : String) -> String {
        var stringaOutput = ""
        //creiamo la stringa da manipolare per produrre la stringa conforme al decodificatore standard
        var stringaDaManipolare : [String] = ["WIFI:S:",";T:",";P:",";;"]
        let nssStringaGenerica = NSString(string: stringaGenerica)
         print("iniziamo a controllare il contenuto della stringa")
        if stringaGenerica.starts(with: "WIFI:S:"){
            stringaOutput = stringaGenerica
        print("questa stringa non è diversa dal solito e verrà passata alla funzione di decodifica classica")
        } else if stringaGenerica.starts(with: "Password: "){
            //CASO ROUTER FASTGATE FASTWEB
            print("Stringa Router Fastweb FastGate Modello: RTV1907VW-D228 o equivalente schema QR")
            var arrayProprietaRete : [String] = nssStringaGenerica.components(separatedBy: ",")
            stringaDaManipolare[1].append("WPA")
            stringaDaManipolare[2].append(arrayProprietaRete[0].replacingOccurrences(of: "Password: ", with: ""))
            stringaDaManipolare[0].append(arrayProprietaRete[1].replacingOccurrences(of: "Nome Rete: ", with: ""))
            stringaOutput = stringaDaManipolare.joined()
        } else if stringaGenerica.contains("WIFI:T:WPA;S:") {
            //CASO ROUTER TIM ADSL SMART
            print("Stringa Router Tim Smart Modem NMU:771302 o con equivalente schema QR")
            var arrayProprietaRete : [String] = nssStringaGenerica.components(separatedBy: ";")
            stringaDaManipolare[1].append("WPA")
            stringaDaManipolare[2].append(arrayProprietaRete[2].replacingOccurrences(of: "P:", with: ""))
            stringaDaManipolare[0].append(arrayProprietaRete[1].replacingOccurrences(of: "S:", with: ""))
            stringaOutput = stringaDaManipolare.joined()
        } else {
            print("questa stringa non è diversa dal solito e verrà passata alla funzione di decofica classica")
             stringaOutput = "NoWiFiString"
        }
      
        return stringaOutput
    }
    
    ///FUNZIONE DECODIFICA STRINGA QR COMPLETA A PARTI NECESSARIE A COMPILARE LA UI
    ///ottenuta la stringa ne si ottengono i parametri della rete
    func decodificaStringaQRValidaARisultatixUI(stringaInputQR: String) -> (String, Bool, Bool,[String]) {
        
        let nssStringaInput = NSString(string: DataManager.shared.stringaGenericaAStringaConforme(stringaGenerica: stringaInputQR))
        //convertiamo la stringa in Nss per maggiori funzionalità
        //let nssStringaInput = NSString(string: stringaInputQR)
        //guardia per controllare che la stringa passata non sia vuota e che sia una stringa conforme
        //NSString(string: nssStringaInput.substring(from: 0)).substring(to: 6) != "WIFI:S:"
        //passata la guardia iniziamo a raccogliere gli elementi che ci interessano
        print("iniziamo a decodificare, è una stringa relativa a una rete wifi")
        //dividiamo e contiamo le proprietà della rete tramite un array di stringhe
        var arrayProprietaRete : [String] = nssStringaInput.components(separatedBy: ";")
        //conteggio a console elementi nell'array per test
        print("l'array è composto da \(arrayProprietaRete.count) elementi")
        //creazione di 2 array con numero componenti statici a contenuto variabile
        //array da dare in pasto alla funzione che crea l'immagine QRCode da salvare
        var arrayStringaQR : [String]  = ["ssid","TipoPass","Password","reteNascosta",";"]
        //array contente i valori della UI nel formato classico di presentazione all'utente
        var arrayStringaXUI : [String] = ["nomeRete","TipoPassword","Password","reteNascosta"]
        //le due var bool per matchare le componenti di WiFiModel
        var reteProtetta : Bool = true
        var reteNascosta : Bool = true
        //copia ssid nella sua parte dell'array, immutati i valori relativi a password e rete nascosta
        arrayStringaQR[0] = String(arrayProprietaRete[0]) + ";"
        //tagliamo arrayProprietàRete solo per riportare il nome della rete pulito
        
        arrayStringaXUI[0] = arrayProprietaRete[0].replacingOccurrences(of: "WIFI:S:", with: "")
        
        print("arrayStringaxUI at 0: " + arrayStringaXUI[0])
        //CONDIZIONE PER ROUTER FASTGATE DI FASTWEB
        //restituisce una stringa di tipo "Password: abcde,NomeRete: FAST..."
        if arrayProprietaRete[1] == "T:WPA" || arrayProprietaRete[1] == "T:WEP"{
            //E' PROTETTA. PASS WEP o WPA
            reteProtetta = true
            arrayStringaQR[1] = String(arrayProprietaRete[1]) + ";"
            arrayStringaQR[2] = String(arrayProprietaRete[2]) + ";"
            if arrayStringaQR[1].contains("WPA"){
                arrayStringaXUI[1] = "WPA/WPA2"
            } else {
                arrayStringaXUI[1] = "WEP"
            }
                arrayStringaXUI[2] = arrayProprietaRete[2].replacingOccurrences(of: "P:", with: "")
            //SE è NASCOSTA
            if arrayProprietaRete[3] == "H:true" {
                //RETE NASCOSTA CON PASS
                reteNascosta = true
                arrayStringaQR[3] = String(arrayProprietaRete[3]) + ";"
                arrayStringaXUI[3] = "Hidden Network"
            } else {//ALTRIMENTI
                //RETE VISIBILE CON PASS
                //RETE VISIBILE
                reteNascosta = false
                arrayStringaQR[3] = ""
                arrayStringaXUI[3] = "Visible Network"}
            
        } else if arrayProprietaRete[1] == "H:true" {
            //RETE NASCOSTA SENZA PASS
            //RETE NASCOSTA
            reteNascosta = true
            arrayStringaQR[3] = String(arrayProprietaRete[1]) + ";"
            arrayStringaXUI[3] = "Hidden Network"
            //NON HA PASS
            reteProtetta = false
            arrayStringaQR[1] = ""; arrayStringaQR[2] = ""
            arrayStringaXUI[1] = "No Password Required"; arrayStringaXUI[2] = ""
        } else {
            //RETE VISIBILE SENZA PASSWORD
            //RETE VISIBILE
            reteNascosta = false
            arrayStringaQR[3] = ""
            arrayStringaXUI[3] = "Visible Network"
            //NON HA PASS
            reteProtetta = false
            arrayStringaQR[1] = ""; arrayStringaQR[2] = ""
            arrayStringaXUI[1] = "No Password Required"; arrayStringaXUI[2] = ""
        }
    
        
        print(arrayStringaQR)
        //STRINGA DECODIFICATA LA RIVERSIAMO NELLA STRINGA COMPLESSIVA FINALE
        let stringaFinale = arrayStringaQR.joined()
        print("StringafinalexFuncQR: ", stringaFinale)
        
        print("StringaFinalexUI:" )
        
        return (stringaFinale, reteProtetta,reteNascosta, arrayStringaXUI)
    }
    
    ///FUNZIONE PER LA CREAZIONE UIIMAGE QR, CON OPZIONE X E Y
    ///con input x e y mirati rendiamo nitida l'immagine per la UI
    ///per i detail e add controller e table iniziale ok 9
    func generateQRCodeFromStringV3(from string: String, x: CGFloat, y:CGFloat) -> UIImage? {
        //accettiamo la stringa da elaborare e la passiamo alla costante interna
        let datoInIngresso = string.data(using: String.Encoding.ascii)
        //condizione per filtro
        if let filtro = CIFilter(name: "CIQRCodeGenerator") {
            //settiamo i parametri per la trasformazione a CIImage(QrCode)
            //diciamo al generatore :
            //qual'è la stringa da lavorare
            filtro.setValue(datoInIngresso, forKey: "inputMessage")
            // quale livello di qualità vogliamo("Q")
            filtro.setValue("Q", forKey: "inputCorrectionLevel")
            //con scalex e y mirati rendiamo nitida l'immagine per la UI
            //per i detail e add controller e table iniziale ok 9
            let parametroTrasformazionexy = CGAffineTransform(scaleX: x, y: y)
            //se è possibile produrre "output"
            //che è un immagine prodotta dal filtro secondo i tre parametri precedenti
            if let output = filtro.outputImage?.transformed(by: parametroTrasformazionexy) {
                //si crea "CoreImagecontesto" oggetto di CICONTEXT che creerà la CIImage finale
                // Create a new CoreImage context object, all output will be drawn
                // into the surface attached to the OpenGL context 'cglctx'. If 'pixelFormat' is
                // non-null it should be the pixel format object used to create 'cglctx';
                let coreImageContesto:CIContext = CIContext.init(options: nil)
                //si produce dal suddetto contesto una CIImage adottando
                //il contenuto e i confini dell'immagine prodotta(output) dal generatore (filtro)
                let cgImageFinale:CGImage = coreImageContesto.createCGImage(output, from: output.extent)!//createCGImage(output, from: output.extent)!
                //creazione della UIImage utilizzabile
                let image:UIImage = UIImage.init(cgImage: cgImageFinale)
                return image
            }
        }
        return nil
    }
    
    ///FUNZIONE PER AVVIO E STOP SESSIONE DI CATTURA AV PER ACQUISIZIONE QR
    func sessionAVStartOrStop (seshAttuale: AVCaptureSession, frameView: UIView) {
        if seshAttuale.isRunning != true {
            seshAttuale.startRunning()
        } else {
            seshAttuale.stopRunning()
        }
        //aggiorna le dimensioni del frame  e adattalo ai bordi dell'oggetto rilevato
        frameView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
    }
    
    ///FUNZIONE PER DECODIFICA DA UI IMAGE A CONTENUTO TESTUALE CODICE QR
    func leggiImmagineQR(immaAcquisita :UIImage) -> String {
        let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let ciImage:CIImage = CIImage(image:immaAcquisita)!
        var qrCodeLink=""
        
        let features=detector.features(in: ciImage)
        for feature in features as! [CIQRCodeFeature] {
            qrCodeLink += feature.messageString!
        }
        
        guard qrCodeLink != "" else {print("Impossibile rilevare/leggere QRCode"); return qrCodeLink}
        
        print("QRStringaRilevata!!! : \(qrCodeLink)")
        
        return qrCodeLink
    }
    
    // MARK: - Metodi Network WiFi
    
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
    
    ///CREA UNA NEHOTSOTCONFIGURATION(DA UN ISTANZA DI WiFiModel o INPUT MANUALE)
    func creazioneConfigDiRete(nomeRete: String, password: String, passwordRichiesta: Bool, tipoPassword: String) -> NEHotspotConfiguration {
        //creo una configurazione vuota
        var myConfig = NEHotspotConfiguration()
        //se il network non ha password
        if passwordRichiesta != true {
            //serve solo il nome della rete
           let hotspostConfig = NEHotspotConfiguration(ssid: nomeRete)
            myConfig = hotspostConfig
        } else if tipoPassword == "WEP"{
            //se la password è di tipo WEP
            let hotspostConfig = NEHotspotConfiguration(ssid: nomeRete, passphrase: password, isWEP: true)
             myConfig = hotspostConfig
        } else {
            //se la password è WPA/WPA2
           let hotspostConfig = NEHotspotConfiguration(ssid: nomeRete, passphrase: password, isWEP: false)
            myConfig = hotspostConfig
        }
        //restituisci la configurazione manipolata
        return myConfig
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
 
    // MARK: - Metodi ProgressBar
    
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
    
    func aggiorna(_ progressBar : UIProgressView,da requestIndex: Int, secondo valoriProgressBar: [Int:Int]){
        for (nrFotoAttuale, percentuale) in valoriProgressBar{
            if nrFotoAttuale == requestIndex {
                //aggiorniamo la progressBar con la percentuale giusta
                progressBar.progress = Float(percentuale) / 100
            }
        }
        
    }
    
}
