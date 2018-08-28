//
//  WiFiNetwork+CoreDataProperties.swift
//  WiFiQR
//
//  Created by riccardo silvi on 28/08/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//
//

import Foundation
import CoreData


extension WiFiNetwork {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WiFiNetwork> {
        return NSFetchRequest<WiFiNetwork>(entityName: "WiFiNetwork")
    }

    @NSManaged public var password: String?
    @NSManaged public var chosenEncryption: String?
    @NSManaged public var requiresAuthentication: Bool
    @NSManaged public var visibility: String?
    @NSManaged public var isHidden: Bool
    @NSManaged public var ssid: String?
    @NSManaged public var wifiQRString: String?

}
