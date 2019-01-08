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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dialogView: DesignableView!
    @IBOutlet weak var dismissButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       panToClose.setGestureRecognizer()
        loadingPolicyLabel.text = loc("LOADING_PRIVACY")
        dismissButton.setTitle(loc("CLOSE_BUTTON"), for: .normal)
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
        panToClose.animateDialogDisappearAndDismiss(panToClose!.tapGestureRecognizer)

    }
    
}

extension PrivacyViewController : WKNavigationDelegate {

    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        let foundError = error as NSError
        
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        loadingPolicyLabel.text =  { () -> String in
            switch  foundError.code {
            case -1001:
                return loc("ERROR_1001")
            case -1003:
                return loc("ERROR_1003")
            case -1100:
                return loc("ERROR_1100")
            case -1009:
                return loc("ERROR_1009")
            default:
                return loc("ERROR_1009")
            }
        }()
      
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //by disabling panGesture on page loaded the page will get dismissed only
        //touching outside of the dialogView
        //and the webKitView will Scroll correctly
        panToClose.panGestureRecognizer.isEnabled = false
        panToClose.tapGestureRecognizer.isEnabled = true
        self.activityIndicator.stopAnimating()
        loadingView.isHidden = true
        
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: 30), animated: true)
    }
    
 
}
