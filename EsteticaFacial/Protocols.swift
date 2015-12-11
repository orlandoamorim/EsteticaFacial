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
    func atribuir_imagem(imagem: UIImage, flag:Int)
    func atribuir_marcacao(dic:[String:NSValue], flag:Int)
}

protocol ProcedimentoCirurgico{
    func alterarDic(dicFormValuesAtual:[String : Any?])
}

protocol CameraViewDelegate{
    func marcar_pontos(dic : [String:NSValue])
}
