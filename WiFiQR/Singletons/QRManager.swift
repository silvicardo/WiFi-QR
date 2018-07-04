//
//  QRManager.swift
//  WiFiQR
//
//  Created by riccardo silvi on 27/06/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class QRManager {
	
	static let shared = QRManager()
	
    
    
    func creaNuovaReteWiFiDa(immaAcquisita: UIImage) -> WiFiModel? {
    
    //creiamo una Stringa con i contenuti dell'immagine QR
    let stringaDecode =  verificaEgeneraStringaQRda(immaAcquisita: immaAcquisita)
        
    print("Immagine Acquisita e trasformata")
    
    //controlliamo con guardia che la Stringa sia conforme ai nostri parametri di codifica
    guard creaStringaConformeDa(stringaGenerica: stringaDecode) != "NoWiFiString" else {  return nil }
    
        print("E'una stringa conforme")
        
    //altrimenti passiamo la guardia e si procede alla decodifica della stringa sicuri di non ricevere errori
    let stringaDecodeRisultati = decodificaStringaQRValidaARisultatixUI(stringaInputQR: stringaDecode)
    
    
        
    //creazioneQRdaStringa e assegnazione a costante immagine
    //guardia per evitare di far crashare l'app se fallisce l'ottenimento di una immagine QR di nostra fattura
        guard let immaXNuovaReteWifi = generateQRCode(from: stringaDecodeRisultati.0, with: Transforms.x9y9) else {  return nil}
    
    print("pronti a generare istanza di WiFiModel")
        
    return WiFiModel(wifyQRStringa: stringaDecodeRisultati.0, ssid: stringaDecodeRisultati.3[0], ssidNascosto: stringaDecodeRisultati.2, statoSSIDScelto: stringaDecodeRisultati.3[3], richiedeAutenticazione: stringaDecodeRisultati.1, tipoAutenticazioneScelto: stringaDecodeRisultati.3[1], password: stringaDecodeRisultati.3[2], immagineQRFinale: immaXNuovaReteWifi)
        
    }
    
    func creaNuovaReteWiFiDa(stringa: String) -> WiFiModel? {
        
        let stringaControllata = creaStringaConformeDa(stringaGenerica: stringa)
        print("Stringa controllata")
        //controlliamo con guardia che la Stringa sia conforme ai nostri parametri di codifica
        guard stringaControllata != "NoWiFiString" else {  return nil }
        print("Stringa è una rete WiFi")
        //altrimenti passiamo la guardia e si procede alla decodifica della stringa sicuri di non ricevere errori
        let stringaDecodeRisultati = decodificaStringaQRValidaARisultatixUI(stringaInputQR: stringaControllata)
        

        //creazioneQRdaStringa e assegnazione a costante immagine
        //guardia per evitare di far crashare l'app se fallisce l'ottenimento di una immagine QR di nostra fattura
        guard let immaXNuovaReteWifi = generateQRCode(from: stringaDecodeRisultati.0, with: Transforms.x9y9) else {  return nil}
        
        print("pronti a generare istanza di WiFiModel")
        
        return WiFiModel(wifyQRStringa: stringaDecodeRisultati.0, ssid: stringaDecodeRisultati.3[0], ssidNascosto: stringaDecodeRisultati.2, statoSSIDScelto: stringaDecodeRisultati.3[3], richiedeAutenticazione: stringaDecodeRisultati.1, tipoAutenticazioneScelto: stringaDecodeRisultati.3[1], password: stringaDecodeRisultati.3[2], immagineQRFinale: immaXNuovaReteWifi)
        
    }

    func generateQRCode(from string: String,with transform: CGAffineTransform = Transforms.x9y9) -> UIImage?{
        //con scalex e y mirati rendiamo nitida l'immagine per la UI
        //per i detail e add controller e table iniziale ok 9
        
        //accettiamo la stringa da elaborare e la passiamo alla costante interna
        guard let dataInputString = string.data(using: String.Encoding.ascii) else { return nil }
        
        guard let filtro = creaNuovoCIFilter(da: dataInputString) else {return nil}
        
        guard let outputImage : UIImage = generaOutput(da: filtro, con: transform) else { return nil }
        
        return outputImage
    }
    
    func eliminaDuplicati(di storage: [WiFiModel],in arrayStringhe: [String]) -> [String]{
        
        //creazione array risultato
        var arrayFinaleStringhe : [String] = []
        //per indice e valore in array da esaminare
        for (index,stringa) in arrayStringhe.enumerated() {
            checkif(stringa, at: index, hasDuplicatesIn: storage, ifNotThen: {(stringaNonDoppia) in
                arrayFinaleStringhe.append(stringaNonDoppia)
            })
        }
        return arrayFinaleStringhe //array stringhe non duplicate
    }
    
    
    func createQRStringFromParameters(fieldSSID: String, isProtected: Bool = true, isHidden: Bool, AutType: String, password: String) -> String {
        //creiamo una stringa vuota per elaborazione
        var qrStringTemp = ""
        
        print("inizio lavorazione Stringa Temp")
        //aggiungiamo il nome della rete alla stringa
        qrStringTemp.append("WIFI:S:" + fieldSSID + ";")
        
        switch (isHidden,isProtected) {
            
        case (true,true)    :   if AutType == Encryption.wpa_Wpa2 {//WPA
                                        qrStringTemp.append("T:WPA;P:" + password + ";" )
                                    } else {//WEP
                                        qrStringTemp.append("T:" + AutType + ";P:" + password  + ";")
                                    }
                                    qrStringTemp.append("H:true;;")
            
        case (true, false)  :   qrStringTemp.append("H:true;;")
            
        case (false, true)  :   if AutType == Encryption.wpa_Wpa2{
                                        qrStringTemp.append("T:WPA;P:" + password + ";;")
                                    } else {
                                        qrStringTemp.append("T:" + AutType + ";P:" + password + ";;")
                                        }
            
        case (false, false) :   qrStringTemp.append(";")
            
        }
        
        //Stampa in console stringa finita
        print("La stringa completa è : " + qrStringTemp)
        //la passiamo al valore d'uscita
        let qrStringFinale = qrStringTemp
        
        return qrStringFinale
        
    }
    
    ///FUNZIONE DECODIFICA STRINGAQR GENERICA NON CONFORME A SCHEMA DEFAULT
    func creaStringaConformeDa (stringaGenerica : String) -> String {
        
        guard stringaGenerica != "" else {return "NoWiFiString"}
        
        //la stringa che sarà utilizzata come output
        var stringaOutput = ""
       
        //la stringa da manipolare per produrre la stringa conforme al decodificatore standard
        var stringaDaManipolare : [String] = ["WIFI:S:",";T:",";P:",";;"]
        //una NSSString dalla stringa input per manipolazione
        let nssStringaGenerica = NSString(string: stringaGenerica)
        
        print("iniziamo a controllare il contenuto della stringa")
        
        //Definizione delle funzioni interne per le casistiche di decodifica
        
        let routerFastwebFastgate = {
            //CASO ROUTER FASTGATE FASTWEB
            print("Stringa Router Fastweb FastGate Modello: RTV1907VW-D228 o equivalente schema QR")
            var arrayProprietaRete : [String] = nssStringaGenerica.components(separatedBy: ",")
            stringaDaManipolare[1].append("WPA")
            stringaDaManipolare[2].append(arrayProprietaRete[0].replacingOccurrences(of: "Password: ", with: ""))
            stringaDaManipolare[0].append(arrayProprietaRete[1].replacingOccurrences(of: "Nome Rete: ", with: ""))
            stringaOutput = stringaDaManipolare.joined()
        }
        
        let routerTimAdslSmart = {
            //CASO ROUTER TIM ADSL SMART
            print("Stringa Router Tim Smart Modem NMU:771302 o con equivalente schema QR")
            var arrayProprietaRete : [String] = nssStringaGenerica.components(separatedBy: ";")
            stringaDaManipolare[1].append("WPA")
            stringaDaManipolare[2].append(arrayProprietaRete[2].replacingOccurrences(of: "P:", with: ""))
            stringaDaManipolare[0].append(arrayProprietaRete[1].replacingOccurrences(of: "S:", with: ""))
            stringaOutput = stringaDaManipolare.joined()
        }
        
        //controllo e manipolazione effettiva della stringa
        
        switch stringaGenerica {
            
        case let str where str.starts(with: "WIFI:S:") : stringaOutput = stringaGenerica
        
        case let str where str.starts(with: "Password: ") : routerFastwebFastgate()
        
        case let str where str.contains("WIFI:T:WPA;S:") : routerTimAdslSmart()
        
        default: print("Stringa non valida"); stringaOutput = "NoWiFiString"
            
        }
    
        return stringaOutput
    }
    
    ///FUNZIONE DECODIFICA STRINGA QR COMPLETA A PARTI NECESSARIE A COMPILARE LA UI
    ///ottenuta la stringa ne si ottengono i parametri della rete
    func decodificaStringaQRValidaARisultatixUI(stringaInputQR: String) -> (String, Bool, Bool,[String]) {
        
        let nssStringaInput = NSString(string: QRManager.shared.creaStringaConformeDa(stringaGenerica: stringaInputQR))
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
                arrayStringaXUI[1] = Encryption.wpa_Wpa2
            } else {
                arrayStringaXUI[1] = Encryption.wep
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
    
    
    ///FUNZIONE PER DECODIFICA DA UI IMAGE A CONTENUTO TESTUALE CODICE QR
    func verificaEgeneraStringaQRda(immaAcquisita :UIImage) -> String {
        
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let ciImage:CIImage = CIImage(image:immaAcquisita)!
        var qrCodeLink=""
        
        let features = detector.features(in: ciImage)
        for feature in features as! [CIQRCodeFeature] {
            qrCodeLink += feature.messageString!
        }
//        guard qrCodeLink != "" else {print("Impossibile rilevare/leggere QRCode"); return qrCodeLink}
            guard qrCodeLink != "" else { return qrCodeLink}
        print("QRStringaRilevata!!! : \(qrCodeLink)")
        
        return qrCodeLink
    }
    ///verifica se una data immagine ha un QR importabile dall'App
    func esaminaSeImmagineContieneWiFiQR(_ immagine : UIImage) -> String {
        
        //se la decodifica dell'immagine QR genera una stringa diversa da ""
        let stringaGenerica = verificaEgeneraStringaQRda(immaAcquisita: immagine)
        //se la stringa derivata è vuota restituisci falso
        guard stringaGenerica != "" else {return "NoWiFiString"}
        //altrimenti esamina la stringa e se possibile generare una stringa conforme
        let stringaConforme = QRManager.shared.creaStringaConformeDa(stringaGenerica: stringaGenerica)
        if stringaConforme != "NoWiFiString" {
            //restituisci la Stringa WiFi Valida
            return stringaConforme
        } else {//altrimenti resituirà la stringa che la farà scartare
            return "NoWiFiString"
        }
    }
    
    ///estrae immagine da un FetchResult della libreria foto
    /// e verifica se una data immagine ha un QR importabile dall'App
    func checkIfQRStringIn(library image: PHAsset,with requestOptions: PHImageRequestOptions, in viewFrameSize: CGSize )-> String? {
        
        var stringaRisultato = ""
        
        PhotoLibraryManager.shared.converti(image, with: requestOptions, targeting: viewFrameSize) { (image) in
            //Esaminiamo l'immagine e otteniamo una stringa Risultato
            stringaRisultato = self.esaminaSeImmagineContieneWiFiQR(image)
        
            }
    
        return (stringaRisultato != "NoWiFiString" && stringaRisultato != "") ?  stringaRisultato : nil
        
        }
    
  
}



