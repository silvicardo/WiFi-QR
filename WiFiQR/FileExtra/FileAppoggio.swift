//
//  FileAppoggio.swift
//  WIFIQR
//
//  Created by riccardo silvi on 05/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//





//
//
//}
//FUNZIONI RECENTI DA USARE

//func goGetStringAndGiveQRV2() {
//    //crea stringa dai parametri attualmente inseriti nei campi
//    DataManager.shared.createQRStringFromParameters(fieldSSID: fieldNomeRete.text!, isProtected: switchReteProtetta, isHidden: switchReteNascosta, AutType: lblTipoAutenticazioneSelezionata.text!, password: fieldPassword.text!)
//    //passa il valore della stringa nel Dmanager alla label
//    lblWiFiQRStringa.text = DataManager.shared.formatQRString
//    print("Stringa generata\(lblWiFiQRStringa.text!)")
//    //crea il qr da stringa generata
//    //scala il qr per essere visualizzato perfettamente
//    DataManager.shared.createFromStringAndShowQRCode(StringToConvertToQR: DataManager.shared.formatQRString, viewImmagine: immagineAddQRCode, inputX: immagineAddQRCode.frame.size.width, inputY: immagineAddQRCode.frame.size.width)
//    print("QR Dreaming....")


//da data manager

////NELLA SEGUENTE FUNZIONE SI POTREBBERO ANCHE RIMUOVERE inputX e Y perchè si possono ricavare dalla view ma così ci si riserva
////la possibilità di produrre un immagine di risoluzione maggiore in base alla necessità
//func createFromStringAndShowQRCode (immagineCI : CIImage, StringToConvertToQR: String, viewImmagine: UIImageView, inputX : CGFloat, inputY : CGFloat ){
//    //generazione qrCode
//    let data = StringToConvertToQR.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
//    let filter = CIFilter(name: "CIQRCodeGenerator")
//    filter?.setValue(data, forKey: "inputMessage")
//    filter?.setValue("Q", forKey: "inputCorrectionLevel")
//    DataManager.shared.qrcodeImageCITemp = filter?.outputImage
//    print("immagine QR generata con successo")
//    //convertiamo la nuova immagine a UIImage e la mettiamo nella var del Dmanager
//    DataManager.shared.qrcodeImage = UIImage(ciImage:  DataManager.shared.qrcodeImageCITemp)
//    //specifichiamo lo "scale factor" per ogni asse a partire dai parametri scelti in avvio funzione
//    let scaleX = inputX /  DataManager.shared.qrcodeImageCITemp.extent.size.width
//    let scaleY = inputY /  DataManager.shared.qrcodeImageCITemp.extent.size.height
//    //creiamo una nuova CiImage scalata come risultato della trasformazione della prima
//    let transformedImage =  DataManager.shared.qrcodeImageCITemp.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//    viewImmagine.image = UIImage(ciImage: transformedImage)
//    print("immagineCIImageScalataCreataEpassataallaView")
//    //convertiamo la nuova immagine a UIImage e la mettiamo nella var del Dmanager
//    //DataManager.shared.qrcodeImage = UIImage(ciImage:  DataManager.shared.qrcodeImageCITemp)
//    print("ImmagineCItrasformataconSuccessoEPassataAlDataManager")
//    //se la view non da Nil assegniamogli l'immagine ormai contenuta nel DataManager
//    
//    print("immagine QR presentata con successo")
//}


//la santa funzione di generazione ok
//func generateQRCode(string: String) -> UIImage? {
//    let data = string.data(using: String.Encoding.ascii)
//    
//    if let filter = CIFilter(name: "CIQRCodeGenerator") {
//        filter.setValue(data, forKey: "inputMessage")
//        filter.setValue("Q", forKey: "inputCorrectionLevel")
//        let transform = CGAffineTransform(scaleX: 9, y: 9)
//        
//        if let output = filter.outputImage?.transformed(by: transform) {
//            let context:CIContext = CIContext.init(options: nil)
//            let cgImage:CGImage = context.createCGImage(output, from: output.extent)!
//            let image:UIImage = UIImage.init(cgImage: cgImage)
//            return image
//        }
//    }
//    
//    return nil
//}

