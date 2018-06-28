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
class WiFiModel: NSObject, NSCoding {
    
    var wifyQRStringa : String
    var ssid : String
    var ssidNascosto : Bool
    var statoSSIDScelto: String
    var richiedeAutenticazione : Bool
    var tipoAutenticazioneScelto : String
    var password : String
    var immagineQRFinale: UIImage

init(wifyQRStringa: String, ssid: String, ssidNascosto: Bool, statoSSIDScelto: String, richiedeAutenticazione: Bool, tipoAutenticazioneScelto: String, password: String, immagineQRFinale: UIImage) {
    self.wifyQRStringa = wifyQRStringa
    self.ssid = ssid
    self.ssidNascosto = ssidNascosto
    self.statoSSIDScelto = statoSSIDScelto
    self.richiedeAutenticazione = richiedeAutenticazione
    self.tipoAutenticazioneScelto = tipoAutenticazioneScelto
    self.password = password
    self.immagineQRFinale = immagineQRFinale
}

internal required init?(coder aDecoder: NSCoder) {
    self.wifyQRStringa = aDecoder.decodeObject(forKey: "wifyQRStringa") as! String
    self.ssid = aDecoder.decodeObject(forKey: "ssid") as! String
    self.ssidNascosto = aDecoder.decodeBool(forKey: "ssidNascosto")
    self.statoSSIDScelto = aDecoder.decodeObject(forKey: "statoSSIDScelto") as! String
    self.richiedeAutenticazione = aDecoder.decodeBool(forKey: "richiedeAutenticazione")
    self.tipoAutenticazioneScelto = aDecoder.decodeObject(forKey: "tipoAutenticazioneScelto") as! String
    self.password = aDecoder.decodeObject(forKey: "password") as! String
    self.immagineQRFinale = UIImage(data: aDecoder.decodeObject(forKey: "immagineQRFinale") as! Data)!
}

func encode(with encoder: NSCoder) {
    encoder.encode(self.wifyQRStringa, forKey: "wifyQRStringa")
    encoder.encode(self.ssid, forKey: "ssid")
    encoder.encode(self.ssidNascosto, forKey: "ssidNascosto")
    encoder.encode(self.statoSSIDScelto, forKey: "statoSSIDScelto")
    encoder.encode(self.richiedeAutenticazione, forKey: "richiedeAutenticazione")
    encoder.encode(self.tipoAutenticazioneScelto, forKey: "tipoAutenticazioneScelto")
    encoder.encode(self.password, forKey: "password")
    encoder.encode(UIImageJPEGRepresentation(self.immagineQRFinale, 0.5), forKey: "immagineQRFinale")
}

}
    

    
    
    
    

