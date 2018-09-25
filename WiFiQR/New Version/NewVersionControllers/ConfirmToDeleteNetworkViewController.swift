//
//  ConfirmToDeleteNetworkViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 25/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

protocol ConfirmToDeleteVCDelegate : class {
    
    func confirmToDelete(_ viewController : ConfirmToDeleteNetworkViewController, didTapDeleteButton button : UIButton)
}

class ConfirmToDeleteNetworkViewController: UIViewController {
    
    @IBOutlet var panToClose: InteractionPanToClose!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var network : WiFiNetwork?
    
    var index : Int?
    
    let deletionMessage = "Are you sure you want to delete : "
    
    weak var delegate : ConfirmToDeleteVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
        CoreDataManagerWithSpotlight.shared.shouldDelete = self
        
        guard let wifi = network,
            let ssid =  wifi.ssid   else {return}
        
        messageLabel.text = deletionMessage + ssid
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        panToClose.animateDialogAppear()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    
    dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
         guard let wifiNetwork = network, let networkIndex = index, let ssid = wifiNetwork.ssid  else {return}
    
        print("cancel ready")
        CoreDataManagerWithSpotlight.shared.storage.remove(at: networkIndex)
        
        CoreDataStorage.mainQueueContext().delete(wifiNetwork)
        
        CoreDataStorage.saveContext(CoreDataStorage.mainQueueContext())
        
        CoreDataManagerWithSpotlight.shared.deleteFromSpotlightBy(ssid: ssid)
        
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.searchController.searchBar.text? = ""
        
        (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController)?.networksTableView.reloadData()
        
        dismiss(animated: true,completion: {
            if let delegate = self.delegate, let button = sender as? UIButton {
                delegate.confirmToDelete(self, didTapDeleteButton: button)
            }
        })
            
           
        }
        
       
    
    
    
}
