//
//  Protocols.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 10/12/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import Foundation
import UIKit

protocol NovoPacienteDelegate{
    func atribuir_imagem(imagem: UIImage, imageTypesSelected:imageTypes)
    func atribuir_marcacao(dic:[String:NSValue], imageTypesSelected:imageTypes, pontosFrontalFrom: pontosFrontalType, pontosPerfilFrom:pontosPerfilType, pontosNasalFrom: pontosNasalType)
}

protocol ProcedimentoCirurgico{
    func alterarDic(dicFormValuesAtual:[String : Any?])
}

protocol CameraViewDelegate{
    func marcar_pontos(dic : [String:NSValue])
}

enum imageTypes {
    case Frontal, Perfil, Nasal
}

enum contentTypes {
    case Adicionar, Atualizar, Nil
}

enum imageGet {
    case Camera, Biblioteca, Servidor
}

enum pontosFrontalType {
    case Servidor, Local, Atualizado, Nil
}

enum pontosPerfilType {
    case Servidor, Local, Atualizado, Nil
}

enum pontosNasalType {
    case Servidor, Local, Atualizado, Nil
}