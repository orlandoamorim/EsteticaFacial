//
//  LastImageVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/12/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class LastImageVC: UIView {


    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Helpers().getLatestPhotos { (image) -> () in
            addSubview(image!)
        }
    }


}
