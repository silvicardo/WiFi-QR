//
//  WiFiModel.swift
//  ShowWifiList
//
//  Created by riccardo silvi on 19/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//
import UIKit
//*** MODIFICA TODAY ***\\
// per salvare nella sandbox condivisa bisogna aggiungere questo flag se no non riesce a dearchiviare dal file di testo
// il file di testo si chiama retiWiFi.plist ed è quello che usiamo per salvare i dati, definito in DataManager.swift
@objc(WiFiModel)
class WiFiModel: NSObject {
    
    var wifyQRStringa : String
    var ssid : String
    var ssidNascosto : Bool
    var statoSSIDScelto: String
    var richiedeAutenticazione : Bool
    var tipoAutenticazioneScelto : String
    var password : String
    var immagineQRFinale: UIImage
    
    init(wifyQRStringa: String = "", ssid: String = "", ssidNascosto: Bool = false, statoSSIDScelto: String  = "", richiedeAutenticazione: Bool = false, tipoAutenticazioneScelto: String = "", password: String = "", immagineQRFinale: UIImage = UIImage()) {
        self.wifyQRStringa = wifyQRStringa
        self.ssid = ssid
        self.ssidNascosto = ssidNascosto
        self.statoSSIDScelto = statoSSIDScelto
        self.richiedeAutenticazione = richiedeAutenticazione
        self.tipoAutenticazioneScelto = tipoAutenticazioneScelto
        self.password = password
        self.immagineQRFinale = immagineQRFinale
    }
    
    ///to use to create newWifi Object from UI Parameters(User input controllers)
    convenience init(fieldSSID: String, isProtected: Bool = true, isHidden: Bool, AutType: String, password: String) {
    
        self.init(tipoAutenticazioneScelto: Encryption.none)
    
        self.wifyQRStringa += "WIFI:S:\(fieldSSID );"
        
        switch (isHidden,isProtected) {
            
        case (true,true)    :    if AutType == Encryption.wpa_Wpa2{
                                    self.wifyQRStringa += "T:WPA;P:\(password);;"
                                } else {
                                    self.wifyQRStringa += "T:WEP;P:\(password);;"
                                }
                                self.wifyQRStringa += "H:true;;"
            
        case (true, false)  :  self.wifyQRStringa += "H:true;;"
            
        case (false, true)  :   if AutType == Encryption.wpa_Wpa2{
                                    self.wifyQRStringa += "T:WPA;P:\(password);;"
                                } else {
                                    self.wifyQRStringa += "T:WEP;P:\(password);;"
                                }
            
        case (false, false) : self.wifyQRStringa += ";"
            
        }
        
        //Stampa in console stringa finita
        print("La stringa completa è : " + self.wifyQRStringa)
    
        self.configuraDa(stringaControllata: self.wifyQRStringa)
    
    }
    
        
    
    ///new wifiObject from a string, FAILABLE returns nil where it is not a valid input string
    convenience init?(stringaInput: String) {
        
        self.init(tipoAutenticazioneScelto: Encryption.none)
        
        let stringaControllata = generaSePossibileStringaConformeDa(stringaGenerica: stringaInput)
        
        guard stringaControllata != "NoWiFiString" else {  return nil }
        
        self.configuraDa(stringaControllata: stringaControllata)
        
    }
    
    ///new wifiObject from an image, FAILABLE returns nil when obtaining a QR string return NoWiFiString
    convenience init?(immaAcquisita: UIImage) {
        
            self.init(tipoAutenticazioneScelto: Encryption.none)
        
            let stringaDecode =  QRManager.shared.verificaEgeneraStringaQRda(immaAcquisita: immaAcquisita)
            
            let stringaControllata = generaSePossibileStringaConformeDa(stringaGenerica: stringaDecode)
        
            guard stringaControllata != "NoWiFiString" else {  return nil }
        
            self.configuraDa(stringaControllata: stringaControllata)
    }
    
}

///Internal functions supporting convenience inits
extension WiFiModel {
    
    private func generaSePossibileStringaConformeDa(stringaGenerica : String) -> String {
        
        guard stringaGenerica != "" else {return "NoWiFiString"}
        
        //la stringa da manipolare per produrre la stringa conforme al decodificatore standard
        var stringaDaManipolare : [String] = ["WIFI:S:",";T:",";P:",";;"]
        //una NSSString dalla stringa input per manipolazione
        let nssStringaGenerica = NSString(string: stringaGenerica)
        
        print("iniziamo a controllare il contenuto della stringa")
        
        //Definizione delle funzioni interne per le casistiche di decodifica
        
        let routerFastwebFastgate = { () -> String in
            //CASO ROUTER FASTGATE FASTWEB
            print("Stringa Router Fastweb FastGate Modello: RTV1907VW-D228 o equivalente schema QR")
            var arrayProprietaRete : [String] = nssStringaGenerica.components(separatedBy: ",")
            stringaDaManipolare[1].append("WPA")
            stringaDaManipolare[2].append(arrayProprietaRete[0].replacingOccurrences(of: "Password: ", with: ""))
            stringaDaManipolare[0].append(arrayProprietaRete[1].replacingOccurrences(of: "Nome Rete: ", with: ""))
            return stringaDaManipolare.joined()
        }
        
        let routerTimAdslSmart = { () -> String in
            //CASO ROUTER TIM ADSL SMART
            print("Stringa Router Tim Smart Modem NMU:771302 o con equivalente schema QR")
            var arrayProprietaRete : [String] = nssStringaGenerica.components(separatedBy: ";")
            stringaDaManipolare[1].append("WPA")
            stringaDaManipolare[2].append(arrayProprietaRete[2].replacingOccurrences(of: "P:", with: ""))
            stringaDaManipolare[0].append(arrayProprietaRete[1].replacingOccurrences(of: "S:", with: ""))
            return stringaDaManipolare.joined()
        }
        
        //controllo e manipolazione effettiva della stringa
        return { () -> String in
            
            switch stringaGenerica {
                
            case let str where str.starts(with: "WIFI:S:") : return stringaGenerica
                
            case let str where str.starts(with: "Password: ") : return routerFastwebFastgate()
                
            case let str where str.contains("WIFI:T:WPA;S:") : return routerTimAdslSmart()
                
            default: print("Stringa non valida"); return "NoWiFiString"
                
            }
            
            }()
        
    }
    
    private func configuraDa(stringaControllata: String) {
        
        let arrStr = stringaControllata.components(separatedBy: ";")
        
        arrStr.forEach { (strComp) in
            
            if strComp.contains("WIFI:S:") {
                self.ssid = strComp.replacingOccurrences(of: "WIFI:S:", with: "")
            }
            
            if strComp == "T:WPA" || strComp == "T:WEP" {
                self.richiedeAutenticazione = true
                self.tipoAutenticazioneScelto = strComp.contains("WPA") ? Encryption.wpa_Wpa2 : Encryption.wep
            }
            
            if strComp.contains("P:") {
                
                self.password = strComp.replacingOccurrences(of: "P:", with: "")
            }
            
            if self.ssidNascosto == false {
                self.ssidNascosto = ( strComp == "H:true" )
            }
            
            self.statoSSIDScelto = self.ssidNascosto ? "HIDDEN" : "VISIBLE"
        }
        
        self.wifyQRStringa = stringaControllata
        
        self.immagineQRFinale = QRManager.shared.generateQRCode(from: self.wifyQRStringa) ?? UIImage()
    }

}


