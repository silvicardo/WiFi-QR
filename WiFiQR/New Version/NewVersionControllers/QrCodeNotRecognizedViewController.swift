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
    
    //MARK: - Passing Variables from QRScannerViewController
    
    var unsupportedString : String?
    
    var unsupportedImage : UIImage?

    //MARK: - Strings contained in this Controller
    
    let shareRecipient : [String] = ["silvicardo@gmail.com"]
    
    let shareSubject : String = loc("SUPPORT_REQUEST")
    
    let textForShare : String = loc("SEND_NOT_SUPPORTED_CODE")
    
    let netNotFoundLblText : String = loc("QR_NOT_RECOGNIZED_PLEASE_SHARE")
    
    
    //MARK: - Pointers
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let qrScannerController = CoreDataManagerWithSpotlight.shared.scanCont as! QRScannerViewController
    
    var mailController : MFMailComposeViewController?
    
    var mailControllerIsShowing : Bool = false
    
    
    //MARK: - Outlets
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var sendUsQRButton: UIButton!
    
    @IBOutlet weak var notRecognizedQRLabel: UILabel!
    
    //MARK: - Default Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panToClose.setGestureRecognizer()
        
        sendUsQRButton.setTitle(loc("MAIL_THIS_QR"), for: .normal)
        
        dismissButton.setTitle(loc("DISMISS_BUTTON"), for: .normal)
        
        notRecognizedQRLabel.text = netNotFoundLblText
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController

        if tabBarController.selectedViewController == qrScannerController && !mailControllerIsShowing{
            print("SESSION DA DISMISSAL RIPARTITA")
            qrScannerController.resetUIforNewQrSearch()
        qrScannerController.collectionView.invertHiddenAlphaAndUserInteractionStatus()
            qrScannerController.findInputDeviceAndDoVideoCaptureSession()
        } else {
            print("PRESENTING SHAREBYMAIL MFMailViewController")
            
        }
        
    }

    //MARK: - IBActions
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
    
        dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func shareWithUsButtonTapped(_ sender: UIButton) {
    
        guard MFMailComposeViewController.canSendMail() else { return }

        guard let notValidString = self.unsupportedString,
            let notValidImage = self.unsupportedImage,
            let imageData = notValidImage.jpegData(compressionQuality: 1.0) else { return }
        
        mailController = MFMailComposeViewController(qrstring: notValidString, unsupportedImage: imageData,with: shareSubject, with : shareRecipient, with: textForShare,  mailComposeDelegate: self)
    
        present(mailController!, animated: true, completion: nil)
        mailControllerIsShowing = true
    }
    
    
}

//MARK: MAIL EXTENSION + METHODS

extension MFMailComposeViewController {
    
    convenience init(qrstring: String, unsupportedImage: Data,with subject: String, with recipients : [String], with body: String, mailComposeDelegate: MFMailComposeViewControllerDelegate) {
        
        self.init()
        self.mailComposeDelegate = mailComposeDelegate
        self.addAttachmentData(unsupportedImage, mimeType: "image/png", fileName: "myQrToAdd")
        self.setSubject(subject)
        self.setToRecipients(recipients)
        self.setMessageBody(body, isHTML: false)
        
    }

}
extension QrCodeNotRecognizedViewController : MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //chiudiamo il controller
        controller.dismiss(animated: true, completion: nil)
        
        self.mailControllerIsShowing = false
        
        self.dismiss(animated: true, completion: nil)
        //se l'invio è possibile e va a buon fine o viene annullato dall'utente OK,
        //altrimenti manda l'alert
        if result != MFMailComposeResult.sent && result != MFMailComposeResult.cancelled {
            
        }
    }
}
