//
//  QrCodeNotRecognizedViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 03/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import MessageUI

class QrCodeNotRecognizedViewController: UIViewController {
    
    var unsupportedString : String?
    var unsupportedImage : UIImage?
    
    var shareRecipient : [String] = ["silvicardo@gmail.com"]
    var shareSubject : String = "Support request"
    var textForShare : String = "Hi,\nthis QRCode is not supported by the app but is actually representing a network, please include it. Thanks"
    @IBOutlet var panToClose: InteractionPanToClose!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panToClose.setGestureRecognizer()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (CoreDataManagerWithSpotlight.shared.scanCont as? QRScannerViewController)?.sessioneDiCattura.startRunning()
    }

    @IBAction func dismissButtonTapped(_ sender: UIButton) {
       
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func shareWithUsButtonTapped(_ sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else { return }

        guard let notValidString = self.unsupportedString,
            let notValidImage = self.unsupportedImage,
            let imageData = notValidImage.jpegData(compressionQuality: 1.0) else { return }
        
        let mailController = prepareMFMailComposeViewControllerWith(qrstring: notValidString, unsupportedImage: imageData)
        
        present(mailController, animated: true, completion: nil)
        
    }
    
    
}

//MARK: MAIL METHODS
extension QrCodeNotRecognizedViewController : MFMailComposeViewControllerDelegate {
    
    func prepareMFMailComposeViewControllerWith(qrstring: String, unsupportedImage: Data) -> MFMailComposeViewController {
        
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.addAttachmentData(unsupportedImage, mimeType: "image/png", fileName: "myQrToAdd")
        controller.setSubject(shareSubject)
        controller.setToRecipients(shareRecipient)
        controller.setMessageBody(textForShare + qrstring, isHTML: false)
        
        return controller
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //chiudiamo il controller
        controller.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
        //se l'invio è possibile e va a buon fine o viene annullato dall'utente OK,
        //altrimenti manda l'alert
        if result != MFMailComposeResult.sent && result != MFMailComposeResult.cancelled {
            
        }
    }
}
