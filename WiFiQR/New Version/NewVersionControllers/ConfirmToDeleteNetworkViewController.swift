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
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var confirmDeleteButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var network : WiFiNetwork?
    
    var index : Int?
    
    let deletionMessage = loc("SURE_TO_DELETE")
    
    weak var delegate : ConfirmToDeleteVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panToClose.setGestureRecognizer()
        
        //Button Localization
        cancelButton.setTitle(loc("DISMISS_BUTTON"), for: .normal)
        confirmDeleteButton.setTitle(loc("REMOVE_BUTTON"), for: .normal)
        
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
       
        
        CoreDataStorage.mainQueueContext().delete(wifiNetwork)
        
         CoreDataManagerWithSpotlight.shared.storage.remove(at: networkIndex)
        
        CoreDataStorage.saveContext(CoreDataStorage.mainQueueContext())
        
        CoreDataManagerWithSpotlight.shared.deleteFromSpotlightBy(ssid: ssid)
        
        guard let listController = (CoreDataManagerWithSpotlight.shared.listCont as? NetworkListViewController) else {return}
        
//        listController.searchController.searchBar.text? = ""
        
//        listController.searchController.searchBar.resignFirstResponder()
//        listController.searchController.searchBar.endEditing(true)
        listController.searchController.isActive = false
//        listController.tabBarShouldReset = false
        listController.networksTableView.reloadData()
        
        dismiss(animated: true,completion: {
            if let delegate = self.delegate, let button = sender as? UIButton {
                delegate.confirmToDelete(self, didTapDeleteButton: button)
            }
        })
            
           
        }
        
       
    
    
    
}
