//
//  Photo.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 17/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public class Image: Object {
    
    dynamic var id = NSUUID().UUIDString
//    dynamic var patientId = ""
    dynamic var recordID = ""
    dynamic var compareImageID = ""
    dynamic var imageRef = ""
    dynamic var imageType = ""
    dynamic var name = ""
    dynamic var create_at = NSDate()
    dynamic var update_at = NSDate()
    dynamic var points: NSData? = nil
    
    dynamic var cloudState:String = CloudState.Ok.rawValue

    override public static func primaryKey() -> String? {
        return "id"
    }
}
