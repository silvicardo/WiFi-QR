//
//  Extensions.swift
//  Prova2
//
//  Created by Marcello Catelli on 07/06/2017.
//  Copyright (c) 2017 Swift srl. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit
import AVFoundation

// NSObject
public extension NSObject{
    public class var nameOfClass : String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass : String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

// FileManager
public extension FileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

// UIView
public extension UIView {
    
    func addParallax(X horizontal:Float, Y vertical:Float) {
        
        let parallaxOnX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffect.EffectType.tiltAlongHorizontalAxis)
        parallaxOnX.minimumRelativeValue = -horizontal
        parallaxOnX.maximumRelativeValue = horizontal
        
        let parallaxOnY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffect.EffectType.tiltAlongVerticalAxis)
        parallaxOnY.minimumRelativeValue = -vertical
        parallaxOnY.maximumRelativeValue = vertical
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [parallaxOnX, parallaxOnY]
        self.addMotionEffect(group)
    }
    
    func blurMyBackgroundDark(adjust b:Bool, white v:CGFloat, alpha a:CGFloat) {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let fxView = UIVisualEffectView(effect: blur)
        
        if b {
            fxView.contentView.backgroundColor = UIColor(white:v, alpha:a)
        }
        
        fxView.frame = self.bounds

        self.addSubview(fxView)
        self.sendSubviewToBack(fxView)
    }
    
    func blurMyBackgroundLight() {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let fxView = UIVisualEffectView(effect: blur)
        
        var rect = self.bounds
        rect.size.width = CGFloat(2500)
        
        fxView.frame = rect
        
        self.addSubview(fxView)
        
        self.sendSubviewToBack(fxView)
    }
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.drawHierarchy(in: self.frame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func convertRectCorrectly(_ rect: CGRect, toView view: UIView) -> CGRect {
        if UIScreen.main.scale == 1 {
            return self.convert(rect, to: view)
        } else if self == view {
            return rect
        } else {
            var rectInParent = self.convert(rect, to: self.superview)
            rectInParent.origin.x /= UIScreen.main.scale
            rectInParent.origin.y /= UIScreen.main.scale
            let superViewRect = self.superview!.convertRectCorrectly(self.superview!.frame, toView: view)
            rectInParent.origin.x += superViewRect.origin.x
            rectInParent.origin.y += superViewRect.origin.y
            return rectInParent
        }
    }
    
    func imageSnapshotCroppedToFrame(_ frame: CGRect?) -> UIImage {
        let scaleFactor = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scaleFactor)
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let frame = frame {
            // UIImages are measured in points, but CGImages are measured in pixels
            let scaledRect = frame.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
            
            if let imageRef = image.cgImage?.cropping(to: scaledRect) {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

// UIImage
public extension UIImage {
    
    func fromLandscapeToPortrait(_ rotate: Bool!) -> UIImage {
        let container : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        container.contentMode = UIView.ContentMode.scaleAspectFill
        container.clipsToBounds = true
        container.image = self
        
        UIGraphicsBeginImageContextWithOptions(container.bounds.size, true, 0);
        container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if !rotate {
            return normalizedImage!
        } else {
            let rotatedImage = UIImage(cgImage: (normalizedImage?.cgImage!)!, scale: 1.0, orientation: UIImage.Orientation.left)
            
            UIGraphicsBeginImageContextWithOptions(rotatedImage.size, true, 1);
            rotatedImage.draw(in: CGRect(x: 0, y: 0, width: rotatedImage.size.width, height: rotatedImage.size.height))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return normalizedImage!
        }
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func areaAverage() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let context = CIContext()
        let inputImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
        
        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
    
    func imageByCroppingImage(_ size: CGSize) -> UIImage {
        let newCropWidth, newCropHeight : CGFloat;
        
        if(self.size.width < self.size.height) {
            if (self.size.width < size.width) {
                newCropWidth = self.size.width;
            }
            else {
                newCropWidth = size.width;
            }
            newCropHeight = (newCropWidth * size.height)/size.width;
        } else {
            if (self.size.height < size.height) {
                newCropHeight = self.size.height;
            }
            else {
                newCropHeight = size.height;
            }
            newCropWidth = (newCropHeight * size.width)/size.height;
        }
        
        let x = self.size.width / 2 - newCropWidth / 2;
        let y = self.size.height / 2 - newCropHeight / 2;
        
        let cropRect = CGRect(x: x, y: y, width: newCropWidth, height: newCropHeight);
        let imageRef = self.cgImage?.cropping(to: cropRect);
        
        let croppedImage : UIImage = UIImage(cgImage: imageRef!, scale: 0, orientation: self.imageOrientation);
        
        return croppedImage;
    }
    
    func imageWithSize(_ size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / self.size.width;
        let aspectHeight:CGFloat = size.height / self.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = self.size.width * aspectRatio;
        scaledImageRect.size.height = self.size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        self.draw(in: scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage!;
    }
    
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/4, size.width/4)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
	
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}

// UITableView
public extension UITableViewController {
    
    func insertBackground(image: UIImage) {
        let imVi = UIImageView(frame: tableView.frame)
        imVi.contentMode = .scaleToFill
        imVi.image = image
        tableView.backgroundView = imVi
    }
    
    func createNoPaintBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: tableView.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .scaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
    
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            tableView.backgroundView = packView
        } else {
            tableView.backgroundColor = UIColor.clear
            tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clear
        }

        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    func createBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            tableView.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            tableView.backgroundColor = UIColor.clear
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clear
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}

public extension UITableView {
    
    func createBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            self.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            self.backgroundColor = UIColor.clear
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        self.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    func createNoPaintBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: self.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .scaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
            
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            self.backgroundView = packView
        } else {
            self.backgroundColor = UIColor.clear
            self.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}

//// UITableViewRowAction
//// INUTILE CON iOS 11
//public extension UITableViewRowAction {
//    
//    class func rowAction2(title: String?, titleBorderMargin:Int, font:UIFont, fontColor:UIColor, verticalMargin:CGFloat, image: UIImage, forCellHeight cellHeight: CGFloat,  backgroundColor: UIColor, handler: @escaping (UITableViewRowAction, IndexPath) -> Void) -> UITableViewRowAction {
//        
//        // clacolo titolo
//        var largezzaTesto : Int = 1
//        
//        if let titleTest = title {
//            largezzaTesto = titleTest.characters.count + (titleBorderMargin * 2)
//        } else {
//            largezzaTesto = titleBorderMargin
//        }
//        let titleSpaceString = "".padding(toLength: largezzaTesto, withPad: "\u{3000}", startingAt: 0)
//        
//        let rowAction = UITableViewRowAction(style: .default, title: titleSpaceString, handler: handler)
//        
//        let larghezzaTestoConSpazio = titleSpaceString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: cellHeight),
//                                                                    options: .usesLineFragmentOrigin,
//                                                                 attributes: [NSAttributedStringKey.font: font],
//                                                                    context: nil).size.width + 30
//        // calcolo grandezza
//        let frameGuess: CGSize = CGSize(width: larghezzaTestoConSpazio, height: cellHeight)
//        
//        let tripleFrame: CGSize = CGSize(width: frameGuess.width * 2.0, height: frameGuess.height * 2.0)
//        
//        // trucco
//        UIGraphicsBeginImageContextWithOptions(tripleFrame, false, UIScreen.main.scale)
//        let context: CGContext = UIGraphicsGetCurrentContext()!
//        
//        backgroundColor.setFill()
//        context.fill(CGRect(x: 0, y: 0, width: tripleFrame.width, height: tripleFrame.height))
//        
//        if let _ = title {
//            image.draw(at: CGPoint(x: (frameGuess.width / 2.0) - (image.size.width / 2.0),
//                                          y: (frameGuess.height / 2.0) - image.size.height - (verticalMargin / 2.0) + 4.0))
//        } else {
//            image.draw(at: CGPoint( x: (frameGuess.width / 2.0) - (image.size.width / 2.0),
//                                           y: (frameGuess.height / 2.0) - image.size.height / 2.0) )
//        }
//        
//        if let titleTest = title {
//            let drawnTextSize: CGSize = titleTest.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: cellHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size
//            
//            let direction : CGFloat = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? -1 : 1
//            
//            titleTest.draw(in: CGRect( x: ((frameGuess.width / 2.0) - (drawnTextSize.width / 2.0)) * direction, y: (frameGuess.height / 2.0) + (verticalMargin / 2.0) + 2.0, width: frameGuess.width, height: frameGuess.height), withAttributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: fontColor])
//        }
//
//        rowAction.backgroundColor = UIColor(patternImage: UIGraphicsGetImageFromCurrentImageContext()!)
//        UIGraphicsEndImageContext()
//        
//        return rowAction
//    }
//    
//}

// Date
let componentFlags : Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekdayOrdinal, Calendar.Component.hour,Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal]

public extension DateComponents {
	mutating func to12am() {
		self.hour = 0
		self.minute = 0
		self.second = 0
	}
	
	mutating func to12pm() {
		self.hour = 23
		self.minute = 59
		self.second = 59
	}
}

public extension Date {
    
    //Crea una data direttamente dai valori passati
    static func customDate(year ye:Int, month mo:Int, day da:Int, hour ho:Int, minute mi:Int, second se:Int) -> Date {
        var comps = DateComponents()
        comps.year = ye
        comps.month = mo
        comps.day = da
        comps.hour = ho
        comps.minute = mi
        comps.second = se
        let date = NSCalendar.current.date(from: comps)
        return date!
    }
    
    func localeString() -> String {
        let df = DateFormatter()
        df.locale = NSLocale.current
        df.timeStyle = .medium
        df.dateStyle = .short
        return df.string(from: self)
    }
	
	struct Gregorian {
		static let calendar = Calendar(identifier: .gregorian)
	}
	var startOfWeek: Date? {
		return Gregorian.calendar.date(from: Gregorian.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
	}
	
	func startOfWeek(weekday: Int?) -> Date {
		var cal = Calendar.current
		var component = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
		component.to12am()
		cal.firstWeekday = weekday ?? 1
		return cal.date(from: component)!
	}
	
	func endOfWeek(weekday: Int) -> Date {
		let cal = Calendar.current
		var component = DateComponents()
		component.weekOfYear = 1
		component.day = -1
		component.to12pm()
		return cal.date(byAdding: component, to: startOfWeek(weekday: weekday))!
	}
    
    static func customDateUInt(year ye:UInt, month mo:UInt, day da:UInt, hour ho:UInt, minute mi:UInt, second se:UInt) -> Date {
        var comps = DateComponents()
        comps.year = Int(ye)
        comps.month = Int(mo)
        comps.day = Int(da)
        comps.hour = Int(ho)
        comps.minute = Int(mi)
        comps.second = Int(se)
        let date = NSCalendar.current.date(from: comps)
        return date!
    }
    
    static func dateOfMonthAgo() -> Date {
        return Date().addingTimeInterval(-24 * 30 * 60 * 60)
    }
    
    static func dateOfWeekAgo() -> Date {
        return Date().addingTimeInterval(-24 * 7 * 60 * 60)
    }
    
    func sameDate(ofDate:Date) -> Bool {
        let cal = NSCalendar.current
        let dif = cal.compare(self, to: ofDate, toGranularity: Calendar.Component.day)
        if dif == .orderedSame {
            return true
        } else {
            return false
        }
    }
    
    static func currentCalendar() -> Calendar {
        
        return Calendar.autoupdatingCurrent
    }
    
    func isEqualToDateIgnoringTime(_ aDate:Date) -> Bool {
        let components1 = Date.currentCalendar().dateComponents(componentFlags, from: self)
        let components2 = Date.currentCalendar().dateComponents(componentFlags, from: aDate)
        
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    public func plusSeconds(_ s: Int) -> Date {
        return self.addComponentsToDate(seconds: s, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusSeconds(_ s: UInt) -> Date {
        return self.addComponentsToDate(seconds: -Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusMinutes(_ m: Int) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: m, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusMinutes(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: -Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: -Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func minusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: -Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func plusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: Int(w), months: 0, years: 0)
    }
    
    public func minusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: -Int(w), months: 0, years: 0)
    }
    
    public func plusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: Int(m), years: 0)
    }
    
    public func minusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: -Int(m), years: 0)
    }
    
    public func plusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: Int(y))
    }
    
    public func minusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: -Int(y))
    }
    
    private func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> Date {
        var dc:DateComponents = DateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return Calendar.current.date(byAdding: dc, to: self, wrappingComponents: false)!
    }
    
    public func midnightUTCDate() -> Date {
        var dc:DateComponents = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        (dc as NSDateComponents).timeZone = TimeZone(secondsFromGMT: 0)
        
        return Calendar.current.date(from: dc)!
    }
    
    public static func secondsBetween(date1 d1:Date, date2 d2:Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.second!
    }
    
    public static func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.minute!
    }
    
    public static func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.hour!
    }
    
    public static func daysBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.day!
    }
    
    public static func weeksBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.weekOfYear!
    }
    
    public static func monthsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.month!
    }
    
    public static func yearsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.year!
    }
    
    //MARK- Comparison Methods
    
    public func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    public func isLessThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    //MARK- Computed Properties
    
    public var day: UInt {
        return UInt(Calendar.current.component(.day, from: self))
    }
    
    public var month: UInt {
        return UInt(Calendar.current.component(.month, from: self))
    }
    
    public var year: UInt {
        return UInt(Calendar.current.component(.year, from: self))
    }
    
    public var hour: UInt {
        return UInt(Calendar.current.component(.hour, from: self))
    }
    
    public var minute: UInt {
        return UInt(Calendar.current.component(.minute, from: self))
    }
    
    public var second: UInt {
        return UInt(Calendar.current.component(.second, from: self))
    }
}

extension UIAlertController {
    override open var shouldAutorotate: Bool {
        return false
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

// Audio fade
extension AVAudioPlayer {
    @objc func fadeOut() {
        if volume > 0.1 {
            // Fade
            volume -= 0.1
            perform(#selector(fadeOut), with: nil, afterDelay: 0.2)
        } else {
            // Stop and get the sound ready for playing again
            stop()
            prepareToPlay()
            volume = 1
        }
    }
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return ((rate != 0) && (error == nil))
    }
}

// metodi utili
public func delay(_ delay:Double, closure:  @escaping ()->()) {
    
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

public func loc(_ localizedKey:String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}

func scaleImageFromWidth (_ sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
    let oldWidth = sourceImage.size.width
    let scaleFactor = scaledToWidth / oldWidth
    
    let newHeight = sourceImage.size.height * scaleFactor
    let newWidth = oldWidth * scaleFactor
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func scaleImageFromHeight (_ sourceImage:UIImage, scaledToHeight: CGFloat) -> UIImage {
    let oldHeight = sourceImage.size.height
    let scaleFactor = scaledToHeight / oldHeight
    
    let newHeight = oldHeight * scaleFactor
    let newWidth = sourceImage.size.width * scaleFactor
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}
