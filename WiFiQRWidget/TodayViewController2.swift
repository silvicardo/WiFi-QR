//
//  TodayViewController.swift
//  WiFiQRWidget
//
//  Created by riccardo silvi on 13/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController2: UIViewController, NCWidgetProviding {
   
    // MARK: - Outlets
    
  
    @IBOutlet var labelImmaQRWidg: UIImageView!
    @IBOutlet var labelNomeReteWidg: UILabel!
    @IBOutlet var labelPassReteWidg: UILabel!
    @IBOutlet var bottoneCondividi: UIButton!
    @IBOutlet var stackHoRete: UIStackView!
    @IBOutlet var stackNonHoRete: UIStackView!
    @IBOutlet var labelNuovaPassword: UILabel!
    @IBOutlet var bottoneMaiuscolo: UIButton!
    @IBOutlet weak var lblReteNascosta: UILabel!
    @IBOutlet weak var switchReteNascosta: UISwitch!
    @IBOutlet weak var segContTipoAutenticazione: UISegmentedControl!
    @IBOutlet var viewTastiera: UIView!
    @IBOutlet var bottoneManually: UIButton!
    @IBOutlet var stackTastiera: UIStackView!
    
    // MARK: - Variabili globali
    
    let context = CoreDataStorage.mainQueueContext()
    
    var timer = Timer()
    
    var contatore = 2
    
    var ssidReteAttuale = DataManager.shared.recuperaNomeReteWiFi()
    
    var reteWiFi: WiFiModel?

    
    var indiceIstanza: Int?
    
    var isMaiusc : Bool = false
    
    var tipoAutenticazione : String = Encryption.wep

    
    var altezza : CGFloat?
    // MARK: - Metodi standard del Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                viewTastiera.isHidden = true
        
                //nascondiamo le stack dei bottoni
                stackNonHoRete.isHidden = true
                stackHoRete.isHidden = true
                stackTastiera.isHidden = true
        
            context.performAndWait{ () -> Void in
                
                let networks = WiFiNetwork.findAllForEntity("WiFiNetwork", context: context)
                
                if (networks?.last != nil) {
                    print("networks Found")
                    CoreDataManagerWithSpotlight.shared.storage = networks as! [WiFiNetwork]
                    
                    guard let rete = CoreDataManagerWithSpotlight.shared.storage.first else {return}
                    
                    guard let qr = QRManager.shared.generateQRCode(from: rete.wifiQRString!) else {return}
                    
                    //mettiamo i dati a schermo
                    self.labelNomeReteWidg.text = "Rete: \(rete.ssid!)"
                    self.labelImmaQRWidg.image = qr
                    self.labelPassReteWidg.text = "Password: \(rete.password!)"
//                    //trasmettiamo l'indice della rete rilevata alla nostra var
//                    self.indiceIstanza = DataManager.shared.storage.index(of: rete)
                    //mostriamo la stack dedicata
                    stackHoRete.isHidden = false
                    stackNonHoRete.isHidden = true
                    viewTastiera.isHidden = true
                    stackTastiera.isHidden = true
                    
                }
                else {
                    
                    print("empty array")
                    CoreDataManagerWithSpotlight.shared.addTestEntities()
                }
                
        }
            
    
        
        //*************VERSIONE PLIST**********//
        // facciamo partire il gestore dei dati
