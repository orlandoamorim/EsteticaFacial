//
//  Paciente+CoreDataProperties.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Paciente {

    @NSManaged var etnia: String?
    @NSManaged var img_frontal: NSData?
    @NSManaged var img_nasal: NSData?
    @NSManaged var img_perfil: NSData?
    @NSManaged var nascimento: NSDate?
    @NSManaged var nome: String?
    @NSManaged var pontos: NSData?
    @NSManaged var relatorio: String?
    @NSManaged var sexo: String?
    @NSManaged var thumb_frontal: NSData?
    @NSManaged var thumb_nasal: NSData?
    @NSManaged var thumb_perfil: NSData?
    @NSManaged var notas: String?
    @NSManaged var data_adicao: NSDate?

}
