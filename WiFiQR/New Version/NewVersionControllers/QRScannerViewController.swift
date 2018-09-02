//
//  QRScannerViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 22/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import Photos
import NotificationCenter

class QRScannerViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let toQrCodeFoundVC = "ToQrCodeFound"
    
    //dichiariamo le variabili per la scansione
    var sessioneDiCattura = AVCaptureSession()
    
    var dispositivoDiCattura : AVCaptureDevice!
    
    var dispositivoDiInput : AVCaptureDeviceInput!
    
    var layerAnteprimaVideo : AVCaptureVideoPreviewLayer?
    
    var captureMetadataOutput : AVCaptureMetadataOutput?
    
    var qrCodeFrameView: UIView?
    
    //var ponte rete WiFi
    var reteWiFiAcquisita : WiFiNetwork?
    
    //dichiariamo le variabili per i parametri del dispositivo video
    var zoomFactor : CGFloat = 1.0
    
    var flashAVDeviceIsOff = true
    
    @IBOutlet weak var mainUIView : UIView!
    
    @IBOutlet weak var avCaptureNotAvailable : UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var actionButtonsUIView : UIView!
    
    @IBOutlet weak var qrDetectionUIView : UIView!
    
    @IBOutlet weak var messageLabel : UILabel!
    
    @IBOutlet weak var flashButton: DesignableButton!
    
    @IBOutlet var pinchToZoomGestureRecognizer: UIPinchGestureRecognizer!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCameraOrientation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        collectionView.delegate = self
        collectionView.dataSource = self
        
        findInputDeviceAndDoVideoCaptureSession()
        
        avCaptureNotAvailable.isHidden = sessioneDiCattura.isRunning
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //L'observer controlla che la sessione non sia stata interrotta
        //a causa di app in splitView su Ipad
        //AVCAPTURE FUNZIONA SOLO IN FULL SCREEN
        self.addObserverForAVCaptureSessionWasInterruptedAndDidStartRunning()
        
        if !sessioneDiCattura.isRunning {
            sessioneDiCattura.startRunning()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionDidStartRunning, object: nil)
        sessioneDiCattura.stopRunning()
        
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setCameraOrientation()
        
    }
    
    
    func addObserverForAVCaptureSessionWasInterruptedAndDidStartRunning() {
        
        //L'observer ci permette di conoscere la ragione dell'interruzione della sessione
        //e agire di conseguenza nella sua closure in base alla determinata motivazione
        //contenuta nelle userInfo della notifica di interruzione stessa
        
        let mainQueue = OperationQueue.main
        
        NotificationCenter.default.addObserver(
            
            forName: Notification.Name.AVCaptureSessionWasInterrupted  ,
            object: nil,
            queue: mainQueue,
            using: { notification in
                                                
            guard let userInfo = notification.userInfo else { return }
                
            //Non eseguiamo un controllo sulla piattaforma
            //siccome l'app è eseguibile solamente da ios 11 in su
            //e quindi l'azione consecutiva all'interruzione dell'AVCaptureSession
            //va eseguita
                
             if let interruptionReason = userInfo[AVCaptureSessionInterruptionReasonKey],
                Int(truncating: interruptionReason as! NSNumber) == AVCaptureSession.InterruptionReason.videoDeviceNotAvailableWithMultipleForegroundApps.rawValue {
                //Action to perform when in Slide Over, Split View, or Picture in Picture mode on iPad
                //self.performSegue(withIdentifier: self.toQrCodeFoundVC, sender: nil)
                self.avCaptureNotAvailable.isHidden = false
                print("multitasking")
                

                }
            })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureSessionDidStartRunning, object: nil, queue: mainQueue) { (notification) in
            
             self.avCaptureNotAvailable.isHidden = true
           print("session ripartita")
        }
    }
        

