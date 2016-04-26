//
//  HeaderCell.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit

class HeaderCell : UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    var name = "" {
        didSet {
            headerLabel.text = name
            headerLabel.textColor = UIColor.whiteColor()
        }
    }
    
    
}

