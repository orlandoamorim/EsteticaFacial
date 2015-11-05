//
//  LocalizadorFrontal.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 03/11/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class LocalizadorFrontal: NSObject {
    /// A matriz que armazena os níveis de intensidade de uma imagem.
    var matrix:Array<Array<Int>>?
    var img:UIImage?
    var width=0
    var height=0
    
    override init() {
    }
    
    /**
     Inicializa o atributo **matrix** da classe com uma imagem. O valor armazenado em **matrix** representa somente a intensidade (brilho) da imagem de entrada, levando em conta os canais RGB.
     
     - Author: Ricardo Teles Freitas
     - Date: 03/11/2015
     
     - Parameter image: Imagem a ser carregada em **matrix**.
     */
    func iniciar_matriz(image:UIImage){
        print("Inicializando matriz...")
        self.width = Int(image.size.width)
        self.height = Int(image.size.height)
        let raw = UnsafeMutablePointer<RGBA>(TratamentoEntrada.uiimage_raw(image))
        
        self.matrix = Array(count: self.height, repeatedValue: Array(count: self.width, repeatedValue: 0))
        self.img = image
        
        for var i:Int=0 ; i<self.height ; i++ {
            for var j:Int=0 ; j<self.width ; j++ {
                self.matrix![i][j] = (Int(raw[i*self.width + j].r) + Int(raw[i*self.width + j].g) + Int(raw[i*self.width + j].b))/3
            }
        }
        print("Finalizando")
    }
    
    /**
     Localiza os olhos do indivíduo presente na imagem **matrix**. O algoritmo utilizado é a transformada de Hough para encontrar círculos.
     
     - Author: Ricardo Teles Freitas
     - Date: 03/11/2015
     - ToDo: Rever o método de localização de círculos e o campo de busca.
     
     - Parameter probdir: Localização provável do centro do olho direito
     - Parameter probesq: Localização provável do centro do olho esquerdo
     - Returns: Lista de tupla, indicando o centro (linha e coluna) e raio dos olhos encontrados.
     
     */
    func find_eyes(probdir:CGPoint, probesq:CGPoint)->[(Int,Int,Int)]{
        print("Iniciando busca pelos olhos...")
        let min = Int(Double(self.height) * 0.02)
        let max = Int(Double(self.height) * 0.04)
        
        print("Menor Raio = \(min)")
        print("Maior Raio = \(max)")
        
        let edges = TecnicasPDI.canny(self.img!, lower: 0.05, upper: 0.15)
        
        var mat = Array(count: self.height, repeatedValue: Array(count: self.width, repeatedValue: 0))
        for var i:Int=0;i<self.height;i++ {
            for var j:Int=0;j<self.width;j++ {
                mat[i][j] = Int(edges[i*width+j].r)
            }
        }
        
        let right_rect = CGRectMake(CGFloat(self.width/4), CGFloat(self.height/3), CGFloat(self.width/4), CGFloat(self.height/6))
        let left_rect = CGRectMake(CGFloat(self.width/2), CGFloat(self.height/3), CGFloat(self.width/4), CGFloat(self.height/6))
        
        var right_eye : [(Int,Int,Int,Double)] = VisaoComputacional.circle_hough_multiple_radius(min, max: max, matrix: mat, width: self.width, height: self.height,rect_to_search:right_rect,probcirc: probdir)
        
        var left_eye : [(Int,Int,Int,Double)] =  VisaoComputacional.circle_hough_multiple_radius(min, max: max, matrix: mat, width: self.width, height: self.height,rect_to_search:left_rect, probcirc:probesq)
        
        let rr = right_eye[0]
        let ll = left_eye[0]
        
        print("Finalizando")
        print("Circulos : \(rr) | \(ll)")
        
        return [(right_eye[0].0,right_eye[0].1,right_eye[0].2),(left_eye[0].0,left_eye[0].1,left_eye[0].2)]
    }
}
