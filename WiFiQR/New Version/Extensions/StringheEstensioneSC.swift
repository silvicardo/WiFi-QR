//
//  StringheEstensioneSC.swift
//  leMieEstensioniSpazioTest
//
//  Created by riccardo silvi on 28/01/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import Foundation
import UIKit



//****CAST****//
public extension NSString {
    // Cast NSString to String
    var swiftStringa: String {
        return self as String
    }
    
}


//***PROPRIETA****//

public extension String {
    // Conteggio caratteri
    var lunghezza: Int {
        return self.count
    }
    
    //solo iniziali di ogni parola
    var iniziali: String {
        return components(separatedBy: .whitespaces)
            .compactMap { $0.first }
            .map { String.init($0).uppercased() }
            .joined(separator: "")
    }
    
    //Underscore su ogni lettera
    var c_o_n_u_n_d_e_r_s_c_o_r_e : String {
        var charactersToRemove = CharacterSet.alphanumerics.inverted
        charactersToRemove.remove(charactersIn: " ")
        
        let result = components(separatedBy: charactersToRemove).joined(separator: "")
        return result.replacingOccurrences(of: " ", with: "_").lowercased()
    }
    
    var isEmailAddress: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: lunghezza))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    
    // Controlla se la conversione a numero riesce
    
    var isNumero: Bool {
        return (NumberFormatter().number(from: self) != nil) ? true : false
    }
}


//***STAMPA IN CONSOLE***//

public extension String {
    
    //stampa con prefisso a scelta
    
    func stampa(conPrefisso: String) {
        print("\(conPrefisso) \(self)")
    }
    
    //stampa risultato Bool con prefisso
    
    func stampa(risultatoCondizione: Bool, conPrefisso:String){
        
        print("\(conPrefisso) : \(risultatoCondizione)")
    }
}

//***COMPARA VERSIONI DI STRINGHE***//

public extension String {
    
    
    func isUgualeA(_ vs: String) -> Bool {
        return self.compare(vs, options: .numeric, range: nil, locale: nil) == .orderedSame
    }
    
    func isPiuCortaDi(_ vs: String) -> Bool {
        return self.compare(vs, options: .numeric, range: nil, locale: nil) == .orderedDescending
    }
    
    func isUgualeOPiuCortaDi(_ vs: String) -> Bool {
        return self.compare(vs, options: .numeric, range: nil, locale: nil) != .orderedAscending
    }
    
    func isPiuLungaDi(_ vs: String) -> Bool {
        return self.compare(vs, options: .numeric, range: nil, locale: nil) == .orderedAscending
    }
    
    func isUgualeOpiuLungaDi(_ vs: String) -> Bool {
        return self.compare(vs, options: .numeric, range: nil, locale: nil) != .orderedDescending
    }
}

//***CONTROLLO LUNGHEZZA STRINGA SECONDO PARAMETRO UTENTE***//

public extension String {
    
    // Controlla se la stringa è più lunga di
    func piuLungaDiTotCaratteri(_ caratteri: Int) -> Bool {
        if lunghezza < caratteri {
            return false
        }
        return true
    }
    
    // Controlla se la stringa è più lunga di
    func piuCortaDiTotCaratteri(_ caratteri: Int) -> Bool {
        if lunghezza > caratteri {
            return false
        }
        return true
    }
    //Controlla se la stringa ha tot caratteri
    func haTotCaratteri(_ caratteri: Int) -> Bool {
        if lunghezza != caratteri {
            return false
        }
        return true
    }
    //Controlla se la stringa è compresa tra tot caratteri
    func compresaTraToTCaratteri(tra inizio: Int, e fine: Int) -> Bool{
        if lunghezza > inizio && lunghezza < fine {
            return true
        }
        return false
    }
}

//***MANIPOLAZIONE STRINGA***//

public extension String {
    
    // Produce una Stringa con spazi e a capo "\n" rimossi
    mutating func rimuoviSpazieACapo(){
        let noSpazi = self.replacingOccurrences(of: " ", with: "")
        self = noSpazi.replacingOccurrences(of: "\n", with: "")
    }
    mutating func rimuoviACapo() {
        self = self.replacingOccurrences(of: "\n", with: "")
    }
    
    // Produce una Stringa con spazi rimossi
    mutating func rimuoviSpazi(){
        
        self = self.replacingOccurrences(of: " ", with: "")
        
    }
    
    //Prende stringa o carattere e lo toglie dalla stringa
    mutating func rimuoviParteStringa(stringa daSostituire: String){
        
        self = self.replacingOccurrences(of: daSostituire, with: "")
        
    }
    // INVERTE i caratteri della stringa
    mutating func invertiCaratteri() {
        self = String(self.reversed())
        
    }
    //
    //    //Stringa con spazi e a capo rimossi e tutto minuscolo
    
    mutating func rimuoviSpaziEaCapoeTuttoMinuscolo() {
        self.rimuoviSpazieACapo()
        self = self.lowercased()
        
    }
    //
    //    //Stringa con spazi e a capo rimossi e tutto maiuscolo
    
    mutating func rimuoviSpaziEaCapoeTuttoMaiuscolo() {
        self.rimuoviSpazieACapo()
        self = self.uppercased()
        
    }
    
}

//***CONVERSIONE AD ALTRI TIPI****//

public extension String {
    
    // DA String a NSString
    var NSStringa: NSString {
        return self as NSString
    }
    
    // Da String a Int
    
    func trasformaInInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    // Da String a Double
    
