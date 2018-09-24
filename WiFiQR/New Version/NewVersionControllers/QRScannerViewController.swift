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
    
    let context = CoreDataStorage.mainQueueContext()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //Stringhe
    
    let foundQr = "Found QRCode: "
    
    let noQrDetected = "No QRCode detected"
    
    let iphoneMessage = "Shoot or pick from Library a QRCode"
    
    let ipadMessage =  "Shoot, pick from library or Drag&Drop a QRCode"
    
    let toQrCodeFoundVC = "ToQrCodeFound"
    
    let toQrCodeUnknownnVC = "ToNotRecognizedQrCode"
    
    let noWiFiString = "NoWiFiString"
    
    let cellId = "LatestInLibraryCell"
    
    var validQrCodeString : String!
    
    var notValidQRString : String!
    
    var unsupportedImage : UIImage!
    
    var isObservingAVCaptureSession = false
    
    //Acquisizione automatica foto da libreria
    
    var arrayLibraryPhotoPreview : [UIImage] = []
    
    //dichiariamo le variabili per la scansione
    var sessioneDiCattura = AVCaptureSession()
    
    var dispositivoDiCattura : AVCaptureDevice!
    
    var dispositivoDiInput : AVCaptureDeviceInput!
    
    var layerAnteprimaVideo : AVCaptureVideoPreviewLayer?
    
    var captureMetadataOutput : AVCaptureMetadataOutput!
    
    var qrCodeFrameView: UIView?

    
    var displayedWalktrough : Bool!
    
    //dichiariamo le variabili per i parametri del dispositivo video
    var zoomFactor : CGFloat = 1.0
    
    var flashAVDeviceIsOff = true
    
    @IBOutlet weak var mainUIView : UIView!
    
    @IBOutlet weak var avCaptureNotAvailable : UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var actionButtonsUIView : UIView!
    
    @IBOutlet weak var qrDetectionUIView : UIView!
    
    @IBOutlet weak var messageLabel : UILabel!

    @IBOutlet weak var flashDesignableView: DesignableView!
    
    @IBOutlet weak var flashButton: DesignableButton!
    
    @IBOutlet weak var previewLoadingDesignableView: DesignableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var pinchToZoomGestureRecognizer: UIPinchGestureRecognizer!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCameraOrientation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        view.addInteraction(UIDropInteraction(delegate: self))
        
        CameraManager.shared.delegate = self
        
        CoreDataManagerWithSpotlight.shared.scanCont = self
        
        
        let userDefaults = UserDefaults.standard
        
        displayedWalktrough = userDefaults.bool(forKey: "DisplayedWalkthrough")
        
        print(displayedWalktrough)
        //empty array
        
        self.arrayLibraryPhotoPreview = []
        
        //CollectionView SetUp
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        print("fine viewDidLoad")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        print("viewWillAppear, resetting UI for actual Device, Orientation and multitasking Status")
        
        let userDefaults = UserDefaults.standard
        
        displayedWalktrough = userDefaults.bool(forKey: "DisplayedWalkthrough")
        
        if self.displayedWalktrough {
        resetUIforNewQrSearch()
    
        //L'observer controlla che la sessione non sia stata interrotta
        //a causa di app in splitView su Ipad
        //AVCAPTURE FUNZIONA SOLO IN FULL SCREEN
        
        self.addObserversForAVCaptureSessionWasInterrupted()
        
        isObservingAVCaptureSession = true
        
        print("Sessione di cattura isRunning = \(self.sessioneDiCattura.isRunning)")
        
        
        findInputDeviceAndDoVideoCaptureSession()
    
        print("Sessione di cattura isRunning = \(self.sessioneDiCattura.isRunning)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
        print("checking if first launch")
        let userDefaults = UserDefaults.standard
        
        displayedWalktrough = userDefaults.bool(forKey: "DisplayedWalkthrough")
        
        if !self.displayedWalktrough {
            
            guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") else {return}
            
            self.present(pageViewController, animated: true, completion: nil)
            
        } else {
    
        //AVCapture Actions
        
        if !sessioneDiCattura.isRunning {
            print("We're multitasking on Ipad, showing alert view")
             self.avCaptureNotAvailable.isHidden = false
        } else {
            print("FullScreenMode, AVSession is succesfully Running, hiding alert View")
            self.avCaptureNotAvailable.isHidden = true
        }
        
        //PhotoLibrary auth status check and actions
        let status = PHPhotoLibrary.authorizationStatus()
    
        switch status {
        case .authorized:
                 self.fillOrUpdateCollectionViewWithLastTenLibraryPhoto()
        case .denied, .restricted :
            print("Permission Denied by the user")
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.fillOrUpdateCollectionViewWithLastTenLibraryPhoto()
                    }
                    
                case .denied, .restricted:
                    print("authorization denied")
                case .notDetermined:
                   break
                }
            }
        }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        
        if self.displayedWalktrough {
            
            sessioneDiCattura.stopRemoving(input: dispositivoDiInput, output: captureMetadataOutput)
            
            NotificationCenter.default.removeObserver(self)
            
            self.isObservingAVCaptureSession = false
            
            messageLabel.text = UIDevice.current.userInterfaceIdiom == .phone ? iphoneMessage : ipadMessage
            
            collectionView.hideAndDisable()
            
        }
        
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
       
        setCameraOrientation()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("Trait did change")
    }
    
   
    
    
    func addObserversForAVCaptureSessionWasInterrupted() {
        //CONTROLLO PER EVITARE OBSERVER DUPLICATI
         if !isObservingAVCaptureSession  {
        print("Adding observer")
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
                
                self.avCaptureNotAvailable.isHidden = false
                print("AVCapture INTERRUPTED BECAUSE multitasking On Ipad")
                }
            })
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureSessionDidStartRunning, object: nil, queue: mainQueue) { (notification) in
                
                self.messageLabel.text = UIDevice.current.userInterfaceIdiom == .phone ? self.iphoneMessage : self.ipadMessage
                
                self.avCaptureNotAvailable.isHidden = true
                
                print("AVSession avviata/riavviata")
                
            }
            
            isObservingAVCaptureSession = true
        }
        
    }
    
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
    
    @IBAction func flashButtonPressed(_ sender: DesignableButton) {
        
        guard dispositivoDiCattura.hasFlash else { return }//doubleCheck
        
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
        
        self.sessioneDiCattura.stopRemoving(input: dispositivoDiInput, output: captureMetadataOutput)
        
        //Acquisizione immagine dalla libreria
        CameraManager.shared.newImageLibrary(controller: self, sourceIfPad: nil, editing: false) { (immaSel) in
           
            //ad immagine acquisita visualizza elementi view per conferma importazione
            print("immagine acquisita da libreria")
            
            let decodedString = QRManager.shared.verificaEgeneraStringaQRda(immaAcquisita: immaSel)
            
            self.unsupportedImage = immaSel
            
            delay(0.6, closure: {//ritardo per dare il tempo al picker di dismissarsi
                self.manageResultFrom(decodedString)
            })
            
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return arrayLibraryPhotoPreview.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LatestInLibraryCollectionViewCell
        
        cell.latestPicImageView.image = arrayLibraryPhotoPreview[indexPath.row]
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
                guard let selectedCellIndexPath = collectionView.indexPathsForSelectedItems?.first else {return }
        
                guard let cell = collectionView.cellForItem(at: selectedCellIndexPath) as? LatestInLibraryCollectionViewCell else {return}
        
                guard let selectedPicture = cell.latestPicImageView.image else {return}
        
                let decodedString = QRManager.shared.verificaEgeneraStringaQRda(immaAcquisita: selectedPicture)
        
                manageResultFrom(decodedString, with: selectedCellIndexPath.row)
        
        
        }
    
    func updateCollectionView(with foundPhotos: [UIImage]) {
        
        print("CollectionView Updates")
        
        //Disables and Hides Collection for deletion/refresh
        collectionView.hideAndDisable()
        
        collectionView.performBatchUpdates({
            
            if collectionView.numberOfItems(inSection: 0) == foundPhotos.count {
                
               removeAllItemsInSectionAndRemoveAllItemsFromImageArray()
                
            }
            
            addImagesToArrayAndItemsInSection(from : foundPhotos)
            
           
        }, completion: { _ in
            
            //UIView.animate(withDuration: 0.7, animations: {
                
                self.previewLoadingDesignableView.isHidden = true
            
                self.activityIndicator.stopAnimating()
                
            self.collectionView.invertHiddenAlphaAndUserInteractionStatus()
            //}
           
        })
    }
    
    func removeAllItemsInSectionAndRemoveAllItemsFromImageArray() {
        
        print("deletion Ops")
        var deletionIndex : Int = 9
        
        while deletionIndex >= 0 {
            
            let indexPath = IndexPath(row: deletionIndex, section: 0)
            
            //print(indexPath)
            
            collectionView.deleteItems(at: [indexPath])
            
            self.arrayLibraryPhotoPreview.remove(at: deletionIndex)
            
            deletionIndex -= 1
        }
    }
    
    func addImagesToArrayAndItemsInSection(from foundPhotos: [UIImage]){
        
        print("refreshOps")
        for (index, photo) in foundPhotos.enumerated() {
            
            //print("index \(index)")
            
            self.arrayLibraryPhotoPreview.append(photo)
            
            let indexPath = IndexPath(row: index , section: 0)
            //print("indexPath \(indexPath)")"
            collectionView.insertItems(at: [indexPath])
        }
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
        
        print("Ready To Start The Session")
        // Inizia la cattura video.
        sessioneDiCattura.startRunning()
        
        print("Session Started, Bringing subviews to front")
        
        // Porta in primo piano gli elementi della view da
        //posizionare sopra al video
        bringSubviewsToFront()
        
        // Crea il frame che evidenzierà il QR Code
        addGreenFrameForQrBounds()
        
    }
    
    func createAndConfigureNewAVCaptureSession() {
        
        print("Getting Rear Camera")
        guard let rearCamera = getRearWideAngleCamera() else {print("NoCamera");return}
        
        dispositivoDiCattura = rearCamera
        
        dispositivoDiCattura.attivaAutofocus()
        
        if !dispositivoDiCattura.hasFlash {
            
            flashDesignableView.isHidden = true
            flashButton.isHidden = true
        }
        
        print("Getting Input Device")
        guard let inputDevice = rearCameraAsInput() else {print("No Input Device"); return }
        
        dispositivoDiInput = inputDevice
        
        print("Setting Metadata Output")
        // Inizializza un oggetto di AVCaptureMetadataOutput (captureMetadataOutput) e
        //impostalo come "dispositivo di Output" per la "sessioneDiCattura" corrente
        self.captureMetadataOutput = AVCaptureMetadataOutput()
        
        // Imposta il dispositivo di input  e output per la sessione di acquisizione
        sessioneDiCattura.addInput(dispositivoDiInput)
        
        self.sessioneDiCattura.addOutput(self.captureMetadataOutput)
        
        self.captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //dichiariamo di voler acquisire un'array di oggetti di solo tipo qr
        self.captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
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

//MARK: - UI Management Methods

extension QRScannerViewController {
    
    func resetUIforNewQrSearch() {
        
        messageLabel.text = UIDevice.current.userInterfaceIdiom == .phone ? iphoneMessage : ipadMessage
        
        collectionView.hideAndDisable()
        
       self.avCaptureNotAvailable.isHidden = true

        
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
            messageLabel.text = noQrDetected
            return }
        
        // altrimenti se l'array contiene almeno un metadataObject lavorane il primo elemento.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Se il metadato trovato è uguale a un metadato di tipo QRCode
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            //crea un oggetto con le dimensioni del qrCode rilevato
            let barCodeObject = layerAnteprimaVideo?.transformedMetadataObject(for: metadataObj)
            
            //aggiorna le dimensioni del frame  e adattalo ai bordi dell'oggetto rilevato
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            guard let qrString = metadataObj.stringValue else { return }
    
            let checkedString = QRManager.shared.creaStringaConformeDa(stringaGenerica: qrString)
            
            manageResultFrom(checkedString)
            

        }
    }
    
}

