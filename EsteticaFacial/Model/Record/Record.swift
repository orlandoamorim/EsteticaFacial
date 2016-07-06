//
//  Record.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 17/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import RealmSwift

public class Record: Object {
    
    dynamic var id = ""
    dynamic var surgeryDescription = ""
    dynamic var patient: Patient?
    let image = List<Image>()
    let compareImage = List<CompareImage>()
    dynamic var surgeryRealized = false
    let surgicalPlanning = List<SurgicalPlanning>()
    dynamic var date_of_surgery: NSDate? = nil
    dynamic var note: String? = nil
    
    dynamic var create_at = NSDate()
    dynamic var update_at = NSDate()
    
    dynamic var cloudState:String = CloudState.Ok.rawValue
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
