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
    
    //controlla che la libreria abbia almeno n foto o almeno una se il valore optional non viene valorizzato
    func hasPhotoLibrary(numberOfPhotos : Int? = nil) -> PHFetchResult<PHAsset>? {
        
        //creaimo opzioni di ricerca
        let fetchOptions : PHFetchOptions = numberOfPhotos != nil  ? fetchByMostRecent(andMaxPhotos: numberOfPhotos) : fetchByMostRecent()
        
        // Esegue il fetch degli assets secondo i criteri sopra
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        switch (numberOfPhotos != nil) {
            
        case (true)      : guard fetchResult.count >= numberOfPhotos! else {return nil}
            
        case (false)     : guard fetchResult.count > 0 else {return nil}
        
         }
    
        return fetchResult
    }
    

    func get(nrOfPhotos : Int,from fetchResult: PHFetchResult<PHAsset>,per view: UIView, withCompletionHandler : @escaping (_ images: [UIImage])->()) {

        var images = [UIImage]()

            print("fetchResult.count = \(fetchResult.count)")

            images = self.salva(da: fetchResult, nFoto: nrOfPhotos, per: view)

            //"controllo in console
            print("Acquisite n: \(images.count) Anteprime")

            withCompletionHandler(images)
        
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

    
    ///se non si imposta un limite foto le options restituiscono l'intera libreria
    func fetchByMostRecent(andMaxPhotos limit : Int? = nil ) -> PHFetchOptions {
        
        //Impostiamo le opzioni di ricerca
        let fetchOptions = PHFetchOptions()
        
        //Dalla foto più recente
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        //Se è stato inserito un numero di foto limite aggiungerlo
        if let amountOfPhotosRequested = limit {
            
            fetchOptions.fetchLimit = amountOfPhotosRequested
        }
        
        return fetchOptions
    }
    
}
