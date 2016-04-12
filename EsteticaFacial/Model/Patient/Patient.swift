//
//  Patient.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 17/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import RealmSwift

class Patient: Object {
    dynamic var id = NSUUID().UUIDString
    dynamic var create_at = NSDate()
    dynamic var update_at = NSDate()
    dynamic var name = ""
    dynamic var sex = ""
    dynamic var ethnic = ""
    dynamic var date_of_birth = NSDate()
    dynamic var mail: String? = nil
    dynamic var phone: String? = nil
    let records = List<Record>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
