//
//  CoreDataManagerWithSpotlight.swift
//  WiFiQR
//
//  Created by riccardo silvi on 29/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import NetworkExtension
import CoreSpotlight
import MobileCoreServices


class CoreDataManagerWithSpotlight {
    
    enum Encryptions : String {
        case wpa_wpa2 = "WPA/WPA2"
        case wep = "WEP"
        case none = "NONE"
    }
    
    enum Visibility : String {
        case visible = "VISIBLE"
        case hidden = "HIDDEN"
    }

	
	static let shared = CoreDataManagerWithSpotlight()
    
    //storage è un array di WiFiNetwork
    var storage : [WiFiNetwork] = []
    
    //var  per il listController(per raggiungerlo)
    var listCont : UIViewController?
    
    // var per il Dettaglio (per raggiungerlo)
    var detCont : UIViewController?
    
    //var per QRScannerController(per raggiungerlo)
    var scanCont : UIViewController?
    
    //var per NetworkAdd(per raggiungerlo)
    var addCont : UIViewController?
    
    //varn per NetworkEdit
    var editCont : UIViewController?
    
    var shouldDelete : UIViewController?
    
    var indexToScroll : IndexPath?

}

extension CoreDataManagerWithSpotlight {
    
    func addNetwork(from network: WiFiModel, noDuplicates newWiFiHandler: ((_ wifi: WiFiNetwork) -> ())? = nil ,
                    foundDuplicates duplicateHandler :((_ wifi: WiFiModel) -> ())? = nil) {
        
        if (storage.filter({ $0.ssid ?? "" == network.ssid }).isEmpty) {
            
            let newNetwork = createNewNetwork(from: network)
            
            storage.append(newNetwork)
            
            CoreDataStorage.saveContext(CoreDataStorage.mainQueueContext())
            
            indexInSpotlight(wifiNetwork: newNetwork)
        
            if let newWiFiHandler = newWiFiHandler {
                newWiFiHandler(newNetwork)
            }
            
        } else {
            if let duplicateHandler = duplicateHandler {
                duplicateHandler(network)
            }
        }
        
        
    }
    

    func addTestEntities(){
        //Istanza di test
        let testNetwork = createNewNetwork(in: CoreDataStorage.mainQueueContext(),
                                                                               ssid: loc("TEST_SSID_2"),
                                                                               visibility: .visible,
                                                                               isHidden: false,
                                                                               requiresAuthentication: false,
                                                                               chosenEncryption: .none,
                                                                               password: loc("TEST_PASS_2"))
        
        
        //Istanza di test
        let testNetwork2 = createNewNetwork(in: CoreDataStorage.mainQueueContext(),
                                                                               ssid: loc("TEST_SSID_1"),
                                                                               visibility: .visible,
                                                                               isHidden: false,
                                                                               requiresAuthentication: true,
                                                                               chosenEncryption: .wpa_wpa2,
                                                                               password: loc("TEST_PASS_1"))
        
        
        [testNetwork, testNetwork2].forEach({
            storage.append($0)
            indexInSpotlight(wifiNetwork: $0)
        })

        CoreDataStorage.saveContext(CoreDataStorage.mainQueueContext())
        
    }
    
    func createNewNetworkFromParameters(_ params: (String, Bool, Bool, [String])) -> WiFiNetwork {
        
        let visibility : (_ visibleStatus: String) -> CoreDataManagerWithSpotlight.Visibility = { visibleStatus in
            
            return visibleStatus == Visibility.hidden.rawValue ? Visibility.hidden : Visibility.visible
        }
        
        let chosenAuth : (_ auth: String) -> Encryptions = { auth in
            
            var chosenAuth : Encryptions = Encryptions.none
            
            
            switch auth
            {
            case Encryption.wep:
                chosenAuth = Encryptions.wep;
                print("Wep Network");
            case Encryption.wpa_Wpa2:
                chosenAuth =  Encryptions.wpa_wpa2;
                print("Wpa Network");
            default:
                break
            }
            
            
            return chosenAuth
            
        }
        
        return CoreDataManagerWithSpotlight.shared.createNewNetwork(
            in: CoreDataStorage.mainQueueContext(),
            ssid: params.3[0],
            visibility: visibility(params.3[3]),
            isHidden: params.2,
            requiresAuthentication: params.1,
            chosenEncryption: chosenAuth(params.3[1]),
            password: params.3[2])
        
        
    }
        
