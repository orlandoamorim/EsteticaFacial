//
//  PontoView.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 19/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class PontoView: UIView {

    let largura : CGFloat = 110.0
    let altura : CGFloat = 30.0
    
    var nome : String?
    var local : CGPoint = CGPointMake(0.0, 0.0)
    var ponto_view : UIImageView! = UIImageView(image: UIImage(named: "ponto_azul"))
    var nome_label : UILabel! = UILabel(frame: CGRectMake(30.0, 5.0, 80.0, 20.0))

    
    func inicializar(nome: String, posicao:CGPoint){
        let primeiroNome = nome.characters.split{$0 == "_"}.map(String.init)
        self.nome =  primeiroNome[0]

        self.local = posicao
        self.nome_label.text = nome
        self.ponto_view.frame = CGRectMake(5.0, 5.0, 20.0, 20.0)
        self.layer.addSublayer(self.nome_label.layer)
        self.layer.addSublayer(self.ponto_view.layer)
        self.frame = CGRectMake(posicao.x-self.altura/2.0, posicao.y-self.altura/2, largura, altura)
    }
    
}
