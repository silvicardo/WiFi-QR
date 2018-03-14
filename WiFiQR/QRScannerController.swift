//
//  QRScannerController.swift
//
//  WIFIQR
//
//  Created by riccardo silvi on 29/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import Photos

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,CameraManagerDelegate,MFMailComposeViewControllerDelegate {
    
    // MARK: - CameraManager
    
    //we add protocol stubs. Type 'QRScannerController' does not conform to protocol 'CameraManagerDelegate'
    
    func cancelImageOrVideoSelection() {
    }
    
    // MARK: - Outlet
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    @IBOutlet weak var btnLibreria: UIButton!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var stackImpOrCanc: UIStackView!
    @IBOutlet var stackLibraryPreview: UIStackView!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var primaImmagine: UIImageView!
    @IBOutlet var secondaImmagine: UIImageView!
    @IBOutlet var terzaImmagine: UIImageView!
    @IBOutlet var quartaImmagine: UIImageView!
    
    // MARK: - Variabili
    
    //array per anteprime Immagini
     var anteprime : [UIImage] = []
    //dichiariamo le variabili per i parametri del dispositivo video
    var zoomFactor : CGFloat = 1.0
    var flashAVDeviceAttualeSpento = true
    //dichiariamo le variabili per la scansione
    var sessioneDiCattura = AVCaptureSession()
    var layerAnteprimaVideo : AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    //var ponte
    var reteWiFiAcquisita : WiFiModel?
    
    // MARK: - Metodi standard del controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //*******BARRA DI NAVIGAZIONE********//
        // stile della barra
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        // tinta dei pulsanti nella barra
        navigationController?.navigationBar.tintColor = UIColor.white
        //lasciamo che l'interfaccia si carichi
        //e inizi la sessione AV ma intanto procediamo
        //all'ottenimento dell'immagine
        DispatchQueue.main.async(execute: {
            //popoliamo l'array anteprime
            self.anteprime = self.salvaDallaLibraryUltime(nFoto: 8)
            //"controllo in console
            print("Acquisite n: \(self.anteprime.count) Anteprime di 8")
            
                //assegniamo alle imageView i componenti dell'array
                self.primaImmagine.image = self.anteprime[0]
                self.secondaImmagine.image = self.anteprime[1]
                self.terzaImmagine.image = self.anteprime[2]
                self.quartaImmagine.image = self.anteprime[3]
            })
        
        //CameraManager
        CameraManager.shared.delegate = self
        //attiviamo la sessione AV
        //autofocus incluso
        findInputDeviceAndDoVideoCaptureSession()
        //ritardiamo di un secondo
        delay(1) {
            //l'apparizione della stack con le preview delle ultime 4 immagini
            //così che intanto sia sicuramente finito il loro caricamento
            //ed appaia una view già caricata
            self.view.bringSubview(toFront: self.stackLibraryPreview)
        }
    }

    // MARK: - Actions
    
