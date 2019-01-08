//
//  BorderView.swift
//  WiFiQRWidget
//
//  Created by riccardo silvi on 08/09/2018.
//  Copyright © 2018 riccardo silvi. All rights reserved.
//

import UIKit

@IBDesignable class BorderView : UIView {
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

