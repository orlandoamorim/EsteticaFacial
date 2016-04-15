//
//  Extensions.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 15/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func selectedButton(title:String, iconName: String, widthConstraints: NSLayoutConstraint){
        self.backgroundColor = UIColor(red: 0, green: 118/255, blue: 254/255, alpha: 1)
        self.setTitle(title, forState: UIControlState.Normal)
        self.setTitle(title, forState: UIControlState.Highlighted)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.setImage(UIImage(named: iconName), forState: UIControlState.Normal)
        self.setImage(UIImage(named: iconName), forState: UIControlState.Highlighted)
        let image = self.imageView!.frame.width
        let text = (title as NSString).sizeWithAttributes([NSFontAttributeName:self.titleLabel!.font!]).width
        let width = text + image + 24
        //24 - the sum of your insets
        widthConstraints.constant = width
        self.layoutIfNeeded()
    }
}

extension UIColor {
    // Creates a UIColor from a Hex string.
    convenience init(hexString: String) {
        var cString: String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            self.init(white: 0.5, alpha: 1.0)
        } else {
            let rString: String = (cString as NSString).substringToIndex(2)
            let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
            let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
            
            var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
            
            self.init(red: CGFloat(r) / CGFloat(255.0), green: CGFloat(g) / CGFloat(255.0), blue: CGFloat(b) / CGFloat(255.0), alpha: CGFloat(1))
        }
        
        
    }
}

extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        guard let data1 = UIImagePNGRepresentation(self),
            data2 = UIImagePNGRepresentation(image)
            else { return false }
        return data1.isEqualToData(data2)
    }
}