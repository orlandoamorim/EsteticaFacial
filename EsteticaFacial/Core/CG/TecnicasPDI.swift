//
//  TecnicasPDI.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 29/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import GPUImage

/**
 # Técnicas de Processamento Digital de Imagens
Esta classe implementa técnicas consagradas de processamento digital de imagens. As funções transformam as imagens de maneira a facilitar a execução dos algoritmos de visão computacional:
    * **median**: Aplica o filtro estatístico da mediana em uma imagem
    * **sobel**: Executa uma convolução do operador Sobel com uma imagem
    * **canny**: Aplica o método de John F. Canny para detecção de bordas
*/
class TecnicasPDI: NSObject {
    static let PI = 3.141592
    /**
    # Filtragem Mediana
    Realiza a filtragem mediana (com máscara 3x3) em uma imagem. O filtro da mediana remove ruídos da imagem preservando as bordas.
    
    - Author: Ricardo Teles Freitas
    - Date: 30/10/2015
    - Warning: A função explora uma imagem com um nível de abstração baixo, que exige extremo cuidado na manipulação.
    - ToDo: Este código deve ser melhorado. Sua execução é bastante lenta.
    
    - Parameter matrix: Ponteiro para os pixels que compõem a imagem de entrada.
    - Parameter width: Largura da imagem.
    - Parameter height: Altura da imagem.
    - Returns: Ponteiro para os pixels que compõem a imagem filtrada.
    
    ![sub](/Users/ricardofreitas/Desktop/median.png)
    
    */
    static func median(matrix:UnsafeMutablePointer<RGBA>,width:Int,height:Int)->UnsafeMutablePointer<RGBA>{
        
        let pixels = UnsafeMutablePointer<RGBA>(calloc(height * width, sizeof(RGBA)))
        print("Aplicando a filtragem mediana...")
        for i in 0...height {
            for j in 0...width {
                var red = [UInt8]()
                var green = [UInt8]()
                var blue = [UInt8]()
                if i>=1 && j>=1{
                    red.append(matrix[(i-1)*width + j-1].r)
                    green.append(matrix[(i-1)*width + j-1].g)
                    blue.append(matrix[(i-1)*width + j-1].b)
                }
                
                if i>=1{
                    red.append(matrix[(i-1)*width + j].r)
                    green.append(matrix[(i-1)*width + j].g)
                    blue.append(matrix[(i-1)*width + j].b)
                }
                
                if i>=1 && j<width-1{
                    red.append(matrix[(i-1)*width + j+1].r)
                    green.append(matrix[(i-1)*width + j+1].g)
                    blue.append(matrix[(i-1)*width + j+1].b)
                }
                
                if j>=1{
                    red.append(matrix[(i)*width + j-1].r)
                    green.append(matrix[(i)*width + j-1].g)
                    blue.append(matrix[(i)*width + j-1].b)
                }
                
                
                red.append(matrix[(i)*width + j].r)
                green.append(matrix[(i)*width + j].g)
                blue.append(matrix[(i)*width + j].b)
                
                
                if j<width-1{
                    red.append(matrix[(i)*width + j+1].r)
                    green.append(matrix[(i)*width + j+1].g)
                    blue.append(matrix[(i)*width + j+1].b)
                }
                
                if i<height-1 && j>=1{
                    red.append(matrix[(i+1)*width + j-1].r)
                    green.append(matrix[(i+1)*width + j-1].g)
                    blue.append(matrix[(i+1)*width + j-1].b)
                }
                
                if i<height-1{
                    red.append(matrix[(i+1)*width + j].r)
                    green.append(matrix[(i+1)*width + j].g)
                    blue.append(matrix[(i+1)*width + j].b)
                }
                
                if i<height-1 && j<width-1{
                    red.append(matrix[(i+1)*width + j+1].r)
                    green.append(matrix[(i+1)*width + j+1].g)
                    blue.append(matrix[(i+1)*width + j+1].b)
                }
                
                red = red.sort({$0 < $1})
                green = green.sort({$0 < $1})
                blue = blue.sort({$0 < $1})
                
                pixels[i*width+j].r = red[red.count/2]
                pixels[i*width+j].g = green[green.count/2]
                pixels[i*width+j].b = blue[blue.count/2]
                pixels[i*width+j].a = 255
            }
        }
        print("Finalizando a filtragem mediana.")
        return pixels
    }
    
