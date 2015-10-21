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
    var ponto_view : UIImageView! = UIImageView(image: UIImage.init(named: "ponto_azul"), highlightedImage: UIImage.init(named: "ponto_vermelho"))
    var nome_label : UILabel! = UILabel(frame: CGRectMake(30.0, 5.0, 80.0, 20.0))
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func inicializar(nome: String, posicao:CGPoint){
        self.nome = nome
        self.local = posicao
        self.nome_label.text = nome
        self.ponto_view.frame = CGRectMake(5.0, 5.0, 20.0, 20.0)
        self.layer.addSublayer(self.nome_label.layer)
        self.layer.addSublayer(self.ponto_view.layer)
        self.frame = CGRectMake(posicao.x-self.altura/2.0, posicao.y-self.altura/2, largura, altura)
    }

}
