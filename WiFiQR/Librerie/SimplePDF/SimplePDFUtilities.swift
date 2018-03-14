//
//  SimplePDFUtilities.swift
//
//  Created by Muhammad Ishaq on 22/03/2015
//

import Foundation
import ImageIO
import UIKit

class SimplePDFUtilities {
    class func getApplicationVersion() -> String {
        var dictionary: Dictionary<String, Any>!
        if (Bundle.main.localizedInfoDictionary != nil) {
            dictionary = Bundle.main.localizedInfoDictionary! as Dictionary
        }
        else {
            dictionary = Bundle.main.infoDictionary!
        }
        let build = dictionary["CFBundleVersion"] as! NSString
        let shortVersionString = dictionary["CFBundleShortVersionString"] as! NSString
        
        return "(\(shortVersionString) Build: \(build))"
    }
    
    class func getApplicationName() -> String {
        var dictionary: Dictionary<String, Any>!
        if (Bundle.main.localizedInfoDictionary != nil) {
            dictionary = Bundle.main.localizedInfoDictionary! as Dictionary
        }
        else {
            dictionary = Bundle.main.infoDictionary!
        }
        let name = dictionary["CFBundleName"] as! NSString
        
        return name as String
    }
    
    class func pathForTmpFile(_ fileName: String) -> URL {
        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let pathURL = tmpDirURL.appendingPathComponent(fileName)
        return pathURL
    }
    
    class func renameFilePathToPreventNameCollissions(_ url: URL) -> String {
        let fileManager = FileManager()
        
        // append a postfix if file name is already taken
        var postfix = 0
        var newPath = url.path
        while(fileManager.fileExists(atPath: newPath)) {
            postfix += 1
            
            let pathExtension = url.pathExtension
            newPath = url.deletingPathExtension().path
            newPath = newPath + " \(postfix)"
            var newPathURL = URL(fileURLWithPath: newPath)
            newPathURL = newPathURL.appendingPathExtension(pathExtension)
            newPath = newPathURL.path
        }
        
        return newPath
    }
    
    class func getImageProperties(_ imagePath: String) -> Dictionary<NSObject, AnyObject>? {
        let imageURL = URL(fileURLWithPath: imagePath)
        let imageSourceRef = CGImageSourceCreateWithURL(imageURL as CFURL, nil)
        let props = CGImageSourceCopyPropertiesAtIndex(imageSourceRef!, 0, nil) as Dictionary?
        return props
    }
    
    class func getNumericListAlphabeticTitleFromInteger(_ value: Int) -> String {
        let base:Int = 26
        let unicodeLetterA :UnicodeScalar = "\u{0061}" // a
        var mutableValue = value
        var result = ""
        repeat {
            let remainder = mutableValue % base
            mutableValue = mutableValue - remainder
            mutableValue = mutableValue / base
            let unicodeChar = UnicodeScalar(remainder + Int(unicodeLetterA.value))
            result = String(describing: unicodeChar) + result
        
        } while mutableValue > 0
        
        return result
    }
    
    class func generateThumbnail(_ imageURL: URL, size: CGSize, callback: @escaping (_ thumbnail: UIImage, _ fromURL: URL, _ size: CGSize) -> Void) {
        
        DispatchQueue.global().async { 
            if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) {
                let options = [
                    kCGImageSourceThumbnailMaxPixelSize as String: max(size.width, size.height),
                    kCGImageSourceCreateThumbnailFromImageIfAbsent as String: true
                ] as [String : Any]
                
                let scaledImage = UIImage(cgImage: CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?)!)
                DispatchQueue.main.async {
                    callback(scaledImage, imageURL, size)
                }
            }
        }
        
    }
}