/*IB ACTIONS RELATIVE A IMPORTAZIONE IMMAGINE DA LIBRERIA E DECODIFICA*/
    
    @IBAction func btnAggiungiDalibreria(_ sender: UIButton) {
            sender.shake()
        //Acquisizione immagine dalla libreria
        CameraManager.shared.newImageLibrary(controller: self, sourceIfPad: nil, editing: false) { (immaSel) in
            self.qrCodeImageView.image = immaSel
            //ad immagine acquisita visualizza elementi view per conferma importazione
            print("immagine acquisita da libreria")
            self.view.bringSubview(toFront: self.qrCodeImageView)
            self.view.bringSubview(toFront: self.stackImpOrCanc)
            //nel caso fossero su "hidden" mostrali
            self.qrCodeImageView.isHidden = false
            self.stackImpOrCanc.isHidden = false
        }
    }
    @IBAction func btnCancel(_ sender: Any) {
        //nascondi gli elementi della view
        self.qrCodeImageView.isHidden = true
        self.stackImpOrCanc.isHidden = true
        
    }
    //Funzione conferma importazione immagine selezionata
    @IBAction func btnImport(_ sender: Any) {
       //guardia passaggio immagine dalla view a costante
        guard let immaQRAcquisita = self.qrCodeImageView.image else {print("fallito passaggio da Ui"); return}
        //stop SessioneAV
        DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        //parte la funzione principale di decodifica da Immagine QR
        self.decodificaESalvaDaImmagineQR(immaAcquisita: immaQRAcquisita)
    }
    
    //MARK: - Actions TapGestureRecognizer
    
    @IBAction func gestureFoto(_ sender: UITapGestureRecognizer) {
        //guardia passaggio immagine dalla view a costante
        guard let immaQRAcquisita = self.primaImmagine.image else {print("fallito passaggio da Ui"); return}
        //stop SessioneAV
        DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        //parte la funzione principale di decodifica da Immagine QR
        self.decodificaESalvaDaImmagineQR(immaAcquisita: immaQRAcquisita)
    }
    @IBAction func gestureFoto2(_ sender: UITapGestureRecognizer) {
        //guardia passaggio immagine dalla view a costante
        guard let immaQRAcquisita = self.secondaImmagine.image else {print("fallito passaggio da Ui"); return}
        //stop SessioneAV
        DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        //parte la funzione principale di decodifica da Immagine QR
        self.decodificaESalvaDaImmagineQR(immaAcquisita: immaQRAcquisita)
    }
    @IBAction func gestureFoto3(_ sender: UITapGestureRecognizer) {
        //guardia passaggio immagine dalla view a costante
        guard let immaQRAcquisita = self.terzaImmagine.image else {print("fallito passaggio da Ui"); return}
        //stop SessioneAV
        DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        //parte la funzione principale di decodifica da Immagine QR
        self.decodificaESalvaDaImmagineQR(immaAcquisita: immaQRAcquisita)
    }
    @IBAction func gestureFoto4(_ sender: UITapGestureRecognizer) {
        //guardia passaggio immagine dalla view a costante
        guard let immaQRAcquisita = self.quartaImmagine.image else {print("fallito passaggio da Ui"); return}
        //stop SessioneAV
        DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        //parte la funzione principale di decodifica da Immagine QR
        self.decodificaESalvaDaImmagineQR(immaAcquisita: immaQRAcquisita)
    }
    
    // MARK: - Metodi Cattura AV e Riconoscimento
    
    //Funzione che trova dispositivo di acquisizione, setta la relativa view per il video e
    //acquisisce un array di metadati di tipo QR
    func findInputDeviceAndDoVideoCaptureSession (){
    // Acquisiamo la camera posteriore come dispositivo di acquisizione video
    //NOTA: WideAngle supporta anche vecchi dispositivi, Dual camera taglia fuori i dispositivi non plus da Iph7 in giu
    let deviceDiscoverySessionWide = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
    //guardia per controllare che sia effettivamente stato trovato
    //un dispositivo di acquisizione valido
    guard let dispositivoDiCattura = deviceDiscoverySessionWide.devices.first else {print("NoCamera");return}
    attivaAutofocus()
    do {
    // Prendi un istanza della classe "AVCaptureDeviceInput" utilizzando l'oggetto "dispositivoDiCattura" ottenuto in precedenza.
    let dispositivoDiInput = try AVCaptureDeviceInput(device: dispositivoDiCattura)
    
    // Imposta il dispositivo di input per la sessione di acquisizione
    sessioneDiCattura.addInput(dispositivoDiInput)
    
    // Inizializza un oggetto di AVCaptureMetadataOutput (captureMetadataOutput) e
    //impostalo come "dispositivo di Output" per la "sessioneDiCattura" corrente
    let captureMetadataOutput = AVCaptureMetadataOutput()
    sessioneDiCattura.addOutput(captureMetadataOutput)
    
    // Settiamo il delegato dell'oggetto come self quindi
    //("AVCaptureMetadataOutputObjectsDelegate" per inviarglielo ed elaborarlo)
    //e utilizziamo la DispatchQueue di default alias
    //"DispatchQueue.manin" di tipo "serial Queue"
    //come processo per eseguire la chiamata
    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    //dichiariamo di voler acquisire un'array di oggetti di solo tipo qr
    captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    
    } catch {
    // Se ci sono errori, stampali in console e non proseguire oltre.
    print(error)
    return
    }
    
    //Inizializza e definisci le proprieta del "layerAnteprimaVideo" e aggiungilo alla view principale come suo sottostrato
    layerAnteprimaVideo = AVCaptureVideoPreviewLayer(session: sessioneDiCattura)
    layerAnteprimaVideo?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    layerAnteprimaVideo?.frame = view.layer.bounds
    view.layer.addSublayer(layerAnteprimaVideo!)
    
    // Inizia la cattura video.
    sessioneDiCattura.startRunning()
    
    // Porta in primo piano gli elementi della view da
    //posizionare sopra al video
    view.bringSubview(toFront: messageLabel)
    view.bringSubview(toFront: btnFlash)
    view.bringSubview(toFront: btnLibreria)
    //view.bringSubview(toFront: stackLibraryPreview)
    
    // Crea il frame che evidenzierà il QR Code
    qrCodeFrameView = UIView()
    //if let per evitare errori...
        if let qrCodeFrameView = qrCodeFrameView {
            //definizione proprietà del frame
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    //Per decodificare il QR(portarlo a Stringa)
    //, dobbiamo implementare il metodo per eseguire operazioni addizionali sui  "metadata objects" trovati.

func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // Se l'array di metadataObjects è nil .
            if metadataObjects.count == 0 {
                //lascia invisibile il frame
                qrCodeFrameView?.frame = CGRect.zero
                //e avvisa l'utente tramite la stringa ed esci
                messageLabel.text = "No QR code is detected"
                return
            }
            // altrimenti se l'array contiene almeno un metadataObject lavorane il primo elemento.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            // Se il metadato trovato è uguale a un metadato di tipo QRCode
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                //crea un oggetto con le dimensioni del qrCode rilevato
                let barCodeObject = layerAnteprimaVideo?.transformedMetadataObject(for: metadataObj)
                //aggiorna le dimensioni del frame  e adattalo ai bordi dell'oggetto rilevato
                qrCodeFrameView?.frame = barCodeObject!.bounds
                //se il valore è convertibile a stringa passa la stringa alla label
                if metadataObj.stringValue != nil {
                    //passa la stringa alla label
                    messageLabel.text = metadataObj.stringValue!
                    //DA INSERIRE LA VERIFICA PER VEDERE SE LA STRINGA PUò ESSERE ACCETTATA
                    //controlliamo ce la Stringa sia conforme ai nostri parametri di codifica
                    guard DataManager.shared.stringaGenericaAStringaConforme(stringaGenerica: messageLabel.text!) != "NoWiFiString" else {
                        //IL CODICE NON è STATO RICONOSCIUTO
                        //gestiamo la sessione AV per evitare alert doppi
                        DataManager.shared.sessionAVStartOrStop(seshAttuale: sessioneDiCattura, frameView: qrCodeFrameView!)
                        //mostriamo alert dedicato all'utente invitandolo al feedback
                        alertCodiceQRNonValidoGestioneFeedbackStringaRilevata(stringaFeedback: messageLabel.text!);
                        return//ed esci
                    }
                    //SE LA GUARDIA VIENE SUPERATA QUINDI LA STRINGA PUO' ESSSERE DECODIFICATA
                    //parte la decodifica della stringa per poi creare il QR rigenerato
                    decodificaGestisciAvSessionESalva(sessioneAV: sessioneDiCattura, stringaDaDecodificare: messageLabel.text!)
                        }
                    }
                }
    
    // MARK: - Metodi decodifica stringa/immagineLibreria e Salvataggio
    
    
    func decodificaGestisciAvSessionESalva(sessioneAV: AVCaptureSession, stringaDaDecodificare: String) {
        
        //parte la decodifica della stringa per poi creare il QR
        let StringaDecodeRisultati = DataManager.shared.decodificaStringaQRValidaARisultatixUI(stringaInputQR: stringaDaDecodificare)
        //creazioneQRdaStringa e assegnazione a costante immagine
        guard let immaXNuovaReteWifi = DataManager.shared.generateQRCodeFromStringV3(from: StringaDecodeRisultati.0, x: 9, y: 9) else {return}
        // Stoppa la cattura video così che il successivo alert non rischi di ripetersi
        DataManager.shared.sessionAVStartOrStop(seshAttuale: sessioneAV, frameView: qrCodeFrameView!)
        //MOSTRA L'ALERT
        let fieldAlert = UIAlertController(title: "SUCCESS", message: "QR Code Detected", preferredStyle: .alert)
        
        fieldAlert.addAction( UIAlertAction(title: "Scan Again", style: .default, handler: { (action) in
            print("ricomincia la cattura e ripeti...")
            // Riparte la cattura video, disponibile per un altro QR
            DataManager.shared.sessionAVStartOrStop(seshAttuale: sessioneAV, frameView: self.qrCodeFrameView!)
        }) )
        fieldAlert.addAction( UIAlertAction(title: "Accept Code", style: .default, handler: { (action) in
            print("ritorno al ListController e creo nuova rete in lista")
            //creazioneNuovaReteWifiDaDatiEstratti e ricarica table
            DataManager.shared.nuovaReteWiFi(wifyQRStringa: StringaDecodeRisultati.0, ssid: StringaDecodeRisultati.3[0], ssidNascosto: StringaDecodeRisultati.2, statoSSIDScelto: StringaDecodeRisultati.3[3], richiedeAutenticazione: StringaDecodeRisultati.1, tipoAutenticazioneScelto: StringaDecodeRisultati.3[1], password: StringaDecodeRisultati.3[2], immagineQRFinale: immaXNuovaReteWifi)
            //*** MODIFICA SPOTLIGHT ***\\
            // indicizziamo in Spotlight
            DataManager.shared.indicizza(reteWiFiSpotlight:DataManager.shared.storage.last! )
            //ricarichiamo la table
            print("pronti a caricare in table")
            (DataManager.shared.listCont as? ListController)?.tableView.reloadData()
            //ritorno al List Controller
            self.performSegue(withIdentifier: "unwindAListContDaScanOrLibrary", sender: self)
        }) )
        //mostra alert
        present(fieldAlert, animated: true, completion: nil)
    }
    
    
    func decodificaESalvaDaImmagineQR(immaAcquisita: UIImage) {
        
        //creiamo una Stringa con i contenuti dell'immagine QR
        let StringaDecode =  DataManager.shared.leggiImmagineQR(immaAcquisita: immaAcquisita)
        //controlliamo con guardia che la Stringa sia conforme ai nostri parametri di codifica
        guard DataManager.shared.stringaGenericaAStringaConforme(stringaGenerica: StringaDecode) != "NoWiFiString" else {
            //se non è conforme ai nostri parametri di codifica
            alertStringaNonCodificabileEInvitoFeedback(immaPerFeedback: immaAcquisita);
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
        //azione "NO"
        fieldAlert.addAction( UIAlertAction(title: "Discard Image", style: .default, handler: { (action) in
            print("prova a catturare altra immagine")
            DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
            self.qrCodeImageView.isHidden = true
            self.stackImpOrCanc.isHidden = true
        }) )
        //Azione "SI"
        fieldAlert.addAction( UIAlertAction(title: "Accept and Save Image", style: .default, handler: { (action) in
            print("ritorno al ListController e creo nuova rete in lista")
            //creazioneNuovaReteWifiDaDatiEstratti e ricarica table
            DataManager.shared.nuovaReteWiFi(wifyQRStringa: StringaDecodeRisultati.0, ssid: StringaDecodeRisultati.3[0], ssidNascosto: StringaDecodeRisultati.2, statoSSIDScelto: StringaDecodeRisultati.3[3], richiedeAutenticazione: StringaDecodeRisultati.1, tipoAutenticazioneScelto: StringaDecodeRisultati.3[1], password: StringaDecodeRisultati.3[2], immagineQRFinale: immaXNuovaReteWifi)
            //*** MODIFICA SPOTLIGHT ***\\
            // indicizziamo in Spotlight
            DataManager.shared.indicizza(reteWiFiSpotlight:DataManager.shared.storage.last! )
            //ricarichiamo la table per evitare ritardi
            print("pronti a caricare in table")
            (DataManager.shared.listCont as? ListController)?.tableView.reloadData()
            //ritorno al List Controller
            self.performSegue(withIdentifier: "unwindAListContDaScanOrLibrary", sender: self)
        }) )
        //mostra alertView
        self.present(fieldAlert, animated: true, completion: nil)
    }
    
    
    
 // MARK: - Metodi accessori fotocamera
    
    @IBAction func pulsanteFlash(_ sender: UIButton) {
        if flashAVDeviceAttualeSpento != false {
            modalitaTorcia(flashOff: flashAVDeviceAttualeSpento)
            flashAVDeviceAttualeSpento = false
            sender.shake()
        } else {
            modalitaTorcia(flashOff: flashAVDeviceAttualeSpento)
            flashAVDeviceAttualeSpento = true
            sender.shake()
        }
    }
    
    @IBAction func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
        //se dispositivo predefinito di cattura è disponibile a ripresa video
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat { return min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor) }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                debugPrint(error)
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)
        
        switch sender.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
        default: break
        }
    }

    func attivaAutofocus (){
        //se dispositivo predefinito di cattura è disponibile a ripresa video
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        //attiviamo l'autofocus
        try! device.lockForConfiguration()
        device.focusMode = .continuousAutoFocus
        device.unlockForConfiguration()
        print("autofocus attivo")
    }
    
    func modalitaTorcia(flashOff: Bool) {
        //se dispositivo predefinito di cattura è disponibile a ripresa video
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        //se il dispositivo ha torcia
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                //se il flash è spento
                if flashOff == true {
                    //accendilo
                    device.torchMode = .on
                } else {
                    //altrimento spegnilo
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("La Torcia non può essere utilizzata")
            }
        } else {
            print("Nessuna Torcia disponibile")
        }
    }
    
    //MARK: - Metodo recupero foto da libreria
    
    ///Salva in un array di UIImage un determinato numero di Foto a partire dall'ultima creata
    func salvaDallaLibraryUltime(nFoto: Int) -> [UIImage] {
        
        var images:[UIImage] = []
        //Ordina le foto in ordine discendente in base alla data di creazione
        //recupera la quantità "nFoto" immessa dall'utente
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = nFoto
        
        // Esegue il fetch degli assets secondo i criteri sopra
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // Se fetchResult non è vuoto,
        // procede con la vera e propria estrapolazione dell'immagine
        if fetchResult.count > 0 {
            //partiamo da un indice richieste pari a zero
            var requestIndex = 0
            
            while requestIndex < fetchResult.count {
                print(fetchResult.count)
                // Nota che se la richiesta non è sincrona
                // la requestImageForAsset retituira' sia la vera immagine che
                // la thumbnail; settando synchronous su true restituirà
                // solo la thumbnail
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                
                // Esegue la image request
                PHImageManager.default().requestImage(for: fetchResult.object(at: requestIndex) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Aggiunge l'immagine all'array desiderato
                        //images += [image]
                        images.append(image)
                        
                        requestIndex += 1
                    }})

            }
        }
        return images
    }
    
     // MARK: - Metodo Creazione Mail Preimpostata
    
    //funzione per creare un MailComposeVC configurato
    func mailDaInviarePreconfigurataVC() -> MFMailComposeViewController {
        
        let mailConfigurataVC = MFMailComposeViewController()
        mailConfigurataVC.mailComposeDelegate = self
        mailConfigurataVC.setToRecipients(["silvicardo86@icloud.com"])
        mailConfigurataVC.setSubject("Please Add this QR-Type to Your App!")
        mailConfigurataVC.setMessageBody("Hi, my QrCode was not recognized by your App. Please add its scheme so i can add to my list as soon as possible. Thanks!", isHTML: false)
        
        return mailConfigurataVC
    }
     // MARK: - Alerts
    
    func alertCodiceQRNonValidoGestioneFeedbackStringaRilevata (stringaFeedback: String) {
        //IL CODICE NON è STATO RICONOSCIUTO
        //ALERT
        let alert = UIAlertController(title: "Error", message: "This is not a WiFi QR-Code or the App has no Scheme for it.\nIf you want to let us add your QR Type to our App Please Share it whith us.\nBy choosing Yes, an e-mail with your selected QR-Code will be sent to us with your default e-mail account", preferredStyle: .alert)
        //Azione Invia Mail per feedback
        let sendAction = UIAlertAction(title: "Yes, please.", style: .default, handler: { (action) in
            print("manda il controller per l'invio di una mail")
            //presenta il VC della mail
            let invioMailVC = self.mailDaInviarePreconfigurataVC()
            invioMailVC.setMessageBody("Hi, my QrCode String \(stringaFeedback) was not recognized by your App. Please add its scheme so i can add to my list as soon as possible. Thanks!", isHTML: false)
            if MFMailComposeViewController.canSendMail(){
                self.present(invioMailVC, animated: true, completion: nil)
                
            } else {
                self.mandaAlertErroreMailFallita()
                //riparte la sessione di cattura AV
                DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
            }
        })
        alert.addAction(sendAction)
        //Azione nessu feedback
        let doNotSendAction = UIAlertAction(title: "No, please", style: .default, handler: {(action) in
            //premuto il tasto no riparte la sessione di cattura AV
            DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
            
            
        })
        alert.addAction(doNotSendAction)
        present(alert, animated: true, completion: nil)
    }
    //alert relativo ad impossibilità invio mail
    func mandaAlertErroreMailFallita () {
        let erroreMailAlert = UIAlertController(title: "SORRY", message: "We could not prepare your mail because your device has no default mail configured", preferredStyle: .alert)
        erroreMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(erroreMailAlert, animated: true, completion: nil)
        DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
    }
    //quando l'utente conferma l'invio della mail
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
        if result != MFMailComposeResult.sent {
            
          let ciDispiaceMailAlert =  creaAlertCiDispiaceDiNonRicevereUnFeedbackEGestisciAvSession(sessioneAV: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        

            present(ciDispiaceMailAlert, animated: true, completion: nil)
        } else {
            
            let ringraziamentoMailAlert = creaAlertGraziePerIlFeedbackEGestisciAvSession(sessioneAV: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)

            present(ringraziamentoMailAlert, animated: true, completion: nil)
        }
        self.qrCodeImageView.isHidden = true
        self.stackImpOrCanc.isHidden = true
        
    }
   
    func alertStringaNonCodificabileEInvitoFeedback(immaPerFeedback: UIImage){
        //se non è conforme ai nostri parametri di codifica
        let alert = UIAlertController(title: "Error", message: "This is not a WiFi QR-Code or the App has no Scheme for it.\nIf you want to let us add your QR Type to our App Please Share it whith us.\nBy choosing Yes, an e-mail with your selected QR-Code will be sent to us with your default e-mail account", preferredStyle: .alert)
        let sendAction = UIAlertAction(title: "Yes, please. Get my image", style: .default, handler: { (action) in
            print("manda il controller per l'invio di una mail")
            //se il passaggio a Data per allegare alla mail il qr non riconosciuto passa...(altrimenti mostra l'alert)
            guard let immaData : Data = UIImagePNGRepresentation(immaPerFeedback) else {
                let erroreImageMailAlert = UIAlertController(title: "SORRY", message: "We could not prepare your mail because attaching image failed", preferredStyle: .alert)
                erroreImageMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(erroreImageMailAlert, animated: true, completion: nil);DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!);
                return}
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
        let doNotSendAction = UIAlertAction(title: "No, please", style: .default, handler: { (action) in
            self.qrCodeImageView.isHidden = true
            self.stackImpOrCanc.isHidden = true
            DataManager.shared.sessionAVStartOrStop(seshAttuale: self.sessioneDiCattura, frameView: self.qrCodeFrameView!)
        })
        alert.addAction(doNotSendAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

 // MARK: - Estensioni

extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    
    
    func shake() {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}

//extension String {
//
//    func toLengthOf(length:Int) -> String {
//        if length <= 0 {
//            return self
//        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
//            return self.substring(from: to)
//            //return String(self[..<to])
//        } else {
//            return ""
//        }
//    }
//}

