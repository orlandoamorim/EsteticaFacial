//
//  Protocols.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 10/12/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import Foundation
import UIKit

protocol RecordImageDelegate{
    func updateData(image image: UIImage, ImageType:ImageTypes)
}

protocol RecordPointsDelegate{
    func updateData(points points:[String:NSValue]?, ImageType:ImageTypes)
}


protocol ProcedimentoCirurgico{
    func updateSurgicalPlanning(surgicalPlanningForm:[String : Any?], SurgicalPlanningType: SurgicalPlanningTypes)
}

protocol RecoverPatient {
    func recoverPatient(patient:Patient?)
}


protocol ImageVerification{
    func imageVerification(image image: UIImage?, ImageVerify : ImageVerificationType)
}


protocol CameraViewDelegate{
    func marcar_pontos(dic : [String:NSValue])
}

struct ImageRowSourceTypes : OptionSetType {
    
    let rawValue: Int
    var imagePickerControllerSourceTypeRawValue: Int { return self.rawValue >> 1 }
    
    init(rawValue: Int) { self.rawValue = rawValue }
    private init(_ sourceType: UIImagePickerControllerSourceType) { self.init(rawValue: 1 << sourceType.rawValue) }
    
    static let PhotoLibrary  = ImageRowSourceTypes(.PhotoLibrary)
    static let Camera  = ImageRowSourceTypes(.Camera)
    static let SavedPhotosAlbum = ImageRowSourceTypes(.SavedPhotosAlbum)
    static let All: ImageRowSourceTypes = [Camera, PhotoLibrary, SavedPhotosAlbum]
}



