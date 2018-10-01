//
//  Concurrency.swift
//  WiFiQR
//
//  Created by riccardo silvi on 04/07/18.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

enum Queues {
    static let main = DispatchQueue.main
    
    static let photosWorkerQueue  = DispatchQueue(label: "com.riccardosilvi.photoExtraction", qos: DispatchQoS.utility, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem)

}


enum CustomDispatchGroups {
    
    static let photosGroup = DispatchGroup()
}
