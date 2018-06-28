//
//  ViewController.swift
//  ShowWifiList
//
//  Created by riccardo silvi on 15/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//
//per estrarre il nome della rete della WIfi a cui si è connessi


//importare UIKitit, Foundation, SystemConfiguration.CaptiveNetwork
import UIKit

import SystemConfiguration.CaptiveNetwork

class ViewController2: UIViewController {
    
//************VARIABILI************
    //var che conterrà il qr code
    var qrcodeImage: CIImage!
    //var stringa da passare al generatoreQRCode
    var myWiFiQRString = "WIFI:S:"
    
    //var tipo di Autenticazione scelto
    var autenticazioneScelta = ""
   
//************OUTLETS************
    
    //outlet bottone inizia
    @IBOutlet var btnInizia: UIButton!
    
    //OUTLET STACK PRINCIPALE
    @IBOutlet var viewStack: UIView!
    
    //outlet dentro la stackPrincipale
    //***outlet label nome rete WiFI
    @IBOutlet var lblNomeReteWiFiAttuale: UILabel!
    //***outlet stack interne
    @IBOutlet var stackDati: UIStackView!
    @IBOutlet var stackEncryptChoice: UIStackView!
    
    @IBOutlet var stackSceltaTreBtnPass: UIStackView!
    @IBOutlet var stackPassword: UIStackView!
    @IBOutlet var stackGeneraQRCode: UIStackView!
    
    //outlet dentro la StackDati
    @IBOutlet var lblPassField: UITextField!
    
    //outlet dentro la stack PassChoice
    @IBOutlet var lblEncryptChoice: UILabel!

    
    //outlet dentro la stackEncryptChoice
    @IBOutlet var lblFree: UIButton!
    @IBOutlet var lblWep: UIButton!
    @IBOutlet var lblWpa: UIButton!
    
    
    //outlet dentro la stack GeneraQrCode
    @IBOutlet weak var btnGeneraQRCode: UIButton!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet var viewQR: UIView!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //nasconde la stack principale
        viewStack.isHidden = true
        //nasconde stackPassword
        stackPassword.isHidden = true
        //nasconde stack QRCode
        stackGeneraQRCode.isHidden = true
        //attivazione asterischi campo password
        lblPassField.isSecureTextEntry = true
        
        
       
        
    }
//************FUNZIONI VARIE************
    
    //FUNZIONE RILASCIO QR CODE
    func displayQRCodeImage() {
        //specifichiamo lo "scale factor" per ogni asse
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        //creiamo una nuova CiImage come risultato della trasformazione della prima
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        //convertiamo la nuova immagine a UIImage
        imgQRCode.image = UIImage(ciImage: transformedImage)
        
        
    }
    
