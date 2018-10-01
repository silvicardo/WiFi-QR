//
//  NetworkListTableViewCell.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit


protocol NetworkListTableViewCellDelegate : class {
    
    func networkListCell(_  cell : NetworkListTableViewCell, didTapShareButton button : DesignableButton, forNetwork wifiNetwork : WiFiNetwork )
    
    func networkListCell(_ cell : NetworkListTableViewCell, didTapConnectButton button : DesignableButton)
    
    func networkListCell(_ cell : NetworkListTableViewCell, didTapEditButton button : DesignableButton, forNetwork wifiNetwork : WiFiNetwork)
    
    func networkListCell(_ cell : NetworkListTableViewCell, didTapDeleteButton button : DesignableButton, forNetwork wifiNetwork : WiFiNetwork)
    
    func networkListCell(_ cell : NetworkListTableViewCell, didTapShareByMessageButton button : DesignableButton, forNetwork wifiNetwork : WiFiNetwork)
    
    func networkListCell(_ cell : NetworkListTableViewCell, didTapShareByMailButton button : DesignableButton, forNetwork wifiNetwork : WiFiNetwork)
    
}

class NetworkListTableViewCell: UITableViewCell {
    
    var wifiNetwork : WiFiNetwork?
    
    @IBOutlet weak var qrcodeImageView : UIImageView!
    
    @IBOutlet weak var qrcodewChRImageView : UIImageView!
    
    @IBOutlet weak var networkSsidLabel : UILabel!
    
    @IBOutlet weak var networkWcHrProtectionLabel : UILabel!
    
    @IBOutlet weak var networkWcHrIsHiddenLabel : UILabel!
    
    @IBOutlet weak var networkProtectionLabel: DesignableLabel!
    
    @IBOutlet weak var networkVisibilityLabel: DesignableLabel!
    
    @IBOutlet weak var deleteBtnLabel: UILabel!
    @IBOutlet weak var smsBtnLabel: UILabel!
    @IBOutlet weak var mailBtnLabel: UILabel!
    @IBOutlet weak var shareBtnLabel: UILabel!
    @IBOutlet weak var editBtnLabel: UILabel!
    @IBOutlet weak var connectBtnLabel: UILabel!
    
    
    weak var delegate : NetworkListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shareNetworkButtonTapped(_ sender : DesignableButton) {
        
        guard let wifiNetwork = wifiNetwork else {return}
        
        delegate?.networkListCell(self, didTapShareButton: sender, forNetwork : wifiNetwork)
        
    }
    
    
    @IBAction func editNetworkButtonTapped(_ sender : DesignableButton) {
        
        guard let wifiNetwork = wifiNetwork else { return }
        
        delegate?.networkListCell(self, didTapEditButton: sender, forNetwork : wifiNetwork)
        
    }
    
    @IBAction func deleteNetworkButtonTapped(_ sender : DesignableButton) {
        
        guard let wifiNetwork = wifiNetwork else { return }
        
        delegate?.networkListCell(self, didTapDeleteButton: sender, forNetwork : wifiNetwork)
        
    }
    
    @IBAction func connectNetworkButtonTapped(_ sender: DesignableButton) {
        
        delegate?.networkListCell(self, didTapConnectButton: sender)
    }
    
    @IBAction func shareByMessageButtonTapped(_ sender : DesignableButton) {
        
        guard let wifiNetwork = wifiNetwork else { return }
        
        delegate?.networkListCell(self, didTapShareByMessageButton: sender, forNetwork: wifiNetwork)
    }
    
    @IBAction func shareByMailButtonTapped(_ sender : DesignableButton) {
        
        guard let wifiNetwork = wifiNetwork else { return }
        
        delegate?.networkListCell(self, didTapShareByMailButton: sender, forNetwork: wifiNetwork)
    }
    
    
}
