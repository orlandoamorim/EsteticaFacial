//
//  SurgicalPlanning.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SurgicalPlanning: Object {
    dynamic var type = false
    dynamic var id = ""
    let surgicalPlanningForm = List<SurgicalPlanningKey>()
}
