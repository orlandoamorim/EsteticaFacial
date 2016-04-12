//
//  Record.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 17/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import RealmSwift

class Record: Object {
    
    dynamic var id = ""
    dynamic var surgeryDescription = ""
    dynamic var patient: Patient?
    let image = List<Image>()
    dynamic var surgeryRealized = false
    let surgicalPlanning = List<SurgicalPlanning>()
    dynamic var date_of_surgery: NSDate? = nil
    dynamic var note: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