//************IB ACTIONS ************
    
    //************FUNZIONE TASTO INIZIA************
    //recupera il nome della rete wifi
    //apre la stack
    @IBAction func showWifi(_ sender: Any) {
        //ssid è il valore prodotto dalla funzione "recuperaNomeReteWiFi"
        let ssid = DataManager.shared.recuperaNomeReteWiFi()
        //se SSID ha un valore
        if ssid != "" {
            //stampa in console il nome rete
            print("SSID: \(String(ssid!))")
            //stampa nella label il nome rete
            lblNomeReteWiFiAttuale.text = "La tua rete è " + ssid!
            //Aggiungi il nome della rete alla stringa principale
            self.myWiFiQRString.append(ssid!  + ";")
            //disabilita azione tasto inizia
            self.btnInizia.isUserInteractionEnabled = false
            //con animazione
            UIView.animate(withDuration: 0.3) {
                //rivela la stack principale di immissione parametri rete
                self.viewStack.isHidden = false
                self.btnInizia.backgroundColor =  UIColor.magenta
            }
        }
    }
    
    //************STACK PASSWORDD ENCRYPTION************
        //TASTO FREE
    @IBAction func addFree(_ sender: Any) {
        //non aggiunge nulla alla stringa principale
         self.myWiFiQRString.append("")
        //modifichiamo la label
        autenticazioneScelta = "Nessuna autenticazione"
        self.lblNomeReteWiFiAttuale.numberOfLines = 2
        self.lblNomeReteWiFiAttuale.text!.append("\n" + self.autenticazioneScelta)
        //con animazione
        UIView.animate(withDuration: 0.3) {
            
            //nasconde la stack scelta
            self.stackEncryptChoice.isHidden = true
            //inserire stack conclusiva
            self.stackGeneraQRCode.isHidden = false
        }
        print(myWiFiQRString)//check stringa in console
        
    }
        //TASTO WEP
    @IBAction func addWep(_ sender: Any) {
        //aggiunge wep alla stringa principale
        self.myWiFiQRString.append("\(Encryption.wep);")
        //modifichiamo la label
        autenticazioneScelta = "Autenticazione WEP"
        self.lblNomeReteWiFiAttuale.numberOfLines = 2
        self.lblNomeReteWiFiAttuale.text!.append("\n" + self.autenticazioneScelta)
        //con animazione
        UIView.animate(withDuration: 0.3) {
            //nasconde la stack scelta
            self.stackEncryptChoice.isHidden = true
            self.stackPassword.isHidden = false
        }
        print(myWiFiQRString)//check stringa in console
    }
        //TASTO WPA
    @IBAction func addWpa(_ sender: Any) {
        //aggiunge wpa alla stringa principale
         self.myWiFiQRString.append("WPA;")
        //modifichiamo la label
        autenticazioneScelta = " Autenticazione WPA/WPA2"
        self.lblNomeReteWiFiAttuale.numberOfLines = 2
        self.lblNomeReteWiFiAttuale.text!.append("\n" + self.autenticazioneScelta)
        //con animazione
        UIView.animate(withDuration: 0.3) {
          
            //nasconde la stack scelta
            self.stackEncryptChoice.isHidden = true
            self.stackPassword.isHidden = false
        }
        print(myWiFiQRString) //check stringa in console
    }
    //************STACK IMMISSIONE PASSWORD************
        //TASTO OK
    @IBAction func okPassword(_ sender: Any) {
        //se il campo è stato riempito
        if lblPassField.text != nil {
            //completa la stringa
            myWiFiQRString.append("P:" + lblPassField.text! + ";;")
            
            UIView.animate(withDuration: 0.3) {
                //nasconde le parti dello stack non utili e mostra stackQR
                self.stackPassword.isHidden = true
                self.stackGeneraQRCode.isHidden = false
                //fa sparire la tastiera alla pressione del tasto ok
                self.lblPassField.resignFirstResponder()
              
            }
            
            print(myWiFiQRString) //check stringa in console
        }
        
    }
   //************STACK RISULTATO/ PRESENTAZIONE STRINGA************
   
    @IBAction func performAction(_ sender: Any) {
        //se l'immagine è uguale a nil
        if qrcodeImage == nil {
            // e se il contenuto del textfield è uguale a stringa vuota
            if myWiFiQRString == "" {
                //non fare nulla
                return
            }
            //generazione qrCode
            let data = myWiFiQRString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter?.outputImage
            //richiamiamo la funzione di conversione e antiBlur
            displayQRCodeImage()
            // nascondiamo "genera" e cambio colore sfondo viewStack
            UIView.animate(withDuration: 0.3) {
           self.stackGeneraQRCode.isHidden = true
                self.viewStack.backgroundColor =  UIColor.green
            }
            //mostriamo la view con animazione
            UIView.animate(withDuration: 1.5, animations: {
                self.viewQR.alpha = 1.0
                self.viewQR.layer.cornerRadius = 12
                self.imgQRCode.alpha = 1.0
                //self.slider.alpha = 1.0
            })
        }
            
        }
}

 //funzione per lo slider
//    @IBAction func changeImageViewScale(_ sender: Any) {
//        imgQRCode.transform = CGAffineTransform(scaleX: CGFloat(slider.value), y: CGFloat(slider.value))
//    }


//    /// Fade in a view with a duration
//    ///
//    /// Parameter duration: custom animation duration
//    func fadeIn(withDuration duration: TimeInterval = 1.0) {
//        UIView.animate(withDuration: duration, animations: {
//            self.alpha = 1.0
//        })
//    }
//
//    /// Fade out a view with a duration
//    ///
//    /// - Parameter duration: custom animation duration
//    func fadeOut(withDuration duration: TimeInterval = 1.0) {
//        UIView.animate(withDuration: duration, animations: {
//            self.alpha = 0.0
//        })
//    }
//


