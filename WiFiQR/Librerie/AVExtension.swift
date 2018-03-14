//
//  AVExtension.swift
//  WiFiQR
//
//  Created by riccardo silvi on 27/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import AVFoundation

public extension AVCaptureSession {
    
    
    //******FUNZIONE PER AVVIO E STOP SESSIONE DI CATTURA AV PER ACQUISIZIONE QR******/
    
    func sessionAVStartOrStop () {
        
        if isRunning != true {
            startRunning()
        } else {
            stopRunning()
        }
        
    }
    
    func startOrStopEAzzeraFrame (seshAttuale: AVCaptureSession, frameView: UIView) {
        
        seshAttuale.sessionAVStartOrStop()
        //aggiorna le dimensioni del frame  e adattalo ai bordi dell'oggetto rilevato
        frameView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
    }
    
}