//MARK: - QRCODE CONVERSION TO NETWORK INSTANCE

extension QRScannerViewController {
    
    func manageResultFrom(_ decodedString : String, with index : Int? = nil) {
        
        let checkedString = QRManager.shared.creaStringaConformeDa(stringaGenerica: decodedString)
        
        if checkedString != noWiFiString {
            
            messageLabel.text = foundQr + checkedString
            
            validQrCodeString = checkedString
            
            sessioneDiCattura.startOrStopEAzzera(frameView: self.qrCodeFrameView!)
            
            print("Codice Riconosciuto, nuova Rete Valorizzata")
            
            performSegue(withIdentifier: toQrCodeFoundVC, sender: nil)
            
        } else {
            
            if let index = index {
                
            unsupportedImage = self.arrayLibraryPhotoPreview[index]
                
            }
            
            notValidQRString = decodedString
            
            print("Codice Non Riconosciuto)")
            
            sessioneDiCattura.startOrStopEAzzera(frameView: self.qrCodeFrameView!)
            
            performSegue(withIdentifier: toQrCodeUnknownnVC, sender: nil)
        }
    }

    
    
}

//MARK : NAVIGATION
extension QRScannerViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.sessioneDiCattura.stopRemoving(input: dispositivoDiInput, output: captureMetadataOutput)
        
        switch segue.identifier {
            
        case toQrCodeFoundVC :
            
            if let destination = segue.destination as? QrCodeFoundViewController {
                
                destination.wifiQrValidString = validQrCodeString
                
            }
            
        case toQrCodeUnknownnVC:
            
            if let destination = segue.destination as? QrCodeNotRecognizedViewController {
            
                destination.unsupportedString = notValidQRString
                destination.unsupportedImage = unsupportedImage
                self.sessioneDiCattura.stopRunning()
            }
            
        default: break
        }
        
    }

}

