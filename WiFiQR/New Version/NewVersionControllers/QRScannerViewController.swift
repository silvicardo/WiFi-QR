//
//  QRScannerViewController.swift
//  WiFiQR
//
//  Created by riccardo silvi on 22/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

class QRScannerViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension QRScannerViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 20
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestInLibraryCell", for: indexPath) as! LatestInLibraryCollectionViewCell
        cell.latestPicImageView.image = UIImage(named: "QRStarter")
        return cell
    }
    
    
    
    
}
