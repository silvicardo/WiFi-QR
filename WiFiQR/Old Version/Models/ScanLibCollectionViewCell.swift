//
//  ScanLibCollectionViewCell.swift
//  WiFiQR
//
//  Created by riccardo silvi on 27/02/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class ScanLibCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelSSID: UILabel!
    @IBOutlet weak var imageWiFiQRCode: UIImageView!
    @IBOutlet weak var labelAuthentication: UILabel!
    @IBOutlet weak var labelPassword: UILabel!
    @IBOutlet weak var imageCheckEditing: UIImageView!
    
    //variabile per tenere traccia dello stato di editing
    var isEditing : Bool = false {
        didSet {
            //imageCheckEditing è nascosta quando non siamo in EditingMode
            imageCheckEditing.isHidden = !isEditing
            
        }
    }
    //quando una cella è selezionata
    override var isSelected: Bool {
        didSet {
            //se siamo in EditingMode
            if isEditing {
                //l'immagine di imageCheckEditing riflette lo status di selezione della cella
                //se la cella è selezionata e quindi isSelected da True mostrerà l'immagine"checked" e viceversa
                imageCheckEditing.image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
            } 
            //altrimenti non fare nulla
        }
    }
    
}