//SI APPOGGIANO QUI LE FUNZIONI COMMENTATE NON PIù UN USO PER REVISIONE

//func generateQRCode() {
//    
//    guard let myWiFiQRString = lblWiFiQRStringa.text else {return}
//    print("la stringa my\(myWiFiQRString)")
//    //se l'immagine è uguale a nil
//    if qrcodeImage == nil {
//        print("QRCODEIMAGE NIL")
//        // e se il contenuto del textfield è uguale a stringa vuota
//        if lblWiFiQRStringa.text == "" {
//            //non fare nulla
//            return
//        }
//        //generazione qrCode
//        let data = myWiFiQRString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
//        let filter = CIFilter(name: "CIQRCodeGenerator")
//        filter?.setValue(data, forKey: "inputMessage")
//        filter?.setValue("Q", forKey: "inputCorrectionLevel")
//        qrcodeImage = filter?.outputImage
//        //richiamiamo la funzione di conversione e antiBlur
//        
//}

/***********************************************/

//func createQRStringFromParameters() {
//    //svuota la stringa
//    lblWiFiQRStringa.text = ""
//    print("Dati minimi Compilati e stringa svuotata")
//    //aggiungiamo il nome della rete alla stringa
//    lblWiFiQRStringa.text?.append("WIFI:S:\(fieldNomeRete.text!);")
//    //se la rete è protetta
//    if switchReteProtetta.isOn == true {
//        //aggiungi tipo autenticazione e password alla stringa
//        if lblTipoAutenticazioneSelezionata.text == "WPA/WPA2"{
//            lblWiFiQRStringa.text?.append("T:WPA;P:\(fieldPassword.text!);")
//        } else {
//            lblWiFiQRStringa.text?.append("T:\(lblTipoAutenticazioneSelezionata.text!);P:\(fieldPassword.text!);")
//        }
//        //se la rete è nascosta
//        if switchReteNascosta.isOn == true {
//            lblWiFiQRStringa.text?.append("H:true;")
//        }
//    }
//    //aggiungi il punto e virgola di chiusura
//    lblWiFiQRStringa.text?.append(";")
//    //Stampa in console stringa finita
//    
//    print("\(lblWiFiQRStringa.text!)")
//}
//
//
//}
/***********************************************/
// creiamo una variabile di tipo CGFloat per contenere l'altezza della cella
// specifichiamo il tipo (CGFloat) a mano
// altrimenti il Type Inference farebbe un Int
// (ma a noi serve un CGFloat perchè richiesto dal metodo tableView:heightForRowAtIndexPath
//var altezza : CGFloat = 50.0
//
//    func openCell() {
//
//        //qui facciamo un semplice if per verificare il valore della variabile altezza
//        if altezza == 44.0 {
//            //se è 44 la mettiamo a 0
//            altezza = 0.0
//        } else {
//            //se è 0 la mettiamo a 44
//            altezza = 44.0
//        }
//        //invochiamo i metodi beginUpdates ed al seguito endUpdates sulla tableView in modo che la table faccia scattare il metodo del datasource che abbiamo usato alla riga 31 e animi la dimensione delle celle
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }

