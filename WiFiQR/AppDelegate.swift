//
//  AppDelegate.swift
//  ShowWifiList
//
//  Created by riccardo silvi on 15/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit
import NetworkExtension
import CoreData
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Variabili globali
    
    var window: UIWindow?
    
   //CoreDataStorage definisce al suo interno lo sharedContainer, quando viene richiesta si ottiene l'accesso al context

    lazy var persistentContainer : NSManagedObjectContext = CoreDataStorage.mainQueueContext()
    
    //MARK: - Metodo Lancio Avvio App
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        //Temporarily disable constraints warning
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        //Status bar appearance in Plist
        loadData()
        
        return true
    }
    
    func loadData() {
        
        persistentContainer.performAndWait{ () -> Void in
            
            let networks = WiFiNetwork.findAllForEntity("WiFiNetwork", context: persistentContainer)
            
            if (networks?.last != nil) {
                print("networks Found, Shared Container Loaded")
                CoreDataManagerWithSpotlight.shared.storage = networks as! [WiFiNetwork]
                
            }
            else {
                
                print("empty array")
                CoreDataManagerWithSpotlight.shared.addTestEntities()
            }
            
            
        }
    }
    
    //MARK: - Metodo gestione 3DTouchQuickActions
    
    //*** MODIFICA 3D TOUCH ***\\
    // questo metodo scatta quando viene premuto un pulsante nel menù del 3D Touch chè è uscito premendo con forza l'icona dell'App
     func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        debugPrint("Chiamato")
        // il metodo ci porta in dono la var shortcutItem che contiene le chiavi, quindi possiamo fare uno switch
        switch shortcutItem.type {
            //azione add
        case "com.RiccardoSilvi.WiFiQr.add":
            
            switchTabToIndex(2)
            
            //azione shoot
        case "com.RiccardoSilvi.WiFiQr.shoot":
        
                    switchTabToIndex(0)


        default: break
        }
        completionHandler(true)

    }
    
    //MARK: - MetodI SPOTLIGHT
    
    //***** principale metodo invocato da Spotlight*****//
    //scatta quando l'utente tocca un risultato della ricerca proveniente dalla nostra App
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Swift.Void) -> Bool {
        
        // estraiamo l'identificatiore dell'attività
        guard let usrInf = userActivity.userInfo else { return false }
        
        var nomeAct = usrInf["kCSSearchableItemActivityIdentifier"] as! String
        // tagliamo la parte iniziale dell'identifier
        nomeAct = nomeAct.replacingOccurrences(of: "WiFiList.", with: "")
        
        print("--------")
        print("")
        print("Continue Activity: " + nomeAct)
        print("")
        print("--------")
        
        //Raggiungiamo la lista delle reti
        
        let tabBarController = self.window?.rootViewController as? UITabBarController
        
        let controllers = tabBarController?.viewControllers
        
        switchTabToIndex(1)
        
        let navigationController = controllers![1] as! UINavigationController
        
        if let networkListVC = navigationController.visibleViewController as? NetworkListViewController {
            print("listVC da Spotlight")
            // creiamo un contatore per sapere a che indice dell'array sta la ricetta
            var contatore = 0
            // clicliamo (for) dentro l'array delle ricette...
            for reteWiFi in CoreDataManagerWithSpotlight.shared.storage {
                // controlliamo se il nome della ricetta corrisponde al risultato toccato dall'utente
                if reteWiFi.ssid == nomeAct {
                    // se corrisponde invochiamo il metodo showDetailFromSpotlightSearch() di ListController e gli passiamo il valore del contatore
                    // guarda cosa fa quel metodo per maggiori info
                    networkListVC.showDetailFromSpotlightSearch(contatore)
                    // arrestiamo il ciclo for
                    break
                }
                // se il nome non corrisponde incrementiamo il contatore
                contatore += 1
            }
            
        }

        return true
    }
    
    // altri metodi di Spotlight
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        
        if (error as NSError).code != NSUserCancelledError {
            
            let message = "The connection to your other device may have been interrupted. Please try again. \(error.localizedDescription)"
            print("--------")
            print("")
            print(message)
            print("")
            print("--------")
        }
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        
        if let titolo = userActivity.title {
            print("--------")
            print("")
            print("Update Activity: \(titolo)")
            print("")
            print("--------")
        }
    }
    


    //MARK: - Metodi Apertura App da URL (widget, apri con)
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        if url.scheme == "shootwithwifi"
        {
            //TODO: Write your code here
       
        }
        return true
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.absoluteString.contains(".png") || url.absoluteString.contains(".PNG") || url.absoluteString.contains(".jpg") || url.absoluteString.contains(".jpeg") || url.absoluteString.contains(".JPG") || url.absoluteString.contains(".JPEG") {
            
            //ricaviamo l'url completo dell'immagine PNG o JPG ricevuta
            let filePathAbsolute = url.absoluteURL//URL
            
            //ricaviamo la versione stringa dell'url
            let filePath = url.absoluteString//String
            print("\nfilePath", filePath)
            
            //creiamo percorso per verifica esistenza
            let filePathXVerifica = String(filePath.dropFirst(7))/*rimuoviamo file:/// */
            print("filePathXVerifica", filePathXVerifica)
            
            //procediamo alla verifica e alla creazione di una nuova istanza di WiFiNetwork
            
            if FileManager.default.fileExists(atPath: filePathXVerifica) {
                print("path esiste")
                if let data = try? Data(contentsOf: filePathAbsolute){
                    
                    print("conversione a dati ok!!!!")
                    
                    guard let importedImage = UIImage(data: data) else {return true}
                    
                    let checkedString = QRManager.shared.esaminaSeImmagineContieneWiFiQR(importedImage)
                    
                    if checkedString != "NoWiFiString" {
                        
                        print("Inizio Importazione")
                        
                        let params = QRManager.shared.decodificaStringaQRValidaARisultatixUI(stringaInputQR: checkedString)
                        
                        let newNetwork = CoreDataManagerWithSpotlight.shared.createNewNetworkFromParameters(params)
                        
                        CoreDataManagerWithSpotlight.shared.storage.append(newNetwork)
                        
                        
                        CoreDataManagerWithSpotlight.shared.indexInSpotlight(wifiNetwork: newNetwork)
                        
                        //Raggiungiamo la lista delle reti
                    
                        switchTabToIndex(1)
                        print("Switched to first Tab")

                        debugPrint("NetworkListReloadingTable")
                        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
                        
                    }
            
                }
            }
        } else if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false){
                // lavoriamo l'url per estrarre il valore passato alla query

            if let queryItems = urlComponents.queryItems {
                
                debugPrint(queryItems)
                    
                    for queryItem in queryItems {
                        
                        if queryItem.name == "q" {
                            
                            if let value = queryItem.value {
                                
                                self.loadData()
                                    //torniamo al List Controller
                                debugPrint("backFromWidgetToNetworkList")
                                switchTabToIndex(1)
                                    
                                    //Se abbiamo passato un indice
                                    if let index = Int(value) {
                                        debugPrint("Netowrk index: \(index)")
                                         (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
                                        delay(0.3) {
                                            //delay necessario per garantire il caricamento della View
                                            //a seguito di lancio app + reloadTable
                                            (CoreDataManagerWithSpotlight.shared.listCont as?  NetworkListViewController)?.showDetailFromWidgetWith(index)
                                        }
                                        
                                        
                                        // fermiamo il ciclo for
                                        break
                                    } else {
                                        switch value {
                                        case "addNetwork" : switchTabToIndex(2)
                                        default: break
                                        }
                                }
                               
                            
                            }
                            
                        }
                    }
                }
        }
        
        return true
    }
    

    //MARK: - Metodi attivita' Background
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Saves changes in the application's managed object context before the application terminates.
        let context = CoreDataStorage.mainQueueContext()
        CoreDataStorage.saveContext(context)
    }
    



    //MARK: - Metodi Personali Navigazione
    
    func switchTabToIndex(_ index : Int ) {
        
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {return}
        
        guard let controllers = tabBarController.viewControllers else { return }
        
        guard let scanCont = controllers.first as? QRScannerViewController else { return }
        
        tabBarController.selectedIndex = index
        
        if index == 0 {
    
            if (self.window?.rootViewController?.presentedViewController as? UIImagePickerController) != nil && UIDevice.current.userInterfaceIdiom == .phone {
            
                debugPrint("UIPicker visible, calling its canceling method to reboot AVCaptureSession")
                
                scanCont.cancelImageOrVideoSelection()
                
            } else if let QrNotRecognizedVC = self.window?.rootViewController?.presentedViewController as? QrCodeNotRecognizedViewController {
                if  !QrNotRecognizedVC.mailControllerIsShowing {
                    print("solo notRecognizedVC")
                    
                } else {
                    print("RecognizedVC con mailVC")
                    self.window!.rootViewController?.dismiss(animated: false, completion: {
                        scanCont.resetUIforNewQrSearch()
                        scanCont.collectionView.invertHiddenAlphaAndUserInteractionStatus()
                        scanCont.findInputDeviceAndDoVideoCaptureSession()
                    })
                }
            }
        }
            self.window!.rootViewController?.dismiss(animated: false, completion: nil )
        }

    
}



