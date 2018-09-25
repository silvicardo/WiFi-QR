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
// senza questi non si può indicizzare i contenuti in Spotlight
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

}

extension CoreDataManagerWithSpotlight {
    

    func addTestEntities(){
        //Istanza di test
        let testNetwork = createNewNetwork(in: CoreDataStorage.mainQueueContext(),
                                                                               ssid: "RETELIBERACASA",
                                                                               visibility: .visible,
                                                                               isHidden: false,
                                                                               requiresAuthentication: false,
                                                                               chosenEncryption: .none,
                                                                               password: "")
        
        
        //Istanza di test
        let testNetwork2 = createNewNetwork(in: CoreDataStorage.mainQueueContext(),
                                                                               ssid: "Infostrada e8t6e5943",
                                                                               visibility: .visible,
                                                                               isHidden: false,
                                                                               requiresAuthentication: true,
                                                                               chosenEncryption: .wpa_wpa2,
                                                                               password: "Californication")
        
        storage.append(testNetwork)
        storage.append(testNetwork2)
        indexInSpotlight(wifiNetwork: testNetwork)
        indexInSpotlight(wifiNetwork: testNetwork2)
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
        newNetwork.wifiQRString = QRManager.shared.createQRStringFromParameters(fieldSSID:  newNetwork.ssid!, isProtected: newNetwork.requiresAuthentication, isHidden: newNetwork.isHidden, AutType: newNetwork.chosenEncryption!, password: newNetwork.password!)
        
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


