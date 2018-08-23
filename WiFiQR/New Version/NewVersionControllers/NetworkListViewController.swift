//
//  NetworkListViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 23/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class NetworkListViewController: UIViewController {

    var isStatusBarHidden : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Avendo comunicato all'applicazione che la barra è nascosta
        super.viewDidAppear(true)
        //prima che la view appaia facciamo si che la barra venga mostrata
        isStatusBarHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    //MARK: GESTIONE DELLA STATUS BAR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        //la barra segue le nostre imposizioni
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        //tipo di animazione per apparizione sparizione della barra
        return .fade
    }

    

}

extension NetworkListViewController {
    
    
    
}

extension NetworkListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNetworkDetail" {
            if let destination = segue.destination as? NetworkDetailViewController {
                //modifichiamo la var
                isStatusBarHidden = true
                //animiamo la sparizione della status bar
                UIView.animate(withDuration: 0.5, animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            }
        }
    }
}

extension NetworkListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkListCell", for: indexPath)
        
        cell.textLabel?.text = "This is a test"
        
        return cell
        
    }
    
    
    
    
    
}
