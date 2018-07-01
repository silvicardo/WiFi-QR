//
//  PhotoLibraryManager.swift
//  WiFiQR
//
//  Created by riccardo silvi on 01/07/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryManager {
	
	static let shared = PhotoLibraryManager()
	
    func hasPhotoLibrary(numberOfPhotos : Int) -> PHFetchResult<PHAsset>? {

        let fetchOptions = PHFetchOptions()

        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]

        fetchOptions.fetchLimit = numberOfPhotos

        // Esegue il fetch degli assets secondo i criteri sopra
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

        return fetchResult.count >= numberOfPhotos ? fetchResult :  nil
    }

    func get(nrOfPhotos : Int,from fetchResult: PHFetchResult<PHAsset>,per view: UIView, withCompletionHandler : @escaping (_ images: [UIImage])->()) {

        var images = [UIImage]()

        print("fetchResult.count = \(fetchResult.count)")

        DispatchQueue.main.async(execute: {

            images = self.salva(da: fetchResult, nFoto: nrOfPhotos, per: view)

            //"controllo in console
            print("Acquisite n: \(images.count) Anteprime")

            OperationQueue.main.addOperation {
                withCompletionHandler(images)
            }
        })
    }

    ///Salva in un array di UIImage un determinato numero di Foto a partire dall'ultima creata
    func salva(da fetchResult : PHFetchResult<PHAsset> ,nFoto: Int, per view: UIView) -> [UIImage] {

        var images:[UIImage] = []

        //partiamo da un indice richieste pari a zero
        var requestIndex = 0

        while requestIndex < fetchResult.count {

            // Nota che se la richiesta non è sincrona
            // la requestImageForAsset retituira' sia la vera immagine che
            // la thumbnail; settando synchronous su true restituirà
            // solo la thumbnail
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            // Esegue la image request
            PHImageManager.default().requestImage(for: fetchResult.object(at: requestIndex) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                if let image = image {
                    // Aggiunge l'immagine all'array desiderato
                    images.append(image)

                    requestIndex += 1
                }})

        }
        return images
    }

    
}
