//
//  WiFiConnectionManager.swift
//  WiFiQR
//
//  Created by riccardo silvi on 02/02/2019.
//  Copyright © 2019 riccardo silvi. All rights reserved.
//


import UIKit

import SystemConfiguration.CaptiveNetwork
import AVFoundation
import NetworkExtension


class WiFiConnectionManager : NSObject {

    // MARK: - Singleton

    static let shared = WiFiConnectionManager()
}

// MARK: - Metodi Network WiFi

extension WiFiConnectionManager {
    ///FUNZIONE PER IL RECUPERO DEL NOME DELLA RETE WIFI,
    ///RICORDA: importare SystemConfiguration.CaptiveNetwork
    func retrieveConnectedNetworkSsid() -> String? {
        //la var ssid è una stringa vuota
        var ssidReteAttuale: String?
        //se la costante "interfacce" è un array che contiene una lista
        //di tutte le interfacce monitorate al momento da CaptiveNetworkSupport
        if let interfacce = CNCopySupportedInterfaces() as NSArray? {
            //per ogni "interfaccia" in "interfacce"
            for interfaccia in interfacce {
                //se "infoInterfaccia" = un oggetto di CNCopyCurrentNetworkInfo
                //che restituisce le info (Network Info dictionary)
                //del Network per la specifica interfaccia
                if let infoInterfaccia = CNCopyCurrentNetworkInfo(interfaccia as! CFString) as NSDictionary? {
                    //"ssidd" sarà la stringa corrispondente ala chiave di NetworkInfoDictionary per l'SSID (in formato CFString)
                    ssidReteAttuale = infoInterfaccia[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        //rilascia ssid
        return ssidReteAttuale
    }
    
    ///CREA UNA NEHOTSPOTCONFIGURATION(DA UN ISTANZA DI WiFiModel o INPUT MANUALE)
    func creazioneConfigDiRete(nomeRete: String, password: String, passwordRichiesta: Bool, tipoPassword: String) -> NEHotspotConfiguration {
        
        //Se la rete richiede password procedi altrimenti restituisci
        //una configurazione libera
        guard passwordRichiesta  else { return NEHotspotConfiguration(ssid: nomeRete)}
        
        if tipoPassword == Encryption.wpa_Wpa2 {//WPA/WPA2
            
            return NEHotspotConfiguration(ssid: nomeRete, passphrase: password, isWEP: false)
        }
        //WEP
        return  NEHotspotConfiguration(ssid: nomeRete, passphrase: password, isWEP: true)
        
    }
    
    ///Funzione per recupero Lista Reti in dizionario e stampa in console
    func mostraListaReti() {
        var elencoRetiDisponibili = "";(CNCopySupportedInterfaces() as? [CFString])?.forEach({ elencoRetiDisponibili = (CNCopyCurrentNetworkInfo($0) as? [String : Any])?[kCNNetworkInfoKeySSID as String] as? String ?? ""})
        print(elencoRetiDisponibili)
    }
    
    ///Chiamata della disconnessione da una rete gestita dall'App
    func disconnect (nomeRete: String){
        
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: nomeRete)
    }
}