    func trasformaInDouble() -> Double? {
        
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    // Da String a Float
    func trasformaInFloat() -> Float? {
        
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    
    ///Da String to Bool
    func trasformaInBool() -> Bool? {
        var stringaManipolata = self
        stringaManipolata.rimuoviSpaziEaCapoeTuttoMinuscolo()
        if stringaManipolata == "true" || stringaManipolata == "false" {
            return (stringaManipolata as NSString).boolValue
        }
        return nil
    }
    
    // Da Stringa a Data
    func trasformaInDato() -> Data {
        return self.data(using: String.Encoding.utf8)!
    }
    
    // restituisce una data OPTIONAL e ora da una Stringa
    func formattaComeDataEOra()-> Date? {
        let convertitoreInFormatoData = DateFormatter()
        convertitoreInFormatoData.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        return convertitoreInFormatoData.date(from: self)
    }
    
    //restituisce una data OPTIONAL che indica solo il giorno
    func formattaComeDataSoloGiorno(format: String = "yyyy-MM-dd") -> Date? {
        
        let convertitoreInFormatoData = DateFormatter()
        
        convertitoreInFormatoData.timeZone = .current
        convertitoreInFormatoData.dateFormat = format
        
        return convertitoreInFormatoData.date(from: self)
    }
    //calcola tempo di lettura a partire da un valore predefinito
    func calcolaTempoDiLettura(VelocitaLettura: Double = 250) -> Double {
        let parole = components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
        return Double(parole.count) / VelocitaLettura
    }
    
}

//***MANIPOLAZIONE DI UNA SECONDA STRINGA IN BASE A CONDIZIONE SU STRINGA IN ENTRATA***//

public extension String {
    
    //Se la stringa esaminata contiene un parametro
    //la seconda stringa diventa due, se falso diventa tre
    //Attenzione!!! CASESENSITIVE
    
    func seContieneSecondaStringaDiventaDueOppureTre( seContiene: String, secondaStringa: inout String, diventa due: String, altrimenti tre: String) {
        
        secondaStringa = self.contains(seContiene) ? due : tre
        
    }
    
    //Solo Se la stringa esaminata contiene un parametro
    //nella seconda stringa sostituiamo occorrenze di "a" con "b"
    //Attenzione!!! CASESENSITIVE
    
    func seContieneInSecondaStringaRimpiazzaOccorrenzeDiAconB(seContiene: String, seconda Stringa: inout String, a: String, b: String) {
        if self.contains(seContiene){
            Stringa = Stringa.replacingOccurrences(of: a, with: b)
        } else {
            print("nessun occorrenza trovata")
        }
    }
}

//****CREAZIONE E MANIPOLAZIONI ARRAY DI STRINGHE

public extension String {
    
    //Crea un array di Stringhe secondo un parametro e ne rimuove se presente un altro parametro
    
    func creaArrayStringhe(tagliaPer: String, rimuovi seEsiste: String ) ->[String]{
        var perArray = self
        perArray.rimuoviParteStringa(stringa: seEsiste)
        return perArray.creaArrayStringheInBaseA(tagliaPer)
    }
    
    //Crea un array di Stringhe tagliando la stringa iniziale secondo un determinato parametro
    
    func creaArrayStringheInBaseA(_ taglio: String ) -> [String] {
        return self.components(separatedBy: taglio)
    }
    
}


//****COPIA LA STRINGA PER LA FUNZIONE COPIA/INCOLLA****//

public extension String {
    
    func aggiungiSuPasteboard() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self
    }
}

//****CONTROLLO STRINGA SECONDO PARAMETRO UTENTE****//

//Controlla secondo un parametro modificabile e non secondo parametri di sistema

public extension String {
    
    //Controlla secondo un parametro modificabile e non secondo parametri di sistema
    func validaStringaSecondo(Parametro: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", Parametro)
        return predicate.evaluate(with: self)
    }
    ///***ESEMPI DI UTILIZZO***//
    //1.
    // Controlla se si tratta di un indirizzo mail valido
    //alternativa alla proprietà isEmailAddress
    
    func isIndirizzoMailValido() -> Bool {
        
        let emailParametro = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        return validaStringaSecondo(Parametro: emailParametro)
    }
    //2.
    //Controlla se numero di telefono valido
    
    func isNumeroTelefonoValido() -> Bool {
        let numeroParametro = "^1\\d{10}$"
        
        return validaStringaSecondo(Parametro: numeroParametro)
    }
}

//***EMOJI***//

public extension String {
    
    /// Controlla se la stringa contiene Emoji
    
    func contieneEmoji() -> Bool {
        for i in 0...lunghezza {
            let c: unichar = (self as NSString).character(at: i)
            if (0xD800 <= c && c <= 0xDBFF) || (0xDC00 <= c && c <= 0xDFFF) {
                return true
            }
        }
        return false
    }
    
    //ESEMPIO
    //var emostring = "🕹"
    //print(emostring.encodeEmoji) -> Optional("\\ud83d\\udd79")
    
    var encodeEmoji: String? {
        let encodedStr = NSString(cString: self.cString(using: String.Encoding.nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue)
        return encodedStr as String?
    }
    //ESEMPIO
    // let emostringa = "\\ud83d\\udd79"
    //print(emostringa.decodeEmoji) -> "🕹"
    var decodeEmoji: String {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if data != nil {
            let valueUniCode = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue) as String?
            if valueUniCode != nil {
                return valueUniCode!
            } else {
                return self
            }
        } else {
            return self
        }
    }
    
}

