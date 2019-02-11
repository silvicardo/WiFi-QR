//
//  QRManager.swift
//  WiFiQR
//
//  Created by riccardo silvi on 27/06/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class QRManager {
	
	static let shared = QRManager()
    
    
    func generateQRCode(from string: String,with transform: CGAffineTransform = Transforms.x9y9) -> UIImage?{
        //con scalex e y mirati rendiamo nitida l'immagine per la UI
        //per i detail e add controller e table iniziale ok 9
        
        //accettiamo la stringa da elaborare e la passiamo alla costante interna
        guard let dataInputString = string.data(using: String.Encoding.ascii) else { return nil }
        
        guard let filtro = creaNuovoCIFilter(da: dataInputString) else {return nil}
        
        guard let outputImage : UIImage = generaOutput(da: filtro, con: transform) else { return nil }
        
        return outputImage
    }
    
    ///FUNZIONE PER DECODIFICA DA UI IMAGE A CONTENUTO TESTUALE CODICE QR
    func verificaEgeneraStringaQRda(immaAcquisita :UIImage) -> String {
        
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let ciImage:CIImage = CIImage(image:immaAcquisita)!
        var qrCodeLink=""
        
        let features = detector.features(in: ciImage)
        for feature in features as! [CIQRCodeFeature] {
            qrCodeLink += feature.messageString!
        }
        guard qrCodeLink != "" else { return qrCodeLink}
        print("QRStringaRilevata!!! : \(qrCodeLink)")
        
        return qrCodeLink
    }
    
    ///verifica se una data immagine ha un QR importabile dall'App
    func esaminaSeImmagineContieneWiFiQR(_ immagine : UIImage) -> String {

        guard let reteWiFi = WiFiModel.init(immaAcquisita: immagine) else { return "NoWiFiString" }
        
        return reteWiFi.wifyQRStringa
    }

    ///estrae immagine da un FetchResult della libreria foto
    /// e verifica se una data immagine ha un QR importabile dall'App
    func checkIfQRStringIn(library image: PHAsset,with requestOptions: PHImageRequestOptions, in viewFrameSize: CGSize )-> String? {
        
        var stringaRisultato = ""
        
        PhotoLibraryManager.shared.converti(image, with: requestOptions, targeting: viewFrameSize) { (image) in
            //Esaminiamo l'immagine e otteniamo una stringa Risultato
            stringaRisultato = self.esaminaSeImmagineContieneWiFiQR(image)
        
            }
    
        return (stringaRisultato != "NoWiFiString" && stringaRisultato != "") ?  stringaRisultato : nil
        
        }
    
}


// MARK: - Funzioni a supporto generateQRCode(from string, with tranform) -> UIImage

extension QRManager {
    
    func creaNuovoCIFilter(da inputData: Data) -> CIFilter? {
        
        guard let filtro = CIFilter(name: "CIQRCodeGenerator") else {return nil}
        
        //settiamo i parametri per la trasformazione a CIImage(QrCode)
        //diciamo al generatore :
        //qual'è la stringa da lavorare
        filtro.setValue(inputData, forKey: "inputMessage")
        // quale livello di qualità vogliamo("Q")
        filtro.setValue("Q", forKey: "inputCorrectionLevel")
        
        return filtro
        
    }
    
    func generaOutput(da filtro : CIFilter, con transformParams : CGAffineTransform) -> UIImage? {
        
        //Procedi solo se possibile produrre un output
        
        guard let output = filtro.outputImage?.transformed(by: transformParams)  else {return nil}
        //si crea "CoreImagecontesto" oggetto di CICONTEXT che creerà la CIImage finale
        // Create a new CoreImage context object, all output will be drawn
        // into the surface attached to the OpenGL context 'cglctx'. If 'pixelFormat' is
        // non-null it should be the pixel format object used to create 'cglctx';
        let coreImageContesto:CIContext = CIContext.init(options: nil)
        
        //si produce dal suddetto contesto una CIImage adottando
        //il contenuto e i confini dell'immagine prodotta(output) dal generatore (filtro)
        let cgImageFinale:CGImage = coreImageContesto.createCGImage(output, from: output.extent)!
        
        //creazione della UIImage utilizzabile
        let image:UIImage = UIImage.init(cgImage: cgImageFinale)
        
        return image
    }
}

