//
//  VisaoComputacional.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 03/11/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class VisaoComputacional: NSObject {
    
    /**
     Transformada de Hough para descoberta de círculos. Esta função aplica a transformada de Hough com um raio pré-determinado para encontrar possíveis círculos em uma imagem.
     
     - Author: Ricardo Teles Freitas
     - Date: 03/11/2015
     - Warning: O campo de busca não deve exceder os limites da imagem.
     - ToDo: Rever implementação explorando a GPU.
     
     - Parameter R: Tamanho do raio dos círculos a serem encontrados.
     - Parameter matrix: Imagem onde procurar os círculos.
     - Parameter width: Largura da imagem.
     - Parameter height: Altura da imagem.
     - Parameter circles: Quantidade de círculos que devem ser encontrados.
     - Parameter rect_to_search: Porção da imagem onde devem ser procurados os círculos.
     - Parameter probcirc: Localização provável de um círculo
     - Returns: Lista de tuplas com posição do centro do círculo (linha e coluna) e medida de caracterização de círculo (valor que indica a porcentagem de pixels encontrados para o círculo).
     
     */
    static func circle_hough(R:Int, matrix: Array<Array<Int>>,width:Int,height:Int,circles:Int,rect_to_search:CGRect,probcirc:CGPoint)->[(Int,Int,Double)]{
        
        var map = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
        var max = 0
        var i_max=0
        var j_max=0
        var max_pts = 0
        var ret = [(Int,Int,Double)]()
        let ox = Int(rect_to_search.origin.x)
        let oy = Int(rect_to_search.origin.y)
        let sw = Int(rect_to_search.size.width)
        let sh = Int(rect_to_search.size.height)
        
        for i in oy..<(oy + sh)
//        for var i:Int=oy;i<oy+sh;i++
        {
            for j in ox..<(ox + sw)
//            for var j:Int=ox;j<ox+sw;j++
            {
                if matrix[i][j] != 0{
                    var pts = 0
                    var aux = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
                    for k in j-R...j+R{
//                    for var k:Int=j-R;k<=j+R;k+=1{
                        let C = (k-j)*(k-j)
                        let CC = i*i + C - R*R
                        
                        let y1 = Int(round((Double(2*i) + pow(Double(4*i*i-4*CC),0.5))/2.0))
                        let y2 = Int(round((Double(2*i) - pow(Double(4*i*i-4*CC),0.5))/2.0))
                        
                        if k>=0 && k<width && y1>=0 && y1<height{
                            if aux[y1][k] == 0{
                                map[y1][k] += 1
                                aux[y1][k]=1
                                pts += 1
                            }
                        }
                        
                        if k>=0 && k<width && y2>=0 && y2<height{
                            if aux[y2][k] == 0{
                                map[y2][k] += 1
                                aux[y2][k]=1
                                pts += 1
                            }
                        }
                    }
                    for k in i-R...i+R{
//                    for var k:Int=i-R;k<=i+R;k+=1{
                        let C = (k-i)*(k-i)
                        let CC = j*j + C - R*R
                        
                        let y1 = Int(round((Double(2*j) + pow(Double(4*j*j-4*CC),0.5))/2.0))
                        let y2 = Int(round((Double(2*j) - pow(Double(4*j*j-4*CC),0.5))/2.0))
                        
                        if k>=0 && k<height && y1>=0 && y1<width{
                            if aux[k][y1] == 0{
                                map[k][y1] += 1
                                aux[k][y1]=1
                                pts += 1
                            }
                        }
                        
                        if k>=0 && k<height && y2>=0 && y2<width{
                            if aux[k][y2] == 0{
                                map[k][y2] += 1
                                aux[k][y2]=1
                                pts += 1
                            }
                        }
                    }
                    
                    if pts > max_pts{
                        max_pts = pts
                    }
                }
            }
        }
        for _ in 0..<circles
//        for(var kk:Int=0;kk<circles;kk++)
        {
            for ii in oy..<oy+sh
//            for var ii:Int=oy;ii<oy+sh;ii++
            {
                for jj in ox..<ox+sw
//                for var jj:Int=ox;jj<ox+sw;jj++
                {
                    if probcirc.x != -1 {
                        let dist = sqrt(pow(Double(probcirc.y)-Double(ii),2)+pow(Double(probcirc.x)-Double(jj),2))
                        map[ii][jj] = Int(Double(map[ii][jj]) * 1.0/(pow(1.01,dist)))
                    }
                    if map[ii][jj]>max{
                        max = map[ii][jj]
                        i_max = ii
                        j_max = jj
                    }
                }
            }
            
            ret.append((i_max,j_max,Double(max)/(Double(max_pts))))
            map[i_max][j_max] = 0
            max=0
        }
        
        return ret
    }
    
    /**
     Função que procura por círculos com diferentes raios em uma imagem.
     
     - Author: Ricardo Teles Freitas
     - Date: 03/11/2015
     - Warning: O campo de busca não deve exceder os limites da imagem.
     - SeeAlso: circle_hough(R:Int, matrix: Array<Array<Int>>,width:Int,height:Int,circles:Int,rect_to_search:NSRect)->[(Int,Int,Double)]
     
     - Parameter min: Tamanho mínimo do raio.
     - Parameter max: Tamanho máximo do raio.
     - Parameter matrix: Imagem onde procurar os círculos.
     - Parameter width: Largura da imagem.
     - Parameter height: altura da imagem.
     - Parameter rect_to_search: Porção da imagem onde devem ser procurados os círculos.
     - Parameter probcirc: Localização provável de um círculo
     - Returns: Lista de tuplas com posição do centro do círculo (linha e coluna), raio do círculo e medida de caracterização de círculo (valor que indica a porcentagem de pixels encontrados para o círculo). A lista é ordenada a partir da medida de caracterização.
     
     */
    static func circle_hough_multiple_radius(min:Int,max:Int,matrix:Array<Array<Int>>,width:Int,height:Int,rect_to_search:CGRect,probcirc:CGPoint) -> [(Int,Int,Int,Double)]{
        if min > max || min < 0 || max < 0{
            return [(0,0,0,0.0)]
        }
        
        print("Aplicando a transformada de Hough...")
        
//        var i_max=0
//        var j_max=0
//        var raio=0
//        var melhor:Double = -1.0
        var houghs = [(Int,Int,Int,Double)]()
        for i in min...max{
//        for var i:Int=min;i<=max;i++ {
            let circles = circle_hough(i,matrix: matrix,width: width,height: height,circles:1,rect_to_search:rect_to_search,probcirc:probcirc)
            
            for circle in circles{
                houghs.append((circle.0,circle.1,i,circle.2))
            }
        }
        
        print("Finalizando")
        
        return houghs.sort({$0.3 > $1.3})
    }
}