//func checkForUserPermissionsAndStartNewAVCaptureSession() {
//        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized {
//            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
//
//                DispatchQueue.main.async() { [weak self] in
//                    if granted {
//                        if granted {
//                            print("permessi utente ok")
//                            self?.findInputDeviceAndDoVideoCaptureSession()
//                        } else {
//                            print("faulty Permissions")
//                        }
//                    }
//
//            }
//        }
//      }
//    }
        @objc func setCameraOrientation() {
            
            guard let previewLayer = layerAnteprimaVideo else { return }
            
            guard let previewLayerConnection : AVCaptureConnection = previewLayer.connection else { return }
            
            guard previewLayerConnection.isVideoOrientationSupported else { return }
            
            let currentDevice: UIDevice = UIDevice.current
            
            let deviceOrientation: UIDeviceOrientation = currentDevice.orientation
        
            let newCaptureVideoOrientation : AVCaptureVideoOrientation
            
            switch (deviceOrientation) {
                
                    case .portrait: newCaptureVideoOrientation = .portrait
                    case .landscapeRight: newCaptureVideoOrientation = .landscapeLeft
                    case .landscapeLeft: newCaptureVideoOrientation = .landscapeRight
                    case .portraitUpsideDown: newCaptureVideoOrientation = .portraitUpsideDown
                    default: newCaptureVideoOrientation = .portrait
                    }
                    
            previewLayerConnection.videoOrientation = newCaptureVideoOrientation
            
            layerAnteprimaVideo!.frame = self.view.bounds
            
            if !sessioneDiCattura.isRunning {
                sessioneDiCattura.startRunning()
            }
            
        }
    
    func goToQrFoundVC () {
        
        performSegue(withIdentifier: toQrCodeFoundVC, sender: nil)
    }
    
    @IBAction func flashButtonPressed(_ sender: DesignableButton) {
        
        guard dispositivoDiCattura.hasFlash else { return }
        
        if flashAVDeviceIsOff {
            
            dispositivoDiCattura.modalitaTorcia(flashOff: flashAVDeviceIsOff)
            flashAVDeviceIsOff = false
            sender.shake()
            
        } else {
            
            dispositivoDiCattura.modalitaTorcia(flashOff: flashAVDeviceIsOff)
            flashAVDeviceIsOff = true
            sender.shake()
        }
        
    }
    
    @IBAction func libraryButtonTapped(_ sender: DesignableButton) {
        
        //Acquisizione immagine dalla libreria
        CameraManager.shared.newImageLibrary(controller: self, sourceIfPad: nil, editing: false) { (immaSel) in
           
            //ad immagine acquisita visualizza elementi view per conferma importazione
            print("immagine acquisita da libreria")
            
                let decodedString = QRManager.shared.esaminaSeImmagineContieneWiFiQR(immaSel)
            
                guard decodedString != "NoWiFiString" else { return }
            
                delay(1.0, closure: { self.goToQrFoundVC()})
            
            
        }
        
    }
    
    @IBAction func pinchToZoomGestureDidHappen(_ sender: UIPinchGestureRecognizer) {
        
        //se dispositivo predefinito di cattura è disponibile a ripresa video
        guard let device = dispositivoDiCattura else  {return}
        
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
        
        let newScaleFactor = minMaxZoom(pinchToZoomGestureRecognizer.scale * zoomFactor)
        
        switch sender.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
        default: break
        }    }
    
}


extension QRScannerViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 20
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestInLibraryCell", for: indexPath) as! LatestInLibraryCollectionViewCell
        cell.latestPicImageView.image = UIImage(named: "QRStarter")
        return cell
    }
    
}

// MARK: - Metodi Cattura AV e Riconoscimento

extension QRScannerViewController {
   
    //Funzione che trova dispositivo di acquisizione, setta la relativa view per il video e
    //acquisisce un array di metadati di tipo QR
    
    func findInputDeviceAndDoVideoCaptureSession(){
        
        createAndConfigureNewAVCaptureSession()
        
        //Inizializza e definisci le proprieta del "layerAnteprimaVideo" e aggiungilo alla view principale come suo sottostrato
        defineAndShowAVCaptureVideoPreviewLayer(for: sessioneDiCattura)
        
        // Inizia la cattura video.
        sessioneDiCattura.startRunning()
        
        // Porta in primo piano gli elementi della view da
        //posizionare sopra al video
        bringSubviewsToFront()
        
        // Crea il frame che evidenzierà il QR Code
        addGreenFrameForQrBounds()
        
    }
    
