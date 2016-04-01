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
//Nao pode mudar a ordem!!
public enum ImageTypes {
    case Front, ProfileRight, Nasal, ObliqueLeft, ObliqueRight, ProfileLeft
}

protocol ProcedimentoCirurgico{
    func updateSurgicalPlanning(surgicalPlanningForm:[String : Any?], SurgicalPlanningType: SurgicalPlanningTypes)
}

enum ImageVerificationType {
    case Ok, Retake
}

protocol ImageVerification{
    func imageVerification(image image: UIImage?, ImageVerify : ImageVerificationType)
}

enum SurgicalPlanningTypes {
    case PreSurgical, PostSurgical
}

protocol CameraViewDelegate{
    func marcar_pontos(dic : [String:NSValue])
}

enum contentTypes {
    case Adicionar, Atualizar, Nil
}

enum ImageGet {
    case Camera, Biblioteca, Servidor
}




enum PontosTypes {
    case Servidor, Local, Atualizado, Nil
}


//var frontPoints : [String:NSValue]?
//var profilePoints : [String:NSValue]?
////    var profileLeftPoints : [String:NSValue]?
////    var obliqueRightPoints : [String:NSValue]?
////    var obliqueLeftPoints : [String:NSValue]?
//var nasalPoints : [String:NSValue]?




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

enum ImageShowAction {
    case No
    case Yes(style: UIAlertActionStyle)
}

enum ImageClearAction {
    case No
    case Yes(style: UIAlertActionStyle)
}

