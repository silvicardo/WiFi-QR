//
//  QRStringa.swift
//  WiFiQR
//
//  Created by riccardo silvi on 10/02/2019.
//  Copyright © 2019 riccardo silvi. All rights reserved.
//

import Foundation

class QRStringa {
    var ssid : String
    var authType : String
    var password : String
    var visibility : String
    
    init (ssid: String = "", authType: String = "", password: String = "", visibility: String = "") {
        self.ssid = ssid
        
        switch authType {
            case "WPA/WPA2" : self.authType = "WPA"
            case "NONE" : self.authType = ""
            default : self.authType = authType
        }
        
        self.password = password
        self.visibility = visibility
    }
    
    func buildQRString() -> String {
        
        var newWiFiString = ""
        
        newWiFiString += { () -> String in
            return "WIFI:S:" + self.ssid + ";"
            }()
        
        
        if self.authType != "" {
            newWiFiString += { () -> String in
                
                return "T:\(self.authType);P:\(self.password);"
                }()
        }
        
        if self.visibility == "true" {
            newWiFiString += { () -> String in
                
                return "H:\(self.visibility);"
                }()
        }
        
        newWiFiString += ";"
        
        
        return newWiFiString
    }

}
