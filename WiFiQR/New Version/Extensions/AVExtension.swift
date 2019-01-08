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
    
    func startOrStopEAzzera(frameView: UIView) {
        
        isRunning ? stopRunning() : startRunning()
        
        //aggiorna le dimensioni del frame  e adattalo ai bordi dell'oggetto rilevato
        frameView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
    }
    
    func stopRemoving(input : AVCaptureDeviceInput, output : AVCaptureMetadataOutput){
        print("Stopping Session + Removing Input and Output")
        self.stopRunning()
        self.removeInput(input)
        self.removeOutput(output)
        
    }
    

    
}
