//
//  DettaglioWifiController.swift
//  WIFIQR
//
//  Created by riccardo silvi on 29/12/17.
//  Copyright © 2017 riccardo silvi. All rights reserved.
//

import UIKit
import QuickLook//per PDF con QLPreviewControllerDataSource
import MessageUI

class DettaglioWifiController: UIViewController, QLPreviewControllerDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
   
    
    
    // MARK: - Outlet
    
    @IBOutlet weak var lblSsid: UILabel!
    @IBOutlet weak var lblTipoAutenticazione: UILabel!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var lblReteNascosta: UILabel!
    
    @IBOutlet weak var immagineQRCode: UIImageView!
    
    @IBOutlet var viewQr: UIView!
    @IBOutlet weak var viewStack: UIView!
    
    // MARK: - Variabili
    
    //var per il passaggio dati
    var reteWiFi : WiFiModel?
    
    //*** MODIFICA 3D TOUCH ***\\
    // questa var serve per passare l'indice della pizza dalla preview del 3D Touch (non c'è altra soluzione)
    var indice : Int!
    
     // MARK: - Metodi standard del controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //*******BARRA DI NAVIGAZIONE********//
        // stile della barra
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        // tinta dei pulsanti nella barra
        navigationController?.navigationBar.tintColor = UIColor.white
        //rendiamo raggiungibile questo controller da qualsiasi punto dell'App
        DataManager.shared.detCont = self

       //se wifiOK riesce a ricevere i dati da rete wifi la guardia passa
        
        guard let wifiOK = reteWiFi else {return}
        //eseguiamo la funzione di caricamento dati per mettere a schermo la WIFI Attuale
        mostraDatiDellaReteWifi(wifiOK)

    }


    //METTE A SCHERMO LA WIFI ATTUALE
    func mostraDatiDellaReteWifi (_ reteWiFi:WiFiModel){
        lblSsid.text = reteWiFi.ssid
        lblTipoAutenticazione.text = reteWiFi.tipoAutenticazioneScelto
        lblPassword.text = reteWiFi.password
        lblReteNascosta.text = reteWiFi.statoSSIDScelto
        
        // mettiamo a video l'immagine
        immagineQRCode.image = reteWiFi.immagineQRFinale
        //snippet imro per regolazione rotazione immagine
        if reteWiFi.immagineQRFinale.size.width > reteWiFi.immagineQRFinale.size.height {
            immagineQRCode.image = UIImage(cgImage: reteWiFi.immagineQRFinale.cgImage!,
                                           scale: 1.0,
                                           orientation: .right)
        }
    }

    
