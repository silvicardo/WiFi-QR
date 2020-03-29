//
//  CameraManager.swift
//  PizzaList
//
//  Created by Marcello Catelli on 27/07/2018.
//  Copyright (c) 2018 Swift srl. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

protocol CameraManagerDelegate {
    func cancelImageOrVideoSelection()
}

class CameraManager: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {
   
    static let shared = CameraManager()
    
    //nel controller che deve ricevere l'immagine aggingere il delegato CameraManagerDelegate
    //e scrivere nel vieDidLoad CameraManager.sharedInstance.delegate = self
    var delegate : CameraManagerDelegate?
    
    var completionHandler : ((_ image: UIImage) -> ())!
    
    var completionHandlerVideo : ((_ path: String) -> ())!
    
    //IMMAGINI
    //questi metodi vanno invocati SOLO da un controller, e solo dopo aver implementato il delegato
    //nel controller che li chiama devi implementare il metodo func incomingImage(image: UIImage) { }
    //se no l'App va in crash
    
    //scegli una foto dalla libreria di iOS
    func newImageLibrary(controller: UIViewController, sourceIfPad: UIView?, editing: Bool, completionHandler : @escaping (_ image: UIImage) -> ()) {
        self.completionHandler = completionHandler
        
        let picker = UIImagePickerController()
        picker.delegate = self
        // .overCurrentContext permette landscape
        picker.modalPresentationStyle = .overCurrentContext
		picker.sourceType = UIImagePickerController.SourceType.photoLibrary;
        picker.allowsEditing = editing
        
        //navigationBarStyle
        picker.navigationBar.barStyle = .black
        picker.navigationBar.isTranslucent = true
        
        picker.navigationBar.barTintColor = .black // Background color
        picker.navigationBar.tintColor = .white
        
        
        
//        if UIDevice.current.userInterfaceIdiom == .pad {
//
//            picker.modalPresentationStyle = .popover
//
//            if let popover = picker.popoverPresentationController {
//                // impostamo la direzione della freccia
//                popover.permittedArrowDirections = .up
//
//                popover.delegate = self
//
//                popover.sourceView = sourceIfPad
//                let rect = CGRect(x: sourceIfPad!.frame.size.width / 2,
//                    y: sourceIfPad!.frame.size.height + 4, width: 1, height: 1)
//
//                popover.sourceRect = rect //imageUser.frame
//                popover.backgroundColor = UIColor.white
//            }
//
//            controller.view.layoutIfNeeded()
//            controller.present(picker, animated: true, completion: nil)
//
//
//        } else {
            controller.present(picker, animated: true, completion: nil)
//        }
    }
    
    //scatta una nuova foto
    func newImageShoot(controller: UIViewController, sourceIfPad: UIView?, editing: Bool, overlay: UIImageView?, completionHandler : @escaping (_ image: UIImage) -> ()) {
        
        self.completionHandler = completionHandler
        
        let picker = UIImagePickerController()
        picker.delegate = self
		picker.sourceType = UIImagePickerController.SourceType.camera;
        let arra : [AnyObject] = [kUTTypeImage]
        picker.mediaTypes = arra as! [String]
        picker.allowsEditing = editing
        
        if let test = overlay {
            picker.cameraOverlayView = test
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            
            picker.modalPresentationStyle = .popover
            if let popover = picker.popoverPresentationController {
                // impostamo la direzione della freccia
                popover.permittedArrowDirections = .up
                
                popover.delegate = self
                
                popover.sourceView = sourceIfPad
                let rect = CGRect(x: sourceIfPad!.frame.size.width / 2,
                    y: sourceIfPad!.frame.size.height + 4, width: 1, height: 1)
                
                popover.sourceRect = rect //imageUser.frame
                popover.backgroundColor = UIColor.black
            }
            controller.view.layoutIfNeeded()
            controller.present(picker, animated: true, completion: nil)
            
            
        } else {
            controller.present(picker, animated: true, completion: nil)
        }
    }
    
    //VIDEO
    //questi metodi vanno invocati SOLO da un controller, e solo dopo aver implementato il delegato
    //nel controller che li chiama devi implementare il metodo func incomingVideo(video: String) { }
    //se no l'App va in crash
    
    //scegli un video dalla libreria
    func newVideoLibrary(controller: UIViewController, sourceIfPad: UIView?, editing: Bool, completionHandlerVideo : @escaping (_ path: String) -> ()) {
        
        self.completionHandlerVideo = completionHandlerVideo
        
        let picker = UIImagePickerController()
        picker.delegate = self
		picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        let arra : [AnyObject] = [kUTTypeMovie]
        picker.mediaTypes = arra as! [String]
        picker.allowsEditing = editing
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            picker.modalPresentationStyle = .popover
            if let popover = picker.popoverPresentationController {
                // impostamo la direzione della freccia
                popover.permittedArrowDirections = .up
                
                popover.delegate = self
                
                popover.sourceView = sourceIfPad
                let rect = CGRect(x: sourceIfPad!.frame.size.width / 2,
                                      y: sourceIfPad!.frame.size.height + 4, width: 1, height: 1)
                
                popover.sourceRect = rect //imageUser.frame
                popover.backgroundColor = UIColor.black
            }
            controller.view.layoutIfNeeded()
            controller.present(picker, animated: true, completion: nil)
            
            
        } else {
            controller.present(picker, animated: true, completion: nil)
        }
    }
    
    //gira un nuovo video
    func newVideoShoot(controller: UIViewController, sourceIfPad: UIView?, editing: Bool, maxDur: TimeInterval, completionHandlerVideo : @escaping (_ path: String) -> ()) {
        
        self.completionHandlerVideo = completionHandlerVideo
        
        let picker = UIImagePickerController()
        picker.delegate = self
		picker.sourceType = UIImagePickerController.SourceType.camera
        let arra : [AnyObject] = [kUTTypeMovie]
        picker.mediaTypes = arra as! [String]
        picker.videoMaximumDuration = maxDur
        picker.videoExportPreset = AVAssetExportPresetMediumQuality
        picker.allowsEditing = editing
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            picker.modalPresentationStyle = .popover
            if let popover = picker.popoverPresentationController {
                // impostamo la direzione della freccia
                popover.permittedArrowDirections = .up
                
                popover.delegate = self
                
                popover.sourceView = sourceIfPad
                let rect = CGRect(x: sourceIfPad!.frame.size.width / 2,
                                      y: sourceIfPad!.frame.size.height + 4, width: 1, height: 1)
                
                popover.sourceRect = rect //imageUser.frame
                popover.backgroundColor = UIColor.black
            }
            controller.view.layoutIfNeeded()
            controller.present(picker, animated: true, completion: nil)
            
            
        } else {
            controller.present(picker, animated: true, completion: nil)
        }
    }
    
    //SANDBOX
    //restituisce il percorso della cartella documents della sandbox dell'App
    func cartellaDocuments() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //println(paths[0] as String)
        return paths[0] as String
    }
    
    //metodi del delegato dell'UIImagePickerController
    //NON USARLI, servono solo internamente a questo Manager
	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
		let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
    
        if mediaType == kUTTypeImage {
            
			let imageEdited : UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            if let test = imageEdited {
                self.completionHandler(test)
            } else {
				let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                self.completionHandler(imageOriginal)
            }
            
        } else if mediaType == kUTTypeMovie {
			let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                let filePath = videoURL.absoluteString
                self.completionHandlerVideo(filePath)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.cancelImageOrVideoSelection()
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
