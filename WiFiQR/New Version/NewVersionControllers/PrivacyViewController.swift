//
//  PrivacyViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 01/10/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var panToClose: InteractionPanToClose!
    @IBOutlet weak var loadingView: DesignableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingPolicyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panToClose.setGestureRecognizer()
        loadingPolicyLabel.text = loc("LOADING_PRIVACY")
        activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        
        //per l'esempio puntiamo la pagina di gestione del router come url da caricare
        let url = URL(string: loc("PRIVACY_POLICY"))!
        //creiamo una request per l'url del router
        let request = URLRequest(url: url)
        //A SOLO SCOPO D'ESEMPIO: mostriamo la webview
        //carichiamo la request
        webView.load(request)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        panToClose.animateDialogAppear()
        
    }
   
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension PrivacyViewController : WKNavigationDelegate {

    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error._code == -1001 { // TIMED OUT:
            
            // CODE to handle TIMEOUT
            print("Time Out")
            
        } else if error._code == -1003 { // SERVER CANNOT BE FOUND
            
            // CODE to handle SERVER not found
             print("SERVER CANNOT BE FOUND")
        } else if error._code == -1100 { // URL NOT FOUND ON SERVER
            
            // CODE to handle URL not found
             print("URL NOT FOUND ON SERVER")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        loadingView.isHidden = true
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: 30), animated: true)
    }
 
}
