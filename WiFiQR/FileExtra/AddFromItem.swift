//
//  ViewController.swift
//  leggiQrDaImmagine
//
//  Created by riccardo silvi on 23/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit
import MessageUI


class AddFromItem : UIViewController, CameraManagerDelegate,MFMailComposeViewControllerDelegate {
    //we add protocol stubs. Type 'AddFromItem' does not conform to protocol 'CameraManagerDelegate'
    func cancelImageOrVideoSelection() {
    }
    

    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var btnDecodaESalva: UIButton!
    
    
    @IBOutlet weak var stringaQREstratta: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CameraManager.shared.delegate = self
    }

    
//METODO FOTO A 2 ORE 3 MINUTI VIDEO PIZZA LIST
    //2 ore 8 minuti per inserimento foto
    //Copiamo Camera Manager.swift
    //Aggiungi al plist Privacy - PhotoLibraryUsageDescription
    
    @IBAction func importaFotoDaLibreria(_ sender: Any) {
        
        CameraManager.shared.newImageLibrary(controller: self, sourceIfPad: nil, editing: false) { (immaSel) in

            self.qrCodeImageView.image = immaSel
            print("immagine acquisita da libreria")
        }
        
        }
    
    @IBAction func btnDecodificaESalva(_ sender: UIButton) {
            //bomb
            guard let immaQRAcquisita = qrCodeImageView.image else {print("fallito passaggio da Ui"); return}
        
            decodificaESalvaDaImmagineQR(immaAcquisita: immaQRAcquisita)
    }
    func cambiaImmaXView (immaginexView: UIImage) {
        
        qrCodeImageView.image = immaginexView
        
    }
    func decodificaESalvaDaImmagineQR(immaAcquisita: UIImage) {
        //creiamo una Stringa con i contenuti del QR
        let StringaDecode =  DataManager.shared.leggiImmagineQR(immaAcquisita: immaAcquisita)
        
        //controlliamo ce la Stringa sia conforme ai nostri parametri di codifica
        guard DataManager.shared.stringaGenericaAStringaConforme(stringaGenerica: StringaDecode) != "NoWiFiString" else {
            //se non è conforme ai nostri parametri di codifica
            let alert = UIAlertController(title: "Error", message: "This is not a WiFi QR-Code or the App has no Scheme for it.\nIf you want to let us add your QR Type to our App Please Share it whith us.\nBy choosing Yes, an e-mail with your selected QR-Code will be sent to us with your default e-mail account", preferredStyle: .alert)
            let sendAction = UIAlertAction(title: "Yes, please. Get my image", style: .default, handler: { (action) in
                print("manda il controller per l'invio di una mail")
                //se il passaggio a Data per allegare alla mail il qr non riconosciuto passa...(altrimenti mostra l'alert)
                guard let immaData : Data = UIImagePNGRepresentation(immaAcquisita) else {let erroreImageMailAlert = UIAlertController(title: "SORRY", message: "We could not prepare your mail because attaching image failed", preferredStyle: .alert)
                    erroreImageMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(erroreImageMailAlert, animated: true, completion: nil);return}
                //presenta il VC della mail allegando l'immagine
                let invioMailVC = self.mailDaInviarePreconfigurataVC()
                invioMailVC.addAttachmentData(immaData, mimeType: "image/png", fileName: "myQrToAdd")
                if MFMailComposeViewController.canSendMail(){
                    self.present(invioMailVC, animated: true, completion: nil)
                    
                } else {
                    self.mandaAlertErroreMailFallita()
                }
            })
            alert.addAction(sendAction)
            let doNotSendAction = UIAlertAction(title: "No, please", style: .default, handler: nil)
            alert.addAction(doNotSendAction)
            present(alert, animated: true, completion: nil);
            return
        }
        //altrimenti passiamo la guardia e si procede alla decodifica della stringa sicuri di non ricevere errori
        let StringaDecodeRisultati = DataManager.shared.decodificaStringaQRValidaARisultatixUI(stringaInputQR: StringaDecode)
        //creazioneQRdaStringa e assegnazione a costante immagine
        //guardia per evitare di far crashare l'app se fallisce l'ottenimento di una immagine QR di nostra fattura
        guard let immaXNuovaReteWifi = DataManager.shared.generateQRCodeFromStringV3(from: StringaDecodeRisultati.0, x: 9, y: 9) else {return}
        //OTTENUTA UNA STRINGA E I PARAMETRI NECESSARI A CREARE UNA NUOVA RETE....
        //MOSTRA L'ALERT PER CHIEDERE UNA CONFERMA DALL'UTENTE
        let fieldAlert = UIAlertController(title: "SUCCESS", message: "QR Code Detected", preferredStyle: .alert)
        
        fieldAlert.addAction( UIAlertAction(title: "Discard Image", style: .default, handler: { (action) in
            print("prova a catturare altra immagine")
        }) )
        fieldAlert.addAction( UIAlertAction(title: "Accept and Save Image", style: .default, handler: { (action) in
            print("ritorno al ListController e creo nuova rete in lista")
            //creazioneNuovaReteWifiDaDatiEstratti e ricarica table
            DataManager.shared.nuovaReteWiFi(wifyQRStringa: StringaDecodeRisultati.0, ssid: StringaDecodeRisultati.3[0], ssidNascosto: StringaDecodeRisultati.2, statoSSIDScelto: StringaDecodeRisultati.3[3], richiedeAutenticazione: StringaDecodeRisultati.1, tipoAutenticazioneScelto: StringaDecodeRisultati.3[1], password: StringaDecodeRisultati.3[2], immagineQRFinale: immaXNuovaReteWifi)
            //ritorno al List Controller
            self.performSegue(withIdentifier: "unwindFromAddItem", sender: self)
        }) )
        //mostra alertView
        present(fieldAlert, animated: true, completion: nil)
        
    }
    
   //funzione per creare un MailComposeVC configurato
    func mailDaInviarePreconfigurataVC() -> MFMailComposeViewController {
        
        let mailConfigurataVC = MFMailComposeViewController()
        mailConfigurataVC.mailComposeDelegate = self
        mailConfigurataVC.setToRecipients(["silvicardo86@icloud.com"])
        mailConfigurataVC.setSubject("Please Add this QR-Type to Your App!")
        mailConfigurataVC.setMessageBody("Hi, my QrCode was not recognized by your App. Please add its scheme so i can add to my list as soon as possible. Thanks!", isHTML: false)
        
        return mailConfigurataVC
    }
    //alert relativo ad impossibilità invio mail
    func mandaAlertErroreMailFallita () {
        let erroreMailAlert = UIAlertController(title: "SORRY", message: "We could not prepare your mail because your device has no default mail configured", preferredStyle: .alert)
        erroreMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(erroreMailAlert, animated: true, completion: nil)
    }
 //quando l'utente conferma l'invio della mail
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        let ringraziamentoMailAlert = UIAlertController(title: "THANKS", message: "Thanks for your support, we'll work on your report", preferredStyle: .alert)
        ringraziamentoMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ringraziamentoMailAlert, animated: true, completion: nil)
        
    }

}
