//
//  HighlightedColorButton.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit

class HighlightedColorButton: UIButton {
    
    var highlightedBackgroundColor: UIColor?
    var temporaryBackgroundColor: UIColor?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
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