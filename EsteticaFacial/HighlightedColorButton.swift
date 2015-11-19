//
//  HighlightedColorButton.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit

class HighlightedColorButton: UIButton {
    
    // A new highlightedBackgroundColor, which shows on tap
    var highlightedBackgroundColor: UIColor?
    // A temporary background color property, which stores the original color while the button is highlighted
    var temporaryBackgroundColor: UIColor?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        
//        view.btnUserImage.layer.cornerRadius = view.btnUserImage.frame.size.width / 2
//        view.btnUserImage.clipsToBounds = true
//        view.btnUserImage.layer.borderWidth = 3.0
//        view.btnUserImage.layer.borderColor = UIColor.whiteColor().CGColor
//        view.btnUserImage.layer.cornerRadius = 10.0
        
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    // Darken a color
    func darkenColor(color: UIColor) -> UIColor {
        
        var red = CGFloat(), green = CGFloat(), blue = CGFloat(), alpha = CGFloat()
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red = max(red - 0.5, 0.0)
        green = max(green - 0.5, 0.0)
        blue = max(blue - 0.5, 0.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    override var highlighted: Bool {
        didSet {
            
          
            if highlighted {
                self.layer.borderColor = darkenColor(UIColor.whiteColor()).CGColor
                if temporaryBackgroundColor == nil {
                    if backgroundColor != nil {
                        if let highlightedColor = highlightedBackgroundColor {
                            temporaryBackgroundColor = backgroundColor
                            backgroundColor = highlightedColor
                        } else {
                            temporaryBackgroundColor = backgroundColor
                            backgroundColor = darkenColor(temporaryBackgroundColor!)
                        }
                    }
                }
                
            } else {
                self.layer.borderColor = UIColor.clearColor().CGColor
                if let temporaryColor = temporaryBackgroundColor {
                    backgroundColor = temporaryColor
                    temporaryBackgroundColor = nil
                }
            }
        }
    }
}