// MARK: - Azioni
    
    //CONDIVISIONE
    
    @IBAction func condividi(_ sender: Any) {
        
        condividi()
        
    }
    
    //Invio Mail bottoneSingolo
    @IBAction func invioMail(_ sender: UIButton) {
        inviaMailConReteAttuale()
    }
    
    @IBAction func invioMessaggio(_ sender: UIButton) {
        inviaMessaggio()
    }
    
    //CREAZIONE PDF
    @IBAction func creaPDF(_ sender: UIBarButtonItem) {
        
        // apriamo un thread alternativo per non rallentare l'interfaccia
        DispatchQueue.global().async {
            // codice eseguito sul thread alternativo
            
            // creiamo il PDF grazie alla libreria SimplePDF
            let pdf = SimplePDF(pdfTitle: "PDF per \(self.reteWiFi!.ssid)", authorName: "WiFiQR")
            
            
            // creaimo una stringa formattata che sarà il Titolo
            let documentTitle = NSMutableAttributedString(string: "\(self.reteWiFi!.ssid)")
            let titleFont = UIFont.boldSystemFont(ofSize: 48)
            let paragraphAlignment = NSMutableParagraphStyle()
            paragraphAlignment.alignment = .center
            let titleRange = NSMakeRange(0, documentTitle.length)
            documentTitle.addAttribute(NSAttributedStringKey.font, value: titleFont, range: titleRange)
            documentTitle.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphAlignment, range: titleRange)
            
            // mettiamola nel PDF grazie all'apposito metodo
            _ = pdf.addAttributedString(documentTitle)
            
//            // facciamo una nuova pagina
//            _ = pdf.startNewPage()
            
            // adesso inseriamo i contenuti
            
            // questo è un titolo con corpo H2 aggiunto al PDF con l'apposito metodo
            _ = pdf.addH2("\(self.reteWiFi!.tipoAutenticazioneScelto) : \(self.reteWiFi!.password)")
            
//            // questo è un testo aggiunto al PDF con l'apposito metodo
//            _ = pdf.addBodyText(" From its earliest conception, Swift was built to be fast. Using the incredibly high-performance LLVM compiler, Swift code is transformed into optimized native code that gets the most out of modern hardware. The syntax and standard library have also been tuned to make the most obvious way to write your code also perform the best. Swift is a successor to both the C and Objective-C languages. It includes low-level primitives such as types, flow control, and operators. It also provides object-oriented features such as classes, protocols, and generics giving Cocoa and Cocoa Touch developers the performance and power they demand. ")
            
            _ = pdf.addView(self.immagineQRCode)

            // salviamo il PDF nella cartella tmp e con un nome standard, il metodo ci restituisce il percorso
            let path = pdf.writePDFWithoutTableOfContents()
            
            // toriamo al thread principale per fare la copia del file e aprire quick look
            DispatchQueue.main.async(execute: {
                // codice eseguito sul thread principale
                
                // controlliamo che il file esista
                if FileManager.default.fileExists(atPath: path) == true {
                    // se esiste creiamo il percorso del vero file
                    let filePath = self.cartellaDocuments() + "/ilPdf.pdf"
                    
                    print(filePath) // stampiamo il percorso in console
                    
                    // controlliamo se esiste già e nel caso lo facciamo secco
                    if FileManager.default.fileExists(atPath: filePath) {
                        try? FileManager.default.removeItem(atPath: filePath)
                        // se non facciamo questo non riesce a spostare il nuovo file dalla cartella temp
                        // questo viene fatto per semplificare al massimo
                        // se no dovevo metterci un button x eliminare il file
                        // ma in una vera App ogni PDF ha un nome diverso e quindi il problema è diverso (in quel caso bisognerà controllare se esiste e nel caso avverire l'utente che non ci possono essere 2 file con lo stesso nome)
                    }
                    
                    // ed in questo try catch copiamo il file nella carrella documents
                    do {
                        // facciamo la copia
                        try FileManager.default.copyItem(atPath: path, toPath: filePath)
                        
                        // se ce la fa allora...
                        
                        // facciamo secca la copia nella cartella tmp
                        try? FileManager.default.removeItem(atPath: path)
                        
                        // questo è il modo con cui in iOS si può usare quickLoook
                        // serve il delegato ed i due metodi che trovate in basso
                        // facciamo l'istanza di QuickLook
                        let previewer = QLPreviewController()
                        // impostiamo il datasource (come per le tableview)
                        previewer.dataSource = self
                        // impostiamo il primo file come indice 0
                        previewer.currentPreviewItemIndex = 0
                        // presentiamo quicklook
                        self.present(previewer, animated: true, completion: nil)
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            })
        }
    }
    
    @IBAction func creaPDF2tipo(_ sender: UIBarButtonItem) {
        generatePDF()
    }
    func generatePDF() {
    //        let pdf = PDFGenerator(format: .a4)
    //        
    //        let tableData: [[String]] = [
    //            ["",    "Company",                     "Contact",              "Country"],
    //            ["1",    "Alfreds Futterkiste",         "Maria Anders",         "Germany"],
    //            ["2",    "Berglunds snabbköp",          "Christina Berglund",   "Sweden"],
    //            ["3",    "Centro comercialMoctezuma",   "Francisco Chang",      "Mexico"],
    //            ["4",    "Ernst Handel",                "Roland Mendel",        "Austria"],
    //            ["5",    "Island Trading",              "Helen Bennett",        "UK"],
    //            ["6",    "Königlich Essen",             "Philip Cramer",        "Germany"],
    //            ["7",    "Laughing Bacchus",            "Yoshi Tannamuri",      "Canada"],
    //            ["8",    "Magazzini Alimentari",        "Giovanni Rovelli",     "Italy"],
    //            ["9",    "Centro comercialMoctezuma",   "Francisco Chang",      "Mexico"],
    //            ["10",    "Ernst Handel",                "Roland Mendel",        "Austria"],
    //            ["11",    "Island Trading",              "Helen Bennett",        "UK"],
    //            ["12",    "Königlich Essen",             "Philip Cramer",        "Germany"],
    //            ["13",    "Laughing Bacchus",            "Yoshi Tannamuri",      "Canada"],
    //            ["14",    "Magazzini Alimentari",        "Giovanni Rovelli",     "Italy"],
    //            ["15",    "Centro comercialMoctezuma",   "Francisco Chang",      "Mexico"],
    //            ["16",    "Ernst Handel",                "Roland Mendel",        "Austria"],
    //            ["17",    "Island Trading",              "Helen Bennett",        "UK"],
    //            ["18",    "Königlich Essen",             "Philip Cramer",        "Germany"],
    //            ["19",    "Laughing Bacchus",            "Yoshi Tannamuri",      "Canada"],
    //            ["20",    "Magazzini Alimentari",        "Giovanni Rovelli",     "Italy"],
    //            ["21",    "Company",                     "Contact",              "Country"]
    //        ]
    //        let tableAlignment: [[TableCellAlignment]] = [
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left],
    //            [.center, .left, .center, .left]
    //        ]
    //        let tableWidth: [CGFloat] = [
    //            0.08, 0.4, 0.251, 0.251
    //        ]
    //        
    //        let tableStyle = TableStyleDefaults.simple
    //        tableStyle.setCellStyle(row: 2, column: 3, style: TableCellStyle(fillColor: .yellow, textColor: .blue, font: UIFont.boldSystemFont(ofSize: 18)))
    //        tableStyle.setCellStyle(row: 20, column: 1, style: TableCellStyle(fillColor: .yellow, textColor: .blue, font: UIFont.boldSystemFont(ofSize: 18)))
    //        pdf.addTable(data: tableData, alignment: tableAlignment, relativeColumnWidth: tableWidth, padding: 8, margin: 0, style: tableStyle)
    //        
    //        let url = pdf.generatePDFfile("Pasta with tomato sauce")
    //        (self.view as? UIWebView)?.loadRequest(URLRequest(url: url))
    }
    // cartella documents
    func cartellaDocuments() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0] as String
    }
    //cartella documents come URL
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // QuickLook Data Source (QLPreviewControllerDataSource)
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let filePath = cartellaDocuments() + "/ilPdf.pdf"
        let urlo = URL(fileURLWithPath: filePath)
        return urlo as QLPreviewItem
    }

    // MARK: - Navigazione
    
    //SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //se il nome del segue è modifica
        if segue.identifier == "modifica" {
            //estraiamo il controller di destinazione
            let controller = (segue.destination as! UINavigationController).topViewController as! AddViewController
            //e gli passiamo la rete wiFi da modificare
            controller.reteWiFiDaModificare = reteWiFi
        }
    }
    
    
    //*** MODIFICA TODAY ***\\
    func aggiornaInterfacciaConIndex(_ index:Int) {
        //passiamo la rete che arriva dal widget
        let wifiWidget = DataManager.shared.storage[index]
        //aggiorniamo la view
        mostraDatiDellaReteWifi(wifiWidget)
    }
  
   
    //*** MODIFICA 3D TOUCH ***\\
    // questo metodo serve per mostrare sotto alla preview dei pulsanti con delle azioni
    override var previewActionItems: [UIPreviewActionItem] {
    
        
        // creaimo un pulsante / azione per condividere la rete
        let shareAction = UIPreviewAction(title: NSLocalizedString("Share", comment: ""), style: .default) { (previewAction, viewController) in
   
            // usiamo il solito if let per capire se abbiamo la refernza del ListController
            // (la cui var nel DataManager si chiama mainController)
            if let mainVC = DataManager.shared.listCont {
                
                guard let wifiok = self.reteWiFi else { return }
                
                // creiamo e mostriamo il pannello standard della condivisione
                let oggetti = ["Hi this is the QrCode to access Network: ", wifiok.ssid, wifiok.immagineQRFinale] as [Any]
                let act = UIActivityViewController(activityItems: oggetti, applicationActivities: nil)
                
                // poichè solo un controller può presentare un controller e la preview del 3D Touch non lo è...
                // lo presentiamo dal ListController, a questo è servito if let maninVC = bla bla bla
                mainVC.present(act, animated: true, completion: nil)
            }
        }
        
        // creaimo un pulsante / azione per cancellare la rete
        let deleteAction = UIPreviewAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (previewAction, viewController) in
            // estraggo la rete dall'array
            let reteWiFiDaEliminare = DataManager.shared.storage[self.indice]
            // eliminiamo la rete da Spotlight
            DataManager.shared.eliminaReteDaSpotlight(reteWiFiDaEliminare)
            // a questo serve la var indice creata in questo controller e riempita nella preview del 3D Touch
            DataManager.shared.storage.remove(at: self.indice)
            
            // salviamo il nuovo array senza la pizza cancellata
            DataManager.shared.salvaReteWiFi()
            
            //*** MODIFICA TODAY ***\\
            // per poter compilare il file DataManager sia con l'App che con la Today Extension la var mainController...
            // è stata modificata e non è più di tipo ListController, ma è il padre di tutti i controller...
            // ovvero UIViewController
            // ecco perchè nel seguente codice facciamo il downcast as!
            (DataManager.shared.listCont as? ListController)?.tableView.reloadData()
        }
        
        // restituiamo le 3 istanze di UIPreviewAction che abbiamo creato
        return [shareAction, deleteAction]
    }
    
    //MARK: - Metodi
    
    func condividi(){
        //guardia di controllo
        guard let wifiOK = reteWiFi else {return}
        //snippet sw_avc
        
        let oggetti : [Any] = ["Ti invio il codice QR per accesso alla rete " + wifiOK.ssid, wifiOK.immagineQRFinale]
        let act = UIActivityViewController(activityItems: oggetti, applicationActivities: nil)
        
        present(act, animated: true, completion: nil)
    }
    
    //MARK: - Metodi Mail
    
    func inviaMailConReteAttuale() {
        //Se è possibile ottenere l'istanza attuale della rete
        if let reteMail = reteWiFi {
            //solo se è possibile passare a Data il QRCode
            guard let immaData : Data = UIImageJPEGRepresentation(reteMail.immagineQRFinale, 1.0) else {return}
            //creiamo una nuova istanza di mail
            let mailconfigurataVC = MFMailComposeViewController()
            //applichiamo il delegato
            mailconfigurataVC.mailComposeDelegate = self
            //configuriamo i dati della mail
            mailconfigurataVC.setSubject("\(reteMail.ssid)")
            mailconfigurataVC.setMessageBody("Hi, I'm sending you this Network \(reteMail.ssid), Password: \(reteMail.password).\nKeep the QRCode pressed for two seconds to show import options", isHTML: false)
            mailconfigurataVC.addAttachmentData(immaData, mimeType: "image/png", fileName: "myQrToAdd")
           //se è possibile inviare mail
            if MFMailComposeViewController.canSendMail(){
                //mostra il controller
                self.present(mailconfigurataVC, animated: true, completion: nil)
            } else {//altrimenti manda l'alert apposito
                self.mandaAlertErroreCondivisioneFallita()
            }
        }
    }
    
    //alert relativo ad impossibilità invio mail
    func mandaAlertErroreCondivisioneFallita () {
        let erroreMailAlert = UIAlertController(title: "SORRY", message: "We could not send your message because your device has no default mail configured or you canceled", preferredStyle: .alert)
        erroreMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(erroreMailAlert, animated: true, completion: nil)
       
    }
    //quando l'utente conferma l'invio della mail
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //chiudiamo il controller
        controller.dismiss(animated: true, completion: nil)
        //se l'invio è possibile e va a buon fine o viene annullato dall'utente OK,
        //altrimenti manda l'alert
        if result != MFMailComposeResult.sent && result != MFMailComposeResult.cancelled {
            mandaAlertErroreCondivisioneFallita()
        }
        
    }
    
    //MARK: - Metodi Invio Messaggio
    
    
    
    func inviaMessaggio () {
        if MFMessageComposeViewController.canSendText() {
        //se l'acquisizione dei dati della rete avviene
        if let wifiMessaggio = reteWiFi {
        //solo se è possibile passare a Data il QRCode
        guard let immaData : Data = UIImagePNGRepresentation(wifiMessaggio.immagineQRFinale) else  {return}
        //se è possibile inviare messaggi
        
            //componiamo il controller Messaggi che si presenterà all'utente
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            controller.addAttachmentData(immaData, typeIdentifier: "image/.png", filename: "image.png")
            controller.body = "Hi, I'm sending you this Network \(wifiMessaggio.ssid), Password: \(wifiMessaggio.password).\nKeep the QRCode pressed for two seconds to show import options"
            
            //procediamo alla presentazione fisisca del controller
            present(controller, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //chiudi il controller
        controller.dismiss(animated: true, completion: nil)
       
        
        self.dismiss(animated: true, completion: nil)

        //Se impossibile inviare messaggi mandare l'alert

        if !MFMessageComposeViewController.canSendText() {

            controller.dismiss(animated: true, completion: nil)
            //Se impossibile inviare messaggi mandare l'alert
            mandaAlertErroreCondivisioneFallita()
        }
    }
    
    
    
    

    
}
