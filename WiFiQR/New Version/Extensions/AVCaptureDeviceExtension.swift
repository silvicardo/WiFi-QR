//
//  AVCaptureDeviceExtension.swift
//  WiFiQR
//
//  Created by riccardo silvi on 01/07/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import AVFoundation

// MARK: - Metodi accessori fotocamera

extension AVCaptureDevice {
    
    func attivaAutofocus (){
        //se dispositivo predefinito di cattura è disponibile a ripresa video
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        //attiviamo l'autofocus
        try! device.lockForConfiguration()
        device.focusMode = .continuousAutoFocus
        device.unlockForConfiguration()
        print("autofocus attivo")
    }
    
    func modalitaTorcia(flashOff: Bool) {
        //se dispositivo predefinito di cattura è disponibile a ripresa video
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        //se il dispositivo ha torcia
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                //se il flash è spento
                if flashOff == true {
                    //accendilo
                    device.torchMode = .on
                } else {
                    //altrimento spegnilo
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("La Torcia non può essere utilizzata")
            }
        } else {
            print("Nessuna Torcia disponibile")
        }
    }
    
}
