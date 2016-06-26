//
//  CompareImages.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 24/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public class CompareImage: Object {
    
    dynamic var id = NSUUID().UUIDString
    dynamic var recordID = ""
    dynamic var reference = ""
    dynamic var date = NSDate()
    let image = List<Image>()
    dynamic var create_at = NSDate()
    dynamic var update_at = NSDate()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