    //    static func erosion(matrix:UnsafeMutablePointer<RGBA>,width:Int,height:Int)->UnsafeMutablePointer<RGBA>{
    //
    //    }
    
    
    /**
    # Operador Sobel
    Realiza uma convolução do operador Sobel em uma imagem. O resultado é uma imagem binária contendo as bordas da imagem original.
    
    - Author: Ricardo Teles Freitas
    - Date: 30/10/2015
    - Warning: A função explora uma imagem com um nível de abstração baixo, que exige extremo cuidado na manipulação.
    - ToDo: Este código deve ser melhorado. Sua execução é lenta.
    
    - Parameter matrix: Ponteiro para os pixels que compõem a imagem de entrada.
    - Parameter width: Largura da imagem.
    - Parameter height: Altura da imagem.
    - Returns: Tupla com ponteiro para os pixels da imagem convoluída, matriz com as magnitudes do gradiente e matriz com as direções do gradiente.
    
    ![sub](/Users/ricardofreitas/Desktop/sobel_1.png)
    
    */
    static func sobel(matrix:UnsafeMutablePointer<RGBA>,width:Int,height:Int)->(UnsafeMutablePointer<RGBA>,Array<Array<Int>>,Array<Array<Int>>){
        let GX = [[-1,0,1],[-2,0,2],[-1,0,1]]
        let GY = [[1,2,1],[0,0,0],[-1,-2,-1]]
        
        print("Aplicando o operador Sobel")
        print("\(GX) | \(GY)")
        
        let pixels = UnsafeMutablePointer<RGBA>(calloc(height * width, sizeof(RGBA)))
        
        
        var pix = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
        var aux = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
        var aux2 = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
        var dir = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
        var gra = Array(count: height, repeatedValue: Array(count: width, repeatedValue: 0))
        
        for i in 0...height {
            for j in 0...width {
                // Canal vermelho desconsiderado
                pix[i][j] = Int(matrix[i*width+j].g/2 + matrix[i*width+j].b/2)
            }
        }
        
        for i in 0...height {
            for j in 0...width {
                if i>=1 && j>=1{
                    aux[i][j]+=GX[0][0]*pix[i-1][j-1]
                    aux2[i][j]+=GY[0][0]*pix[i-1][j-1]
                }
                
                if i>=1{
                    aux[i][j]+=GX[0][1]*pix[i-1][j]
                    aux2[i][j]+=GY[0][1]*pix[i-1][j]
                }
                
                if i>=1 && j<width-1{
                    aux[i][j]+=GX[0][2]*pix[i-1][j+1]
                    aux2[i][j]+=GY[0][2]*pix[i-1][j+1]
                }
                
                if j>=1{
                    aux[i][j]+=GX[1][0]*pix[i][j-1]
                    aux2[i][j]+=GY[1][0]*pix[i][j-1]
                }
                
                aux[i][j]+=GX[1][1]*pix[i][j]
                aux2[i][j]+=GY[1][1]*pix[i][j]
                
                
                if j<width-1{
                    aux[i][j]+=GX[1][2]*pix[i][j+1]
                    aux2[i][j]+=GY[1][2]*pix[i][j+1]
                }
                
                if i<height-1 && j>=1{
                    aux[i][j]+=GX[2][0]*pix[i+1][j-1]
                    aux2[i][j]+=GY[2][0]*pix[i+1][j-1]
                }
                
                if i<height-1{
                    aux[i][j]+=GX[2][1]*pix[i+1][j]
                    aux2[i][j]+=GY[2][1]*pix[i+1][j]
                }
                
                if i<height-1 && j<width-1{
                    aux[i][j]+=GX[2][2]*pix[i+1][j+1]
                    aux2[i][j]+=GY[2][2]*pix[i+1][j+1]
                }
                
                
                let ang = atan2(Double(aux2[i][j]),Double(aux[i][j]))*180.0/TecnicasPDI.PI
                dir[i][j] = Int(round(ang/45))*45
                
                
                gra[i][j] = Int(sqrt(Double(aux[i][j])*Double(aux[i][j])+Double(aux2[i][j])*Double(aux2[i][j])))
                var val = gra[i][j]
                //print("VAL \(val) - \(Double(aux[i][j])*Double(aux[i][j])) + \(Double(aux2[i][j])*Double(aux2[i][j]))")
                if val > 255 {
                    val = 255
                }
                pixels[i*width+j].r = UInt8(val)
                pixels[i*width+j].g = UInt8(val)
                pixels[i*width+j].b = UInt8(val)
                pixels[i*width+j].a = 255
            }
        }
        print("Finalizando o operador Sobel")
        // print("\(dir)")
        return (pixels,gra,dir)
    }
    
