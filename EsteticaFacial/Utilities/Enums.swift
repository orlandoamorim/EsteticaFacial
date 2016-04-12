//
//  Enums.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 11/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit

//Nao pode mudar a ordem!!
public enum ImageTypes {
    case Front, ProfileRight, Nasal, ObliqueLeft, ObliqueRight, ProfileLeft
}

enum ImageVerificationType {
    case Ok, Retake
}

enum SurgicalPlanningTypes {
    case PreSurgical, PostSurgical
}

enum contentTypes {
    case Adicionar, Atualizar, Nil
}

enum ImageShowAction {
    case No
    case Yes(style: UIAlertActionStyle)
}

enum ImageClearAction {
    case No
    case Yes(style: UIAlertActionStyle)
}

public enum SurgeryShow {
    case Patient, Surgery
}

public enum PatientShow {
    case Patient, CheckPatient
}

public enum PatientDetailShow {
    case PatientDetail, CheckPatient
}