//
//  SurgicalPlanningValue.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import RealmSwift

class SurgicalPlanningValue: Object {
    dynamic var valueString: String? = nil
    let valueBool = RealmOptional<Bool>()
    dynamic var valueDate: NSDate? = nil
}