// MARK: - Funzioni a supporto generateQRCode(from string, with tranform) -> UIImage

extension QRManager {
    
    func creaNuovoCIFilter(da inputData: Data) -> CIFilter? {
        
        guard let filtro = CIFilter(name: "CIQRCodeGenerator") else {return nil}
        
        //settiamo i parametri per la trasformazione a CIImage(QrCode)
        //diciamo al generatore :
        //qual'è la stringa da lavorare
        filtro.setValue(inputData, forKey: "inputMessage")
        // quale livello di qualità vogliamo("Q")
        filtro.setValue("Q", forKey: "inputCorrectionLevel")
        
        return filtro
        
    }
    
    func generaOutput(da filtro : CIFilter, con transformParams : CGAffineTransform) -> UIImage? {
        
        //Procedi solo se possibile produrre un output
        
        guard let output = filtro.outputImage?.transformed(by: transformParams)  else {return nil}
        //si crea "CoreImagecontesto" oggetto di CICONTEXT che creerà la CIImage finale
        // Create a new CoreImage context object, all output will be drawn
        // into the surface attached to the OpenGL context 'cglctx'. If 'pixelFormat' is
        // non-null it should be the pixel format object used to create 'cglctx';
        let coreImageContesto:CIContext = CIContext.init(options: nil)
        
        //si produce dal suddetto contesto una CIImage adottando
        //il contenuto e i confini dell'immagine prodotta(output) dal generatore (filtro)
        let cgImageFinale:CGImage = coreImageContesto.createCGImage(output, from: output.extent)!
        
        //creazione della UIImage utilizzabile
        let image:UIImage = UIImage.init(cgImage: cgImageFinale)
        
        return image
    }
}

//MARK: - Funzioni a supporto eliminaDuplicati(di storage: [WiFiModel],in arrayStringhe: [String]) -> [String]

extension QRManager {
    
    func checkif(_ stringa: String, at index: Int, hasDuplicatesIn storage : [WiFiModel], ifNotThen handler: (_ string: String)->Void ){
        // Elenca in console indici e valori
        print("Istanza \(index) = \(stringa)")
        print("Cerchiamo duplicati in Datamanager.shared.storage")
        //sortiamo tutti gli elementi di storage per vedere se la stringa è contenuta in almeno uno di loro
        let results = storage.filter({ $0.wifyQRStringa == stringa })
        //exists riporta false se il risultato del controllo è un array vuoto
        let exists = results.isEmpty == false
        //se exists riporta vero ossia abbiamo un duplicato
        if exists != true {
            //restuiamo la stringa
            print("Istanza \(index) non presente, verrà aggiunta")
            handler(stringa)
        } else {
             //non aggiungiamo all'array
            print("Istanza \(index) presente, non verrà aggiunta")
            
        }
    }
}