    /**
     # Detector de Bordas Canny
     Aplica o método de Canny para a detecção de bordas em uma imagem. Este algoritmo é o mais eficaz para detecção de bordas, contudo, sua execução é lenta em relação a outros detectores de borda.
     
     - Author: Ricardo Teles Freitas
     - Date: 31/10/2015
     - SeeAlso: sobel(matrix:UnsafeMutablePointer<RGBA>,width:Int,height:Int)->UnsafeMutablePointer<RGBA>
     
     - Parameter image: Imagem de entrada a ter bordas detectadas.
     - Parameter lower: Limiar de supressão de bordas fracas. Pixels de borda com gradiente abaixo deste valor serão suprimidos.
     - Parameter upper: Limiar de fortalecimento de bordas. Pixels de borda com gradiente acima deste valor são considerados fortes.
     - Returns: Imagem (em nível mais baixo) com as bordas detectadas.
     
     ![sub](/Users/ricardofreitas/Desktop/canny.png)
     
     */
    static func canny(image:UIImage,lower:CGFloat,upper:CGFloat)->UnsafeMutablePointer<RGBA>{
        let canny = GPUImageCannyEdgeDetectionFilter()
        canny.lowerThreshold = lower
        canny.upperThreshold = upper
        
        let output = canny.imageByFilteringImage(image)
        
        return UnsafeMutablePointer<RGBA>(TratamentoEntrada.uiimage_raw(output))
    }
    
    static func draw_circle(circles:[(Int,Int,Int,Double)],image:UIImage)->UIImage{
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        let pixels = TratamentoEntrada.uiimage_raw(image)
        let primeiro = UnsafeMutablePointer<RGBA>(pixels)
        
        for circle in circles{
            let ii = circle.0
            let jj = circle.1
            let r = Int(circle.2)
            
            primeiro[ii*width + jj].r = 255
            primeiro[ii*width + jj].g = 0
            primeiro[ii*width + jj].b = 0
            for k in jj-r...jj+r{
//            for var k:Int=jj-r;k<=jj+r;k+=1{
                let C = (k-jj)*(k-jj)
                let CC = ii*ii + C - r*r
                
                let y1 = Int(round((Double(2*ii) + pow(Double(4*ii*ii-4*CC),0.5))/2.0))
                let y2 = Int(round((Double(2*ii) - pow(Double(4*ii*ii-4*CC),0.5))/2.0))
                
                if k>=0 && k<width && y1>=0 && y1<height{
                    primeiro[y1*width + k].r = 131
                    primeiro[y1*width + k].g = 255
                    primeiro[y1*width + k].b = 0
                }
                
                if k>=0 && k<width && y2>=0 && y2<height{
                    primeiro[y2*width + k].r = 131
                    primeiro[y2*width + k].g = 255
                    primeiro[y2*width + k].b = 0
                }
            }
            for k in ii-r...ii+r{
//            for var k:Int=ii-r;k<=ii+r;k+=1{
                let C = (k-ii)*(k-ii)
                let CC = jj*jj + C - r*r
                
                let y1 = Int(round((Double(2*jj) + pow(Double(4*jj*jj-4*CC),0.5))/2.0))
                let y2 = Int(round((Double(2*jj) - pow(Double(4*jj*jj-4*CC),0.5))/2.0))
                
                if k>=0 && k<height && y1>=0 && y1<width{
                    primeiro[k*width + y1].r = 131
                    primeiro[k*width + y1].g = 255
                    primeiro[k*width + y1].b = 0
                }
                
                if k>=0 && k<height && y2>=0 && y2<width{
                    primeiro[k*width + y2].r = 131
                    primeiro[k*width + y2].g = 255
                    primeiro[k*width + y2].b = 0
                }
            }
        }
        return TratamentoEntrada.raw_to_uiimage(primeiro,largura:width,altura:height)
    }
}