    func createAndConfigureNewAVCaptureSession() {
        
        guard let rearCamera = getRearWideAngleCamera() else {print("NoCamera");return}
        
        dispositivoDiCattura = rearCamera
        
        dispositivoDiCattura.attivaAutofocus()
        
        if !dispositivoDiCattura.hasFlash {
            
            flashButton.isHidden = true
        }
        
        guard let inputDevice = rearCameraAsInput() else {print("No Input Device"); return }
        
        dispositivoDiInput = inputDevice
        
        // Inizializza un oggetto di AVCaptureMetadataOutput (captureMetadataOutput) e
        //impostalo come "dispositivo di Output" per la "sessioneDiCattura" corrente
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        // Imposta il dispositivo di input  e output per la sessione di acquisizione
        sessioneDiCattura.addInput(dispositivoDiInput)
        
        sessioneDiCattura.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //dichiariamo di voler acquisire un'array di oggetti di solo tipo qr
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
    
    
    func rearCameraAsInput() -> AVCaptureDeviceInput? {
        
        do {
            // Prendi un istanza della classe "AVCaptureDeviceInput" utilizzando l'oggetto "dispositivoDiCattura" ottenuto in precedenza.
            return try AVCaptureDeviceInput(device: dispositivoDiCattura)
            
        } catch {
            // Se ci sono errori, stampali in console e non proseguire oltre.
            print(error)
            return nil
        }
    }
    
    func getRearWideAngleCamera() -> AVCaptureDevice? {
        
        // Acquisiamo la camera posteriore come dispositivo di acquisizione video
        //NOTA: WideAngle supporta anche vecchi dispositivi, Dual camera taglia fuori i dispositivi non plus da Iph7 in giu
        let deviceDiscoverySessionWide = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        //restituiamo il primo risultato disponibile(Optional)
       return deviceDiscoverySessionWide.devices.first
        
    }
    
    func defineAndShowAVCaptureVideoPreviewLayer(for session : AVCaptureSession) {
        
        layerAnteprimaVideo = AVCaptureVideoPreviewLayer(session: session)
        layerAnteprimaVideo?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layerAnteprimaVideo?.frame = view.bounds
        
        view.layer.addSublayer(layerAnteprimaVideo!)
    }
    
    func bringSubviewsToFront(){
        view.bringSubviewToFront(mainUIView)
    }
    
    func addGreenFrameForQrBounds(){
        qrCodeFrameView = UIView()
        //if let per evitare errori...
        if let qrCodeFrameView = qrCodeFrameView {
            //definizione proprietà del frame
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
}


extension QRScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    //Per decodificare il QR(portarlo a Stringa)
    //, dobbiamo implementare il metodo per eseguire operazioni addizionali sui  "metadata objects" trovati.
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Se l'array di metadataObjects è nil .
        guard metadataObjects.count != 0 else { //lascia invisibile il frame
            qrCodeFrameView?.frame = CGRect.zero
            //e avvisa l'utente tramite la stringa ed esci
            messageLabel.text = "No QR code is detected"
            return }
        
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
                guard QRManager.shared.creaStringaConformeDa(stringaGenerica: messageLabel.text!) != "NoWiFiString" else {
                    print("Codice Non Riconosciuto)")
                    //IL CODICE NON è STATO RICONOSCIUTO
                    
//                    //STOPPA la sessione AV per evitare alert doppi
//                    sessioneDiCattura.startOrStopEAzzera(frameView: self.qrCodeFrameView!)
//
//                    //mostriamo alert dedicato all'utente invitandolo al feedback
//                    alertCodiceQRNonValidoGestioneFeedbackStringaRilevata(stringaFeedback: messageLabel.text!);
                    return//ed esci
                }
                //SE LA GUARDIA VIENE SUPERATA QUINDI LA STRINGA PUO' ESSSERE DECODIFICATA
                //abbiamo un istanza di WiFiModel e procediamo al salvataggio tramite alert all'utente
                print("Codice Riconosciuto, nuova Rete Valorizzata")
                
//                guard let nuovaRete = QRManager.shared.creaNuovaReteWiFiDa(stringa: messageLabel.text!) else { return }
//
//                gestisci(sessioneDiCattura, eSeUtenteConfermaSalva: nuovaRete)
                
            }
        }
    }
    
}
