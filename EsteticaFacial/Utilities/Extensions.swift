//
//  Extensions.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 15/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension String {
    func toInt() -> Int {
        return Int(self)!
    }

    func toDate() -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.dateFromString(self)!
    }
}

extension Int{
    func toString() -> String{
        return String(self)
    }
}

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

extension UINavigationController {
    
    func progress(progressView: UIProgressView) {
        self.view.addSubview(progressView)
        let navBar = self.navigationBar
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[navBar]-0-[progressView]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView, "navBar" : navBar]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView]))
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        if progressView.progress == 1.0 {
            progressView.hidden = true
        }
    }
    
    func progressQuant(count: Int) {
        let progressView = UIProgressView()
        
        self.view.addSubview(progressView)
        let navBar = self.navigationBar
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[navBar]-0-[progressView]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView, "navBar" : navBar]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView]))
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        if progressView.progress == 1.0 {
            progressView.hidden = true
        }
    }
}

extension UIAlertController {
    
    class func alertControllerWithTitle(title:String, message:String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        return controller
    }
    
    class func alertControllerWithNoCancel(title:String, message:String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        return controller
    }
    
    class func alertControllerWithNumberInput(title:String, message:String, buttonTitle:String, handler:(Int?)->Void) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        controller.addTextFieldWithConfigurationHandler { $0.keyboardType = .NumberPad }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        controller.addAction(UIAlertAction(title: buttonTitle, style: .Default) { action in
            let textFields = controller.textFields! as [UITextField]
            let value = Int(textFields[0].text!)
            handler(value)
            } )
        
        return controller
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

extension NSValue {
    func toString() -> String{
        return String(self)
    }
}

extension Array where Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

//Swift 3
//extension Array where Element: Equatable {
//    
//    // Remove first collection element that is equal to the given `object`:
//    mutating func removeObject(object: Element) {
//        if let index = index(of: object) {
//            remove(at: index)
//        }
//    }
//}


extension NSBundle {
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
    
}

