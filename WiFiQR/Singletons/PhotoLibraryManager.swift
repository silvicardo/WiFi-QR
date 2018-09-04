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

    var requestIndex : Int = 0
    
    // Nota che se la richiesta non è sincrona
    // la requestImageForAsset retituira' sia la vera immagine che
    // la thumbnail; settando synchronous su true restituirà
    // solo la thumbnail
    
    var icloudRequestOptions : PHImageRequestOptions {
        
                let icloudROpt = PHImageRequestOptions()
                icloudROpt.isSynchronous = true //Solo Thumbnail
                icloudROpt.isNetworkAccessAllowed = true//Icloud si
                return icloudROpt
            }
        
    
    
    var localRequestOptions : PHImageRequestOptions {
                let locROpt = PHImageRequestOptions()
                locROpt.isSynchronous = true//Solo thumbnail
                icloudRequestOptions.isNetworkAccessAllowed = false //Icloud No
                return locROpt
            }

    
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

        while requestIndex < nFoto {
   
            let requestOptions = self.localRequestOptions

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
    
    ///Con ciclo while controlla cerca tra le foto codici QR
    ///e nel MAIN THREAD aggiorna la view per tenere informato l'utente del progresso
    //    (v2. function async sistemata)
    func loopaThrough(runQueue: DispatchQueue, completionQueue: DispatchQueue,
        in tutteLeFoto: PHFetchResult<PHAsset>,
        forEachPhoto runQueueActionHandler : @escaping ((_ image: PHAsset, _ requestOptions : PHImageRequestOptions) -> Void),
        afterEachPhotoAction mainQueueHandler: ((_ image: PHAsset)->Void)? = nil,
        with completionHandler: (() -> Void)? = nil ){
        
        runQueue.async {
            var photoAssetDaEsaminare = PHAsset()
            
            //CICLO WHILE
            //finchè l'indice della foto in esame è inferiore del totale foto presenti
            while self.requestIndex < tutteLeFoto.count {
                //CODICE SPECIALE per rilascio memoria ad ogni esecuzione del while loop
                autoreleasepool{
                    
                    let requestOptions = self.localRequestOptions
                    //estraiamo all'indice "requestIndex" il fetchResult come PHAsset
                    photoAssetDaEsaminare = tutteLeFoto.object(at: self.requestIndex)
                    
                    runQueueActionHandler(photoAssetDaEsaminare, requestOptions)
                    
                    self.requestIndex += 1
                }
                
                completionQueue.async {
                    if let atEachPhotoCompletion = mainQueueHandler {
                     atEachPhotoCompletion(photoAssetDaEsaminare)
                    }
                }
               
            }/*Fine While*/
            
            completionQueue.async {
                if let completionHandler = completionHandler {
                 completionHandler()
                //resetta il valore di request Index
                self.requestIndex = 0
                }
            }
        
        }
       
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
    
    func converti(_ fetchResult: PHAsset, with requestOptions: PHImageRequestOptions,targeting viewFrameSize: CGSize, with resultHandler: @escaping ((_ image: UIImage)->Void)){
        
        // Esegue la image request una volta
        PHImageManager.default().requestImage(for: fetchResult, targetSize: viewFrameSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            //se abbiamo un immagine valida
            if let uiImage : UIImage = image {
                resultHandler(uiImage)
            }
        })
    }

    
}

//MARK : - Funzionalità da sperimentare

extension PhotoLibraryManager {
    
    //    func asyncPhotoOp(foto: PHFetchResult<PHAsset>,with options: PHImageRequestOptions = PhotoLibraryManager.shared.localRequestOptions, inRunQueue customFunction : @escaping ((PHAsset,PHImageRequestOptions) -> Void), mainQueue completionHandler: @escaping ((Error?)->(Void))){
    //        Queues.photosWorkerQueue.async {
    //            var error: Error?
    //
    //            error = .none
    //            customFunction(foto, options)
    //
    //            Queues.main.async {
    //
    //                    completionHandler(error)
    //                }
    //            }
    //
    //        }
    //
    //
    //    func asyncPhotoOpGroup(foto: PHFetchResult<PHAsset>,group : DispatchGroup = CustomDispatchGroups.photosGroup, with options: PHImageRequestOptions = PhotoLibraryManager.shared.localRequestOptions, inRunQueue customFunction : @escaping ((PHAsset,PHImageRequestOptions) -> Void), mainQueue completionHandler: @escaping ((Error?)->(Void))){
    //        //Ingresso Gruppo
    //        group.enter()
    //
    //        asyncPhotoOp(foto: foto , with : options, inRunQueue: customFunction, mainQueue : {error in
    //
    //            completionHandler(error)
    //            group.leave()
    //        })
    //
    //
    //    }
    //
    //    func performOn(tutteLeFoto: PHFetchResult<PHAsset>, group : DispatchGroup = CustomDispatchGroups.photosGroup, with options: PHImageRequestOptions = PhotoLibraryManager.shared.localRequestOptions, inRunQueue customFunction : @escaping ((PHAsset,PHImageRequestOptions) -> Void), mainQueue completionHandler: @escaping ((Error?, Int)->(Void))){
    //
    //
    ////            asyncPhotoOpGroup(foto: foto, group: group, with: options, inRunQueue : customFunction, mainQueue: {error  in
    ////                print("Completamento ciclo for per Photo : \(indiceFoto)")
    ////                completionHandler(error, indiceFoto)
    ////
    ////            })
    //
    //
    //    }

}
