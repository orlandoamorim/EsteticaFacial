//
//  SurgicalPlanningKey.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public class SurgicalPlanningKey: Object {
    dynamic var id = ""
    dynamic var key = ""
    var value = List<SurgicalPlanningValue>()
}
