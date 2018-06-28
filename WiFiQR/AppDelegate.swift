//
//  AppDelegate.swift
//  ShowWifiList
//
//  Created by riccardo silvi on 15/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit
import NetworkExtension

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Variabili globali
    
    var window: UIWindow?

    //MARK: - Metodo Lancio Avvio App
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //il primo metodo che parte quando scatta l'app. Partirà subito carica dati
        DataManager.shared.caricaDati()
        
        return true
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
            
            tornaAlListControllerE(performSegue: "toAdd")
            
            //azione shoot
        case "com.RiccardoSilvi.WiFiQr.shoot":
            
            tornaAlListControllerE(performSegue: "toQrScanner")
            
        case "com.RiccardoSilvi.WiFiQr.search":
            
            tornaAlListControllerE(performSegue: "fromListToSearch")

        default: break
        }
        completionHandler(true)

    }
    
    //MARK: - MetodI SPOTLIGHT
    
    //***** principale metodo invocato da Spotlight*****//
    //scatta quando l'utente tocca un risultato della ricerca proveniente dalla nostra App
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
        
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
        
        // accediamo al navigation che sta alla radice dell'App
        let navController = self.window?.rootViewController as! UINavigationController
        
        // verifichiamo se il controller visibile è ListController
        if let listController = navController.topViewController as? ListController {
            // creiamo un contatore per sapere a che indice dell'array sta la ricetta
            var contatore = 0
            // clicliamo (for) dentro l'array delle ricette...
            for reteWiFi in DataManager.shared.storage {
                // controlliamo se il nome della ricetta corrisponde al risultato toccato dall'utente
                if reteWiFi.ssid == nomeAct {
                    // se corrisponde invochiamo il metodo showDetailFromSpotlightSearch() di ListController e gli passiamo il valore del contatore
                    // guarda cosa fa quel metodo per maggiori info
                    listController.showDetailFromSpotlightSearch(contatore)
                    // arrestiamo il ciclo for
                    break
                }
                // se il nome non corrisponde incrementiamo il contatore
                contatore += 1
            }
            // se il controller visibile NON è ListController allora controlliamo che sia visibile DettaglioWiFiController
        } else if let reteWiFiDetController = navController.visibleViewController as? DettaglioWifiController {
            // cicliamo come prima
            for reteWiFi in DataManager.shared.storage {
                // controlliamo il nome
                if reteWiFi.ssid == nomeAct {
                    print("--------")
                    print("")
                    print("Trovato")
                    print("")
                    print("--------")
                    // se lo troviamo passiamo la ricetta a DetailController
                    reteWiFiDetController.reteWiFi = reteWiFi
                    // e aggiorniamo l'interfaccia
                    reteWiFiDetController.mostraDatiDellaReteWifi(reteWiFi)
                    // arrestiamo il ciclo
                    break
                }
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
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.absoluteString.contains(".png") || url.absoluteString.contains(".PNG") || url.absoluteString.contains(".jpg") || url.absoluteString.contains(".jpeg") || url.absoluteString.contains(".JPG") || url.absoluteString.contains(".JPEG") {
            
            //ricaviamo l'url completo dell'immagine PNG o JPG ricevuta
            let filePathAbsolute = url.absoluteURL//URL
            
            //ricaviamo la versione stringa dell'url
            let filePath = url.absoluteString//String
            print("\nfilePath", filePath)
            
            //creiamo percorso per verifica esistenza
            let filePathXVerifica = String(filePath.dropFirst(7))/*rimuoviamo file:/// */
            print("filePathXVerifica", filePathXVerifica)
            
            //procediamo alla verifica e alla creazione di una nuova istanza di WiFiModel
            if FileManager.default.fileExists(atPath: filePathXVerifica) {
                print("path esiste")
                if let data = try? Data(contentsOf: filePathAbsolute){
                    
                    print("conversione a dati ok!!!!")
                    
                   guard let miaImmagineAcquisita = UIImage(data: data),
                        let nuovaRete : WiFiModel = QRManager.shared.creaNuovaReteWiFiDa(immaAcquisita: miaImmagineAcquisita) else { return true }
                    
                        DataManager.shared.salvaEdIndicizzaInSpotlightNuovaReteWiFi(da: nuovaRete)
                    
                        (DataManager.shared.listCont as? ListController)?.tableView.reloadData()
                    
                    if let reteWiFiImportata = DataManager.shared.storage.last {
                        //eseguiamo la funzione nel list controller per connettersi
                        //alla configurazione ricavata dalla rete importata con alert connessione singola/permanente
                        if let listCont = DataManager.shared.listCont as? ListController{
                         listCont.connettiAReteWifiConAlert(configRete: DataManager.shared.creazioneConfigDiRete(nomeRete: reteWiFiImportata.ssid, password: reteWiFiImportata.password, passwordRichiesta: reteWiFiImportata.richiedeAutenticazione, tipoPassword: reteWiFiImportata.tipoAutenticazioneScelto))
                        }
                    
                    }
                }
            }
        } else if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false){
                // lavoriamo l'url per estrarre il valore passato alla query

                if let queryItems = urlComponents.queryItems {
                    
                    for queryItem in queryItems {
                        
                        if queryItem.name == "q" {
                            
                            if let value = queryItem.value {
                                
                                //ok abbiamo il valore che è l'indice della rete
                                //TODO: Sistemare navigazione nel caso stiamo editando una rete
                                // accediamo al navigation che sta alla radice dell'App
                                let navController = self.window!.rootViewController as! UINavigationController
                                
                                // controlliamo se il controller visibile è MasterViewController
                                if let masterController = navController.visibleViewController as? ListController {
                                    print("casoListCont")
                                   
                                    masterController.mostraDettaglioConWiFiIndex(Int(value)!)
                                    
                                    // se il controller visibile NON è ListController allora controlliamo che sia visibile DetailViewController
                                } else if let dettaglioController = navController.visibleViewController as? DettaglioWifiController {
                                    print("CasoDetCont")
                                    // invochiamo il metodo appositamente preparato per questo e gli passiamo l'indice della pizza
                                    dettaglioController.aggiornaInterfacciaConIndex(Int(value)!)
                                }else if (navController.visibleViewController as? AddViewController) != nil {
                                    print("casoAdd")
                                    self.window!.rootViewController?.dismiss(animated: false, completion: nil)
                                    if let masterController = navController.topViewController as? ListController {
                                        print("popocheTOP")
                                        masterController.mostraDettaglioConWiFiIndex(Int(value)!)
                                    }
                                } else if let shootController = navController.visibleViewController as? QRScannerController {
                                    print("casoShoot")
                                    shootController.performSegue(withIdentifier: "unwindAListContDaScanOrLibrary", sender: nil)
                                    if let masterController = navController.visibleViewController as? ListController {
                                        print("aggiorna index")
                                        masterController.mostraDettaglioConWiFiIndex(Int(value)!)
                                    }
                                }
                                
                                // fermiamo il ciclo for
                                break
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
    }
    

    //MARK: - Metodi Personali Navigazione
    
    ///WIFIQR-ONLY: Gestisce il Ritorno al ListController e performa il segue desiderato, non prevede passaggioDati
    
    func tornaAlListControllerE(performSegue: String ) {
        
        // accediamo al navigation che sta alla radice dell'App
        let navController = self.window!.rootViewController as! UINavigationController
        
        //Se siamo nel Detail Controller
        if let detController = navController.visibleViewController as? DettaglioWifiController {
            print("casoDetCont")
            //ritorniamo al List Controller
            detController.performSegue(withIdentifier: "unwindAListController", sender: nil)
            //se invece siamo nel QRScannerController
        } else if let shootController = navController.visibleViewController as? QRScannerController {
            print("casoShoot")
            //torna al List Controller
            shootController.performSegue(withIdentifier: "unwindAListContDaScanOrLibrary", sender: nil)
        } else if (navController.visibleViewController as? AddViewController) != nil {
            print("casoAddCont")//mettiamo giù la modal e..
            self.window!.rootViewController?.dismiss(animated: false, completion: nil)
            //se stavamo modificando una rete ci ritroviamo nel DetailController
            if let detController = navController.topViewController as? DettaglioWifiController {
                print("casoDetCont")
                //ritorniamo al List Controller
                detController.performSegue(withIdentifier: "unwindAListController", sender: nil)
            }
                //altrimenti andiamo avanti perchè saremo già nel List Controller
        }
        //se siamo già nel ListController o il passaggio è avvenuto vai all'QRScannerController
        if let masterController = navController.topViewController as? ListController {
            print("OkListController")
            //vai al controller desiderato
            masterController.performSegue(withIdentifier: performSegue, sender: nil)
        }
        
        
    }
    
    
}

//MARK: - ESTENSIONI