/**********************CONVERSIONE CIIMAGE IN UIMAGE JPGFORMAT*********************/
//Convertiamo l'immagine in jpg
//let renderer = UIGraphicsImageRenderer(size: viewImmagine.bounds.size)
//let image = renderer.image { ctx in
//viewImmagine.drawHierarchy(in: viewImmagine.bounds, afterScreenUpdates: true)
//      }
//**********************FUNZIONE CREAZIONE QR DA STRINGA CHE DAVA ERRORE*********************/
//func goGetQRandString() {
//    //crea stringa dai parametri attualmente inseriti nei campi
//    DataManager.shared.createQRStringFromParameters(fieldSSID: fieldNomeRete.text!, isProtected: switchReteProtetta, isHidden: switchReteNascosta, AutType: lblTipoAutenticazioneSelezionata.text!, password: fieldPassword.text!)
//    //passa il valore della stringa nel Dmanager alla label
//    lblWiFiQRStringa.text = DataManager.shared.formatQRString
//    print("Stringa generata\(lblWiFiQRStringa.text!)")
//    //crea il qr da stringa generata
//    DataManager.shared.generateQRCodeFromString(StringToConvertToQR: DataManager.shared.formatQRString)
//    //scala il qr per essere visualizzato perfettamente
//    DataManager.shared.displayQRCodeImage(immagineInput: DataManager.shared.qrcodeImageCITemp, viewImmagine: immagineAddQRCode, inputX: immagineAddQRCode.frame.size.width, inputY: immagineAddQRCode.frame.size.width)
//
//}
//
////FUNZIONE RILASCIO VISIVO QR CODE
////prende la view a cui va destinata la CIImage e la scala
//func displayQRCodeImage(immagineInput: CIImage, viewImmagine: UIImageView, inputX : CGFloat, inputY : CGFloat ) {
//    //specifichiamo lo "scale factor" per ogni asse
//    let scaleX = inputX / immagineInput.extent.size.width
//    let scaleY = inputY / immagineInput.extent.size.height
//    //creiamo una nuova CiImage come risultato della trasformazione della prima
//    let transformedImage = immagineInput.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//    //convertiamo la nuova immagine a UIImage
//    viewImmagine.image = UIImage(ciImage: transformedImage)
//    //        //Convertiamo l'immagine in jpg
//    //        let renderer = UIGraphicsImageRenderer(size: viewImmagine.bounds.size)
//    //        let image = renderer.image { ctx in
//    //            viewImmagine.drawHierarchy(in: viewImmagine.bounds, afterScreenUpdates: true)
//    //        }
//    //assegniamo l'immagine convertita alla view per evitare errori
//    // viewImmagine.image = image
//    print("immagine QR presentata con successo")
//}

///***************************************Passaggio ad un altro VC programmatico
//        //You should handle the call back here.
//        // Accedi allo storyboard e crea un istanza del Controller da raggiungere
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let viewController =  storyboard.instantiateViewController(withIdentifier: "AddFromItem")
//
//        // E poi rendilo il VC principale
//        let rootViewController = self.window!.rootViewController as! UINavigationController;
//        rootViewController.pushViewController(viewController, animated: true);
//
//        print("passaggio eseguito")




///***************************************Dall'App Delegate, roba per importazione immagine e generazione URL
//let imageData:NSData = UIImagePNGRepresentation(URL()!)! as NSData

//print(imageData)

//let data = try! Data(withContentsOf: URL(string: filePath)!)
//let image = UIImage(data: data)

//w let data = try? Data(withContentsOf: URL(string: filePath)!)
//        let image = UIImage(data: data) {
//            //imageView.contentMode = .scaleAspectFit
//            //imageView.image = image
//        }
//
//estrazione immagine
//        if let data = try? Data(withContentsOf: URL(string: filePath)!) {
//        print("immagine acquisita")
//        let myImage = UIImage(data: data)
//            DataManager.shared.addItemCont?.cambiaImmaXView(immaginexView: myImage!)
//       // if let myImage =  try! UIImage(data: Data(contentsOf: URL(string: filePath)!)){
//            print("iimmagine alla view")
//        } else {
//                print("estrazione immagine fallita")
//        }


//let immaPath = URL(fileURLWithPath: #file).lastPathComponent//String
//print("\nfileName: ", fileName)
//print("\nfilePath: ", filePath)
//print("\nimmaginePath", immaginePath)
//let fileName = URL(fileURLWithPath: filePath)//URL
//let immaginePath = fileName.lastPathComponent//String
//print("immapath", immaPath)


