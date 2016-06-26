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

extension Object {
    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValuesForKeys(properties)
        
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeysWithDictionary(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name)
            }
            
        }
        return mutabledic
    }
    
}

//extension Object {
//    func toDictionary() -> [String:AnyObject] {
//        let properties = self.objectSchema.properties.map { $0.name }
//        var dicProps = [String:AnyObject]()
//        for (key, value) in self.dictionaryWithValuesForKeys(properties) {
//            if let value = value as? ListBase {
//                dicProps[key] = value.toArray()
//            } else if let value = value as? Object {
//                dicProps[key] = value.toDictionary()
//            } else {
//                dicProps[key] = value
//            }
//        }
//        return dicProps
//    }
//}
//
//extension ListBase {
//    func toArray() -> [AnyObject] {
//        var _toArray = [AnyObject]()
//        for i in 0..<self._rlmArray.count {
//            let obj = unsafeBitCast(self._rlmArray[i], Object.self)
//            _toArray.append(obj.toDictionary())
//        }
//        return _toArray
//    }
//}