//MARK: - PHOTOLIBRARY MANAGEMENT

extension QRScannerViewController {

    //*******ACQUISIZIONE FOTO PER ANTEPRIME********//
    
    //lasciamo che l'interfaccia si carichi
    //e inizi la sessione AV ma intanto procediamo
    //all'ottenimento delle anteprime delle immagini se presenti
    
    func fillOrUpdateCollectionViewWithLastTenLibraryPhoto() {
        
        self.collectionView.hideAndDisable()
        
        previewLoadingDesignableView.isHidden = false
        
        activityIndicator.startAnimating()
    
            DispatchQueue.main.async {
                
                if let photos : PHFetchResult<PHAsset>  = PhotoLibraryManager.shared.fetchPhotoLibraryFor(numberOfPhotos: 10) {
                    
                    //prevents crash if user has IcloudPhotoLibrary
                    let icloudOptions = PhotoLibraryManager.shared.icloudRequestOptions
                    
                    PhotoLibraryManager.shared.get(nrOfPhotos : 10, from: photos, per: self.view,with: icloudOptions, withCompletionHandler: { images in
                        
                        OperationQueue.main.addOperation {
                            
                            //assegniamo alle imageView i componenti dell'array
                            self.updateCollectionView(with: images)
                            
                        }
                        
                    })
                    
                }
            }
        }
   
}