//        DataManager.shared.caricaDati()
//        viewTastiera.isHidden = true
//
//        //nascondiamo le stack dei bottoni
//        stackNonHoRete.isHidden = true
//        stackHoRete.isHidden = true
//        stackTastiera.isHidden = true
//        //se viene rilevata una rete a cui si è connessi
//        if ssidReteAttuale != nil {
//            //cicliamo nel nostro elenco in cerca di un match...
//            for rete in DataManager.shared.storage {
//                //se c'è una corrispondenza..
//                if ssidReteAttuale == rete.ssid {
//                    //passiamo alla nostra var la rete trovata in "storage"
//                    reteWiFi = rete
//                    //mettiamo i dati a schermo
//                    self.labelNomeReteWidg.text = "Rete: \(rete.ssid)"
//                    self.labelImmaQRWidg.image = rete.immagineQRFinale
//                    self.labelPassReteWidg.text = "Password: \(rete.password)"
//                    //trasmettiamo l'indice della rete rilevata alla nostra var
//                    self.indiceIstanza = DataManager.shared.storage.index(of: rete)
//                    //mostriamo la stack dedicata
//                    stackHoRete.isHidden = false
//                    stackNonHoRete.isHidden = true
//                    viewTastiera.isHidden = true
//                    stackTastiera.isHidden = true
//
////                    // impostiamo la misura del widget
////                    self.altezza = 110
////                    self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: altezza!)
////                    //lo espandiamo
//                    self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
//                    //interrompiamo il ciclo for
//                    break
//                }
//                else {//se invece non trovo una corrispondenza in "storage"
//                    //lo comunichiamo all'utente e lo invitiamo all'aggiunta
//                    self.labelNomeReteWidg.text = "Connected to \(ssidReteAttuale!)"
//                    self.labelPassReteWidg.text = "not available in database, Add"
//                    //mostriamo la stack dedicata
//                    stackNonHoRete.isHidden = false
//                    stackHoRete.isHidden = true
//                    viewTastiera.isHidden = false
//                    stackTastiera.isHidden = false
//                    // impostiamo la misura del widget
//                    self.altezza = 110
//                    self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: altezza!)
////                    //lo espandiamo
//                    self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
//                }
//            }
//        } else {//se ssidReteAttuale == nil(non siamo connessi a una WiFi)
//            //lo comunichiamo all'utente
//            self.labelNomeReteWidg.text = "Not Connected to Any WiFi"
//            self.labelPassReteWidg.text = ""
//            //mostriamo la stack dedicata
//            stackNonHoRete.isHidden = false
//            stackHoRete.isHidden = true
//        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TODO: Se lasciato vuoto parte compact...
        //impostiamo la misura del widget, va fatto per forza dopo che tutto è stato caricato
        
        if let height = self.altezza {
            //labelPassReteWidg.text = "DiDAPPear rileva altezza"
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: height)
        } else {
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 110)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Dimensioni e Margini Widget
    
    //per l'espansione del widget
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 410)
            viewTastiera.isHidden = false
            bottoneManually.isUserInteractionEnabled = false
            
        } else if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 110)
            viewTastiera.isHidden = true
            bottoneManually.isUserInteractionEnabled = true
        }
        
    }
    
    
    // dice quanto deve essere il margine del nostro widget dai bordi
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // visto che abbiamo una collection view usiamo le sue funzioni per distanziare le celle
        // quindi restituiamo zero margine
        return UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 0)
    }
    
    //MARK: - Aggiornamento Dati Widget
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    //MARK: - IBActions e relative funzioni
    
    @IBAction func bottoneCondividi(_ sender: UIButton) {
        //controllo istanza
        if let retewifiOK = reteWiFi {
        //copia nel pasteboard
        let pasteboard = UIPasteboard.general
        pasteboard.string = "Rete: \(retewifiOK.ssid), Password: \(retewifiOK.password)"
        //Diamo all'utente un feedback
        bottoneCondividi.backgroundColor = UIColor.orange
        labelPassReteWidg.text = "✅Network Data Copied To Clipboard!📝"
        //tramite un timer ripristiniamo dopo 2 secondi lo stato originale degli elementi appena modificati
        //timer per reazione della view
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(funzioneContatoreCondivisione), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func funzioneContatoreCondivisione() {
        //diminuiamo il timer di un unità
        contatore -= 1
        //e se il contatore raggiunge lo 0....
        if contatore == 0 {
            //ripristiniamo gli elementi della view
            labelPassReteWidg.text = "Password: \(reteWiFi!.password)"
            
            bottoneCondividi.backgroundColor = UIColor.red
            //blocchiamo il timer
            timer.invalidate()
            //contatore torna a 2
            contatore = 2
        }
    }
    @IBAction func bottoneApriDettaglio(_ sender: UIButton) {
        //se indice non è vuoto, quindi se è stata trovata una rete
        if let indice = indiceIstanza {
        let indexPath = IndexPath(row: indice, section: 1)
        // per fare in modo che il widget possa aprire la sua App bisogna andare alla radice del progetto, tab Info
        // ed impostare un "URL Types", guarda questo esempio per capire, in un campo ho scritto pizzalist, tutto li
        // quindi adesso quest'App può essere invocata con openUrl e lo schema pizzalist://
        
        // l'url deve essere per forza fatto così wifiqr://?q= , la parte ?q= è importante se no la creazione dell'url fallise
        let url = URL(string: "wifiqr://?q=\(indexPath.row)")// else {return }
        // diciamo all'esxtension di aprire un url, e gli passiamo quello della nostra App
            extensionContext?.open(url!, completionHandler: nil)
        }
    }
    @IBAction func bottoneCameraOrLibrary(_ sender: UIButton) {
        
        //TODO: Sistemare passaggio al QRScannerController
//        let url = URL(string: "shootwithwifiqr://")!
//        self.extensionContext?.open(url, completionHandler: { (success) in
//            if (!success) {
//                print("error: failed to open app from Today Extension")
//            }
//        })
    }
    @IBAction func switchReteNascostaPremuto(_ sender: UISwitch) {
        
        if switchReteNascosta.isOn == true {
            print("Network is Hidden, Switch is on")
            lblReteNascosta.text = "Hidden"
            
        } else {
            //azione
            print("Network is visible, Switch is off")
            lblReteNascosta.text = "Visible"
        }
    }
    @IBAction func indexSegContTipoAutcambiato(_ sender: UISegmentedControl) {
        switch segContTipoAutenticazione.selectedSegmentIndex
        {
        case 0:
            tipoAutenticazione = Encryption.wep;
            print("Wep Segment Selected");
        case 1:
            tipoAutenticazione = Encryption.wpa_Wpa2;
            print("Wpa Segment Selected");
        default:
            break
        }
    }
    @IBAction func bottoneMaiuscolo(_ sender: UIButton) {
        if !isMaiusc {
            bottoneMaiuscolo.backgroundColor = UIColor.red
            isMaiusc = true
        } else {
            bottoneMaiuscolo.backgroundColor = UIColor.gray
            isMaiusc = false
        }
    }
    @IBAction func bottoneCancellaTutto(_ sender: UIButton) {
        
        labelNuovaPassword.text = "Input Password"
    }
    @IBAction func bottoneCancella(_ sender: UIButton) {
        //cancella solo se la stringa non è vuota
        if labelNuovaPassword.text?.isEmpty == false {
        labelNuovaPassword.text?.removeLast()
        }
    }
    @IBAction func bottoneIncolla(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general

        if pasteboard.string?.isEmpty != true {
            self.labelNuovaPassword.text = pasteboard.string
        }
    }
    
    @IBAction func caratteriTastiera(_ sender: UIButton) {
        //Se la label è allo stato iniziale cancella tutto prima di battere il carattere
        if labelNuovaPassword.text == "Input Password" {
            labelNuovaPassword.text = ""
        }
        //Se viene premuto un numero sulla tastiera
        if let carattere = sender.currentTitle {
            if !isMaiusc {
                //lo aggiungiamo alla stringa
                labelNuovaPassword.text?.append(carattere)
            } else {
                //lo aggiungiamo alla stringa
                labelNuovaPassword.text?.append(carattere.capitalized)
            }
            
        }
    }
    
    @IBAction func numeriTastiera(_ sender: UIButton) {
        //Se la label è allo stato iniziale cancella tutto prima di battere il numero
        if labelNuovaPassword.text == "Input Password" {
            labelNuovaPassword.text = ""
        }
        //Se viene premuto un carattere sulla tastiera
        if let numero = sender.currentTitle {
            //lo aggiungiamo alla stringa
            labelNuovaPassword.text?.append(numero)
        }
    }
    
    @IBAction func bottoneFatto(_ sender: UIButton) {
        
        //creiamo la Stringa dalla UI del Widget
        let stringaQR = QRManager.shared.createQRStringFromParameters(fieldSSID: ssidReteAttuale!, isHidden: switchReteNascosta.isOn, AutType: tipoAutenticazione, password: labelNuovaPassword.text!)
        
        guard let nuovaReteWiFi : WiFiModel = QRManager.shared.creaNuovaReteWiFiDa(stringa: stringaQR) else {return}
        
            DataManager.shared.salvaEdIndicizzaInSpotlightNuovaReteWiFi(da: nuovaReteWiFi)

        //Il dato in storage viene indicizzato correttamente
        //Estraiamo l'ultima istanza dall'array storage e ci compiliamo la view
        if let rete = DataManager.shared.storage.last {
            if ssidReteAttuale == rete.ssid {
                //mettiamo i dati a schermo
                self.labelNomeReteWidg.text = "Rete: " + rete.ssid
                self.labelImmaQRWidg.image = rete.immagineQRFinale
                self.labelPassReteWidg.text = "Password: " + rete.password
                //trasmettiamo l'indice della rete rilevata alla nostra var
                self.indiceIstanza = DataManager.shared.storage.index(of: rete)
                //mostriamo la stack dedicata
                stackHoRete.isHidden = false
                stackNonHoRete.isHidden = true
                //nascondiamo la tastiera
                viewTastiera.isHidden = true

            }
        }
       
        //lo espandiamo
        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        // impostiamo la misura del widget, va fatto per forza dopo che tutto è stato caricato
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 110)
        
    }
    
    @IBAction func bottoneCatchManually(_ sender: UIButton) {
        
        //aggiustiamo la view
            self.labelNuovaPassword.text = "Input Password"
            viewTastiera.isHidden = false
            stackTastiera.isHidden = false
            // impostiamo la misura del widget,
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 450)
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            //nascondiamo il bottone, l'utente dovrà gestire ora dal tasto di apple "ShowMore/ShowLess"
            bottoneManually.isHidden = true
        
    }

}