    func createNewNetwork(in context : NSManagedObjectContext, ssid: String, visibility: Visibility, isHidden: Bool, requiresAuthentication: Bool, chosenEncryption : Encryptions, password : String  ) -> WiFiNetwork {
        
        let newNetwork = WiFiNetwork(context: context)
        
        newNetwork.ssid = ssid
        newNetwork.visibility = visibility.rawValue
        newNetwork.isHidden = isHidden
        newNetwork.requiresAuthentication = requiresAuthentication
        newNetwork.chosenEncryption = chosenEncryption.rawValue
        newNetwork.password = password
        newNetwork.wifiQRString = getQrStringFrom(fieldSSID: ssid, isProtected: requiresAuthentication, isHidden: isHidden, AutType: chosenEncryption.rawValue, password: password)
        return newNetwork
        
    }
    
    func createNewNetwork(from  network: WiFiModel, in context : NSManagedObjectContext = CoreDataStorage.mainQueueContext()) -> WiFiNetwork {
        
        let newNetwork = WiFiNetwork(context: context)
        
        newNetwork.ssid = network.ssid
        newNetwork.visibility = network.statoSSIDScelto
        newNetwork.isHidden = network.ssidNascosto
        newNetwork.requiresAuthentication = network.richiedeAutenticazione
        newNetwork.chosenEncryption = network.tipoAutenticazioneScelto
        newNetwork.password = network.password
        newNetwork.wifiQRString = network.wifyQRStringa
        return newNetwork
        
    }
    
    
    
}

extension CoreDataManagerWithSpotlight {
    
    func indexInSpotlight(wifiNetwork : WiFiNetwork) {
        
        
        // creiamo gli attributi dell'elemento cercabile in Spotlight
        let attributi = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        // diamogli un nome (ovvero il nome della rete)
        attributi.title = wifiNetwork.ssid
        
        // adesso serve la descrizione,
        //sarà composta da una stringa con i dettagli della rete e un immagineQR
        // prima di tutto creiamo la parte di testo iniziale
        var testoDettaglioRete: String {
            var statusAndAuthentication = "Status: \(wifiNetwork.visibility!), Authentication: \(wifiNetwork.chosenEncryption!),"
            if wifiNetwork.requiresAuthentication {
                statusAndAuthentication += "Password: \(wifiNetwork.password!)"
            }
            return statusAndAuthentication
        }
        //aggiungiamo il QR
        
        if let qrCode = QRManager.shared.generateQRCode(from: wifiNetwork.wifiQRString!) {
        attributi.thumbnailData = qrCode.jpegData(compressionQuality: 0.8)
        }
        
        // aggiungiamo la descrizione
        attributi.contentDescription = testoDettaglioRete
        
        // creiamo la CSSearchableItem
        let item = CSSearchableItem(uniqueIdentifier: "WiFiList." + wifiNetwork.ssid!,
                                    domainIdentifier: "com.RiccardoSilvi",
                                    attributeSet: attributi)
        
        // indicizziamo in Spotlight
        CSSearchableIndex.default().indexSearchableItems([item]) { (error:Error?) -> Void in
            print("rete WiFi indicizzata")
        }    }
    
    func deleteFromSpotlight(wifiNetwork : WiFiNetwork) {
        
        // ricostruiamo l'identifier
        let identifier = "WiFiList." + wifiNetwork.ssid!
        // cancelliamo da Spotlight
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { (error) -> Void in
            print("wifi deleted")
        }
    }
    
    func deleteFromSpotlightBy(ssid : String) {
            // ricostruiamo l'identifier
            let identifier = "WiFiList." + ssid
            // cancelliamo da Spotlight
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier]) { (error) -> Void in
                print("wifi deleted")
        }
    }
    
    func updateItemInSpotlightWith(previous ssid: String, with wifiNetwork : WiFiNetwork ) {
            
                
                if ssid != wifiNetwork.ssid {
                    deleteFromSpotlightBy(ssid: ssid)
                }
                
                indexInSpotlight(wifiNetwork: wifiNetwork)
        }
    
    
}

extension CoreDataManagerWithSpotlight {
    
    func getQrStringFrom(fieldSSID: String, isProtected: Bool = true, isHidden: Bool, AutType: String, password: String) -> String {
        
        var wifiQRStringa = ""
        
        wifiQRStringa += "WIFI:S:\(fieldSSID );"
        
        switch (isHidden,isProtected) {
            
        case (true,true)    :    if AutType == Encryption.wpa_Wpa2{
            wifiQRStringa += "T:WPA;P:\(password);;"
        } else {
            wifiQRStringa += "T:WEP;P:\(password);;"
        }
        wifiQRStringa += "H:true;;"
            
        case (true, false)  :  wifiQRStringa += "H:true;;"
            
        case (false, true)  :   if AutType == Encryption.wpa_Wpa2{
            wifiQRStringa += "T:WPA;P:\(password);;"
        } else {
            wifiQRStringa += "T:WEP;P:\(password);;"
            }
            
        case (false, false) : wifiQRStringa += ";"
            
        }
        
        //Stampa in console stringa finita
        print("La stringa completa è : \(wifiQRStringa)")
        
        return wifiQRStringa
        
    }
    
}


