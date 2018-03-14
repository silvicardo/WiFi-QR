//
//  MailExtension.swift
//  WiFiQR
//
//  Created by riccardo silvi on 27/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import MessageUI
import AVFoundation

public extension MFMailComposeViewController {
    
    
    //funzione per creare un MailComposeVC configurato
    func mailCompostaVC(a destinatario: String, oggetto: String, corpo: String) -> MFMailComposeViewController {
        
        let mailConfigurataVC = MFMailComposeViewController()
        mailConfigurataVC.mailComposeDelegate = (self as! MFMailComposeViewControllerDelegate)
        mailConfigurataVC.setToRecipients([destinatario])
        mailConfigurataVC.setSubject(oggetto)
        mailConfigurataVC.setMessageBody(corpo, isHTML: false)
        
        return mailConfigurataVC
    }


        
}

