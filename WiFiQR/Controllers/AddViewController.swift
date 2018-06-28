//
//  AddViewController.swift
//  WIFIQR
//
//  Created by riccardo silvi on 02/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class AddViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Outlet

    @IBOutlet weak var fieldNomeRete: UITextField!
    @IBOutlet weak var lblReteNascosta: UILabel!
    @IBOutlet weak var switchReteNascosta: UISwitch!
    @IBOutlet weak var lblProtezioneRete: UILabel!
    @IBOutlet weak var switchReteProtetta: UISwitch!
    @IBOutlet weak var segContTipoAutenticazione: UISegmentedControl!
    @IBOutlet weak var lblTipoAutenticazioneSelezionata: UILabel!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var lblWiFiQRStringa: UILabel!
    @IBOutlet weak var immagineAddQRCode: UIImageView!
    
    // MARK: - Variabili globali
    
    //var ponte
    var reteWiFiDaModificare : WiFiModel?
    
    //stato protezione rete (x switch)
    
    var isProtected : Bool = false
    
    // MARK: - Metodi standard del controller
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rendiamo raggiungibile questo controller da qualsiasi punto dell'App
        DataManager.shared.addCont = self
        //alertPrimoAccesso()
        
        //replichiamo l'interfaccia del resto dell'app
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //sfondo della table invariato ma volendo cambiare tramite la riga sotto
        //tableView.backgroundColor = UiColor.red
        
        title = "New Wi-Fi Network"
        
        //delegato ai textfield
        fieldNomeRete.delegate = self
        fieldPassword.delegate = self
        
        caricamentoUI()
        
    }
    
    // MARK: - Azioni
    
    @IBAction func salva(_ sender: UIBarButtonItem) {
            if fieldNomeRete.text!.isEmpty == false {
                //RICREIAMO La STRINGA E L'IMMAGINE QR AL TOCCO DEL TASTO SALVA
                //al fine di evitare che l'utente tocchi dei parametri senza poi rigenerare
                creaStringaDaParametriElaboraQRDalloAllaUI()
                //SALVATAGGIO DATI IN BASE CHE SIA UNA NUOVA RETE O MENO
                // e se è una rete da modificare
                if let wifiOk = reteWiFiDaModificare {
                    wifiOk.wifyQRStringa = lblWiFiQRStringa.text!
                    wifiOk.ssid = fieldNomeRete.text!
                    wifiOk.ssidNascosto = switchReteNascosta.isOn
                    wifiOk.statoSSIDScelto = lblReteNascosta.text!
                    wifiOk.richiedeAutenticazione = switchReteProtetta.isOn
                    wifiOk.tipoAutenticazioneScelto = lblTipoAutenticazioneSelezionata.text!
                    wifiOk.password = fieldPassword.text!
                    print("parametri passati poi immagine")
                    wifiOk.immagineQRFinale = immagineAddQRCode.image!
                    print("immagine passata ci sono errori?")
                    //salva
                    DataManager.shared.salvaReteWiFi()
                    print("rete modificata salvata in DataManager.shared.storage")
                    //*** MODIFICA SPOTLIGHT ***\\
                    // indicizziamo in Spotlight
                    DataManager.shared.indicizza(reteWiFiSpotlight: wifiOk)
                    //Ricarichiamo la table della lista delle reti(ListController)
                    //*** MODIFICA TODAY ***\\
                    (DataManager.shared.listCont as? ListController)?.tableView.reloadData()
                    print("table aggiornata.")
                    //Per aggiornare i dati a video nel DetailController della rete attiva
                    //*** MODIFICA TODAY ***\\
                    (DataManager.shared.detCont as? DettaglioWifiController)?.title = "WiFiQR"
                    (DataManager.shared.detCont as? DettaglioWifiController)?.lblSsid.text = wifiOk.ssid
                    (DataManager.shared.detCont as? DettaglioWifiController)?.lblTipoAutenticazione.text = wifiOk.tipoAutenticazioneScelto
                    (DataManager.shared.detCont as? DettaglioWifiController)?.lblPassword.text =  wifiOk.password
                    (DataManager.shared.detCont as? DettaglioWifiController)?.lblReteNascosta.text = wifiOk.statoSSIDScelto
                    (DataManager.shared.detCont as? DettaglioWifiController)?.immagineQRCode.image = wifiOk.immagineQRFinale
                
                } else {
                    //salva nuova rete
                    /****RIPRISTINARE IMMAGINE SU ULTIMA  RIGA****/
                    DataManager.shared.nuovaReteWiFi(wifyQRStringa: lblWiFiQRStringa.text!  , ssid: fieldNomeRete.text!, ssidNascosto: switchReteNascosta.isOn, statoSSIDScelto: lblReteNascosta.text!, richiedeAutenticazione: switchReteProtetta.isOn, tipoAutenticazioneScelto: lblTipoAutenticazioneSelezionata.text!, password: fieldPassword.text!, immagineQRFinale: immagineAddQRCode.image!)
                        print("rete nuova salvata")
                    //*** MODIFICA SPOTLIGHT ***\\
                    // indicizziamo in Spotlight
                    DataManager.shared.indicizza(reteWiFiSpotlight:DataManager.shared.storage.last! )
                    //Ricarichiamo la table della lista delle reti(ListController) perchè DataManager adesso viene compilato anche con il Today...
                    // Ma il Today NON possiede ListController, quindi se la lasciamo nel DataManager da errore
                    //*** MODIFICA TODAY ***\\
                    (DataManager.shared.listCont as? ListController)?.tableView.reloadData()
                    
                }
                //chiude la modal
                dismiss(animated: true, completion: nil)
                print("modal chiusa")
            } else {
                //altrimenti mostra l'alert
                let simpleAlert = UIAlertController(title: "WARNING", message: "Check fields or image", preferredStyle: .alert)
                simpleAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(simpleAlert, animated: true, completion: nil)
                // fermiamo il codice in modo che non prosegua oltre
                return
    }
       
    }
    
    @IBAction func annulla(_ sender: Any?) {
        //chiude la modal
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchReteNascostaPremuto(_ sender: UISwitch) {

        if switchReteNascosta.isOn == true {
           print("Network is Hidden, Switch is on")
           lblReteNascosta.text = "Hidden Network"
         
        } else {
            //azione
            print("Network is visible, Switch is off")
            lblReteNascosta.text = "Visible Network"
            }
    }
    @IBAction func switchReteProtettaPremuto(_ sender: UISwitch) {
                if switchReteProtetta.isOn == true {
                    //azione
                    print("Netowrk is protected, Switch is on")
                    lblProtezioneRete.text = "Protected Network"
                    lblTipoAutenticazioneSelezionata.text = Encryption.wep
                    segContTipoAutenticazione.isEnabled = true
                    segContTipoAutenticazione.selectedSegmentIndex = 0
                    fieldPassword.isEnabled = true
                    isProtected = true
                    } else {
                    //azione
                    print("Network is free, Switch is off")
                    lblProtezioneRete.text = "Free Network"
                    lblTipoAutenticazioneSelezionata.text = "No Password Required"
                    segContTipoAutenticazione.isEnabled = false
                    fieldPassword.isEnabled = false
                    isProtected = false
                }
    }
    
    @IBAction func indexSegContTipoAutcambiato(_ sender: UISegmentedControl) {
        switch segContTipoAutenticazione.selectedSegmentIndex
        {
        case 0:
            lblTipoAutenticazioneSelezionata.text = Encryption.wep;
            print("Wep Segment Selected");
        case 1:
            lblTipoAutenticazioneSelezionata.text = Encryption.wpa_Wpa2;
            print("Wpa Segment Selected");
        default:
            break
        }
    }
    
    @IBAction func foto(_ sender: UITapGestureRecognizer) {
        // nel caso la tastiera sia fuori la chiudiamo
        fieldNomeRete.resignFirstResponder()
        fieldPassword.resignFirstResponder()
        
        //A FINI DI CONTROLLO CREIAMO LA STRINGA ANCHE A QUESTO PUNTO
        //controlliamo con guardia che la rete abbia un nome
        if fieldNomeRete.text?.isEmpty == false && fieldNomeRete.text != "WIFI:S:;" {
            creaStringaDaParametriElaboraQRDalloAllaUI()
        } else {
            //altrimenti mostra l'alert
            let simpleAlert = UIAlertController(title: "WARNING", message: "Must fill at least SSID field to generate QRCode", preferredStyle: .alert)
            simpleAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(simpleAlert, animated: true, completion: nil)
        }
    }
  
    // MARK: - Metodi Vari
    
    func creaStringaDaParametriElaboraQRDalloAllaUI() {
        //crea una stringa come risultato della funzione "creaStringaDaParametro"
        let stringaElaborata = QRManager.shared.createQRStringFromParameters(fieldSSID: fieldNomeRete.text!, isProtected: switchReteProtetta.isOn, isHidden: switchReteNascosta.isOn, AutType: lblTipoAutenticazioneSelezionata.text!, password: fieldPassword.text!)
        
//    let stringaElaborata =
            lblWiFiQRStringa.text = stringaElaborata
        //crea un immagine UIImage come risultato della funzione "creaQRCodeDaStringa"
        let immaXView = QRManager.shared.generateQRCode(from: stringaElaborata, with: Transforms.x9y9)
        //Assegna l'immagine sopra all'interfaccia
        immagineAddQRCode.image = immaXView
        //messaggini di successo
        print("immagineCIImageScalataCreataEpassataallaView")
        print("immagine QR presentata con successo")
        }

    func caricamentoUI() {
        //campo password sicuro e con tasto clear attivo
        fieldPassword.isSecureTextEntry = true
        fieldPassword.clearButtonMode = .whileEditing
        //se è una rete da moficare caricane i valori a video
        if let wifiOk = reteWiFiDaModificare {
            lblWiFiQRStringa.text = wifiOk.wifyQRStringa
            fieldNomeRete.text = wifiOk.ssid
            switchReteNascosta.isOn = wifiOk.ssidNascosto
            lblReteNascosta.text = wifiOk.statoSSIDScelto
            switchReteProtetta.isOn = wifiOk.richiedeAutenticazione
            lblTipoAutenticazioneSelezionata.text = wifiOk.tipoAutenticazioneScelto
            fieldPassword.text = wifiOk.password
            immagineAddQRCode.image = wifiOk.immagineQRFinale
            //aggiorniamo lo stato della var che monitora la protezione
            self.isProtected = wifiOk.richiedeAutenticazione
            //E ADATTA LE PARTI VISIVE DELL'UI AI PARAMETRI
            //se la rete è nascosta abilita o meno lo switch
            //e aggiorna la label
            if wifiOk.ssidNascosto == true {
                lblReteNascosta.text = "Hidden Network"
            } else {
                lblReteNascosta.text = "Visible Network"
            }
            //se la rete non è protetta disabilita i campi protezione
            if wifiOk.richiedeAutenticazione == false {
                segContTipoAutenticazione.isEnabled = false
                lblTipoAutenticazioneSelezionata.text = "No Password Required"
                fieldPassword.isEnabled = false
            }
            //modifica il segmento WEP-WPA in base al contenuto
            if lblTipoAutenticazioneSelezionata.text == Encryption.wep {
                segContTipoAutenticazione.selectedSegmentIndex = 0
            } else {
                segContTipoAutenticazione.selectedSegmentIndex = 1
            }
            
        } else {
            //se è una nuova rete
            self.isProtected = false
            //ssid è il valore prodotto dalla funzione "recuperaNomeReteWiFi"
            if let ssid = DataManager.shared.recuperaNomeReteWiFi() {
                //se SSID ha un valore
                if ssid != "" {
                    //stampa in console il nome rete
                    print("RETE RILEVATA: \(ssid)")
                    //stampa nella label il nome rete
                    fieldNomeRete.text = "\(ssid)"}
            }
            //disabilita segmento tipo password e relativo field
            //e resetta il contenuto delle label
            segContTipoAutenticazione.isEnabled = false
            lblReteNascosta.text = "Visible Network"
            lblProtezioneRete.text = "Free Network"
            lblTipoAutenticazioneSelezionata.text = "No Password Required"
            fieldPassword.isEnabled = false
            //piazza IMMAGINE QR di Default
            immagineAddQRCode.image = #imageLiteral(resourceName: "QRStarter")
        }
    }
    
    func alertPrimoAccesso (){
        if DataManager.shared.contatoreAccessiAddCont == 0 {
            //mostra l'alert che informa l'utente sulla generazione\refresh del qr
            let simpleAlert = UIAlertController(title: "Instructions",
                                                message: "1. Fill at least SSID field before saving \n2.You can preview your QRCode by pressing the image everytime you want before hitting the Save Button \n3.When you hit the Save Button, even if you have changed parameters after generating a preview QR, the App will refresh it for you \nPlease enjoy the App",
                                                preferredStyle: .alert)
            simpleAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(simpleAlert, animated: true, completion: nil)
            DataManager.shared.contatoreAccessiAddCont = +1
        }
        
    }
    
    //MARK: - Delegati
    
    //per chiusura tastiera tasto return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fieldNomeRete.resignFirstResponder()
        fieldPassword.resignFirstResponder()
        return true
    }
}

