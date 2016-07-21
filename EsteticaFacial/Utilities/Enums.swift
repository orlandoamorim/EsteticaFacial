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
public enum ImageTypes: Int  {
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

public enum CloudTypes: String {
    case Dropbox = "Dropbox"
    case GoogleDrive = "GoogleDrive"
    case iCloud = "iCloud"
    case LogOut = "LogOut"
}

public enum CloudState: String {
    case Delete = "Delete"
    case Update = "Update"
    case Add = "Add"
    case Ok = "Ok"
}

public enum ImageType: String {
    case Front = "Frontal"
    case ProfileRight = "Perfil Direito"
    case Nasal = "Nasal"
    case ObliqueLeft = "Obliquo Esquerdo"
    case ObliqueRight = "Obliquo Direito"
    case ProfileLeft = "Perfil Esquerdo"
}

