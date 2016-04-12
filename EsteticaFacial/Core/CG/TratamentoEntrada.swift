//
//  TratamentoEntrada.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 29/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

/**
 Estrutura de um pixel. Cada campo representa um canal do sistema RGBA e pode assumir valores inteiros que variam de 0 a 255.
 */
struct RGBA {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}

/**
 # Tratamento de Imagem Capturada
 Esta classe fornece funções para tratar uma imagem capturada pela câmera de um dispositivo que não é adequada para o processamento.
 As funções têm como objetivo corrigir qualquer problema que possa influenciar negativamente em posteriores etapas de processamento. São elas:
    * **recortar_imagem**: Seleciona uma porção da imagem de entrada
    * **corrigir_orientacao**: Corrige a orientação da imagem de entrada em relação à tela do dispositivo de captura
    * **uiimage_raw**: Reduz o nível de abstração de uma imagem, permitindo manipulação direta dos pixels
    * **raw_to_uiimage**: Aumenta o nível de abstração de uma imagem, permitindo uso direto no ambiente gráfico do iOS
 */
class TratamentoEntrada: NSObject {
    
    /**
     Função que gera uma imagem recortada da entrada. Originalmente implementada para segmentação facial, pode ser usada para fins semelhantes.
     
     - Author: Ricardo Teles Freitas
     - Date: 29/10/2015
     
     - Parameter originalImage: Imagem de entrada.
     - Parameter rect: Região que deve ser cortada.
     - Returns: Imagem **originalImage** cortada em **rect**.
     
     ```
     TratamentoImage.recortar_imagem(UIImage.init("imagem.png"), rect: CGRectMake(0.0, 0.0, 50.0, 50.0))
     ```
     */
    static func recortar_imagem(originalImage: UIImage, rect:CGRect) -> UIImage {
        
        let imageRef: CGImageRef =  CGImageCreateWithImageInRect(originalImage.CGImage, rect)!
        
        let newImage: UIImage = UIImage(CGImage: imageRef)
        
        return newImage
    }
    
    
    /**
     Responsável por consertar a orientação da imagem capturada. Devido a conflitos na orientação da tela no momento da captura (provavelmente oriundos da posição informada por sensores que orientam a tela) a imagem fornecida apresenta problemas que refletem nas fases posteriores de processamento. Antes de qualquer processamento, é necessário corrigir este defeito na captura.
     
     - Author: Ricardo Teles Freitas
     - Date: 29/10/2015
     
     - Parameter src: Imagem com orientação incorreta
     - Returns: Imagem **src** com a orientação adequada
     
     */
    static func corrigir_orientacao(src:UIImage)->UIImage {
        
        if src.imageOrientation == UIImageOrientation.Up {
            return src
        }
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch src.imageOrientation {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, src.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
        case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            CGAffineTransformTranslate(transform, src.size.width, 0)
            CGAffineTransformScale(transform, -1, 1)
            break
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            CGAffineTransformTranslate(transform, src.size.height, 0)
            CGAffineTransformScale(transform, -1, 1)
        case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
            break
        }
        
        
        let ctx:CGContextRef = CGBitmapContextCreate(nil, Int(src.size.width),Int(src.size.height), CGImageGetBitsPerComponent(src.CGImage), 0, CGImageGetColorSpace(src.CGImage), CGImageGetBitmapInfo(src.CGImage).rawValue)!
        
        CGContextConcatCTM(ctx, transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.height, src.size.width), src.CGImage)
            break
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.width, src.size.height), src.CGImage)
            break
        }
        
        let cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)!
        let img:UIImage = UIImage(CGImage: cgimg)
        
        return img
    }
    
    
    /**
     Converte os dados de um objeto *UIImage* para um vetor manipulável. O nível de abstração da classe *UIImage* não permite manipulação direta dos pixels. Esta função permite extrair os dados necessários para isso.
     
     - Author: Desconhecido
     - Date: 29/10/2015
     - Warning: A função gera uma imagem com um nível de abstração menor, que exige extremo cuidado na manipulação.
     - Important: A orientação da imagem pode causar problemas na conversão dos dados.
     - SeeAlso: raw_to_uiimage(pixels:UnsafeMutablePointer<Void>, largura:Int, altura:Int)->UIImage
     
     - Parameter image: Imagem a ser convertida
     - Returns: Vetor que agrupa todas as linhas da imagem. Cada elemento do vetor representa um pixel (struct RGBA).
     
     ```
     let raw = UnsafeMutablePointer<RGBA>(TratamentoImagem(image))
     
     raw[i * image.size.width + j].r = 137
     ```
     */
    static func uiimage_raw(image:UIImage)->UnsafeMutablePointer<Void>{
        let inputCGImage = image.CGImage
        
        let width = CGImageGetWidth(inputCGImage)
        let height = CGImageGetHeight(inputCGImage)
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let pixels = calloc(height * width, sizeof(RGBA))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage)
        
        return pixels
    }
    
    
    /**
     Cria um objeto UIImage a partir de um vetor de pixels.
     
     - Author: Desconhecido
     - Date: 29/10/2015
     - Warning: Deve-se ter atenção com os parâmetros para que os limites do vetor não sejam excedidos.
     - SeeAlso: *uiimage_raw(image:UIImage)->UnsafeMutablePointer<Void>*
     
     - Parameter pixels: Ponteiro para os pixels que compõem a imagem.
     - Parameter largura: Quantidade de colunas da imagem.
     - Parameter altura: Qauntidade de linhas da imagem.
     - Returns: Objeto *UIImage* formado a partir de **pixels**.
     */
    static func raw_to_uiimage(pixels:UnsafeMutablePointer<Void>, largura:Int, altura:Int)->UIImage{
        let width = largura
        let height = altura
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let newCGImage = CGBitmapContextCreateImage(context)
        let processedImage = UIImage(CGImage: newCGImage!)
        
        return processedImage
    }
    
    
    /**
     Redimensiona a imagem de entrada. Usada para reduzir o tempo de processamento dos algoritmos.
     
     - Author: NSHipster
     - Date: 03/11/2015
     
     - Parameter image: Imagem a ser redimensionada.
     - Returns: Imagem redimensionada.
     
     */
    static func resize_image(image:UIImage,scale_w:CGFloat,scale_h:CGFloat)->UIImage{
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(scale_w, scale_h))
        print("SIZE: \(image.size) - NEW \(size)")
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