extension QRScannerViewController : CameraManagerDelegate {

//Se l'utente non seleziona nulla
func cancelImageOrVideoSelection() {
    print("Nothing selected")
    findInputDeviceAndDoVideoCaptureSession()
    }

}

extension QRScannerViewController : UIDropInteractionDelegate {
    
    //Metodo che gestisce l'azione del controller all'effettiva azione di drag & drop
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        //E' possibile droppare oggetti multipli
        //cicleremo in ognuno di essi
        for dragItem in session.items {
            
            //richiesta di caricamento oggetto draggato
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                //se c'è un errore nel caricamento
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                //altrimenti se non abbiamo errori
                guard let draggedImage = obj as? UIImage else { return }
                
                 DispatchQueue.main.async {
                let decodedString = QRManager.shared.verificaEgeneraStringaQRda(immaAcquisita: draggedImage)
                
                self.unsupportedImage = draggedImage
                
                self.manageResultFrom(decodedString)
                }
            })
        }
    }
    
    //L'oggetto droppato sarà solo copiato nell/dall'app
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    
    //Tipi di file accettati dall'app
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
}

extension UICollectionView {
    
    func hideAndDisable() {
        self.isHidden = true
        self.alpha = 0.0
        self.isUserInteractionEnabled = false
    }
    
    func invertHiddenAlphaAndUserInteractionStatus() {
        self.isHidden = !self.isHidden
        self.alpha = (self.alpha == 1.0) ? 0.0 : 1.0
        self.isUserInteractionEnabled = !self.isUserInteractionEnabled
    }
}



    
    
    
    






