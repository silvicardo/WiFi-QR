//
//  QRScannerClassExtension.swift
//  WiFiQR
//
//  Created by riccardo silvi on 27/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MessageUI
extension QRScannerController {
    

    //***********ALERT CON ACTIONS IMPOSTATE***********//
    func creaAlertNessunMailConfigurataEGestisciAVSession ( sessioneAV: AVCaptureSession,frameView: UIView) -> UIAlertController{
        let erroreMailAlert = UIAlertController(title: "SORRY", message: "We could not prepare your mail because your device has no default mail configured", preferredStyle: .alert)
        erroreMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(erroreMailAlert, animated: true, completion: nil)
        sessioneAV.startOrStopEAzzeraFrame(seshAttuale: sessioneAV, frameView: frameView)
        return erroreMailAlert
    }
    
    func creaAlertCiDispiaceDiNonRicevereUnFeedbackEGestisciAvSession(sessioneAV: AVCaptureSession, frameView:UIView) ->UIAlertController {
        let ciDispiaceMailAlert = UIAlertController(title: "WE ARE SORRY", message: "Feel free to contact us at any time", preferredStyle: .alert)
        ciDispiaceMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            //premuto il tasto ok riparte la sessione di cattura AV
            sessioneAV.startOrStopEAzzeraFrame(seshAttuale: sessioneAV, frameView: frameView)
        }))
       // present(ciDispiaceMailAlert, animated: true, completion: nil)
        return ciDispiaceMailAlert
    }
    
    func creaAlertGraziePerIlFeedbackEGestisciAvSession(sessioneAV: AVCaptureSession, frameView:UIView) ->UIAlertController {
        
        let ringraziamentoMailAlert = UIAlertController(title: "THANKS", message: "Thanks for your support, we'll work on your report", preferredStyle: .alert)
        ringraziamentoMailAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            //premuto il tasto ok riparte la sessione di cattura AV
            sessioneAV.startOrStopEAzzeraFrame(seshAttuale: sessioneAV, frameView: frameView)
        }))
        //present(ringraziamentoMailAlert, animated: true, completion: nil)
        return ringraziamentoMailAlert
        
    }

    
}
