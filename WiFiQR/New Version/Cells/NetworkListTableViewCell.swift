//
//  NetworkListTableViewCell.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class NetworkListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var qrcodeImageView : UIImageView!
    
    @IBOutlet weak var qrcodewChRImageView : UIImageView!
    
    @IBOutlet weak var networkSsidLabel : UILabel!
    
    @IBOutlet weak var networkWcHrProtectionLabel : UILabel!
    
    @IBOutlet weak var networkWcHrIsHiddenLabel : UILabel!
    
    @IBOutlet weak var networkProtectionLabel: DesignableLabel!
    
    @IBOutlet weak var networkVisibilityLabel: DesignableLabel!
    
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
