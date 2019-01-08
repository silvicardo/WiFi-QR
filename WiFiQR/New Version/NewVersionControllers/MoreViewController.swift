//
//  MoreViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 01/10/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UIViewController {
    
    @IBOutlet weak var supportLabel : UILabel!
    
    @IBOutlet weak var supportButton : UIButton!
    
    @IBOutlet weak var privacyButton : UIButton!
    
    @IBOutlet weak var dialogView: DesignableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        supportLabel.text = loc("SUPPORT")
        supportButton.setTitle(loc("ASK_FOR_HELP"), for: .normal)
        privacyButton.setTitle(loc("READ_PRIVACY"), for: .normal)
        
        //FadeIn Dialog-View
        dialogView.isHidden = true
        dialogView.alpha = 0
        
        UIView.animate(withDuration: 0.7, animations: {
            
            self.dialogView.alpha = 1
            self.dialogView.isHidden = false
            
        })
        
    }
    
    //FadeIn Dialog-View everytime viewAppears
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dialogView.isHidden = true
        dialogView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.animate(withDuration: 0.7, animations: {
            
            self.dialogView.alpha = 1
            self.dialogView.isHidden = false
            
        })
        
    }
    
    @IBAction func readPolicyButtonTapped(_ sender : UIButton) {
    
        //open Policy Link in Safari
        performSegue(withIdentifier: "toPrivacyVC", sender: nil)

    }
    
    @IBAction func askSupportButtonTapped(_ sender: UIButton) {
        //Preconfigured Mail
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setSubject(loc("SUPPORT"))
        mailController.setToRecipients([loc("SUPPORT_MAIL")])
        
        present(mailController, animated: true, completion: nil)
    }

}

extension MoreViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //chiudiamo il controller
        controller.dismiss(animated: true, completion: nil)

    
        //se l'invio è possibile e va a buon fine o viene annullato dall'utente OK,
        //altrimenti manda l'alert
        if result != MFMailComposeResult.sent && result != MFMailComposeResult.cancelled {
            
        }
    }
}
