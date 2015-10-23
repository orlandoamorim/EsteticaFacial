//
//  CameraViewController.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 18/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

protocol CameraViewDelegate{
    func marcar_pontos(dic : [String:NSValue])
}

class CameraViewController: UIViewController, CameraViewDelegate {
    
    var delegate: NovoPacienteDelegate! = nil
    
    @IBOutlet weak var imagem_guia: UIImageView!
    @IBOutlet weak var quadro_corte: UIView!
    @IBOutlet weak var preview_imagem: UIView!
    @IBOutlet weak var imagem_capturada: UIImageView!
    
    var sessao_captura: AVCaptureSession?
    var imagem_saida: AVCaptureStillImageOutput?
    var camada_preview: AVCaptureVideoPreviewLayer?
    var imagem_recuperada: UIImage?
    
    var dicionario: [String:NSValue]?
    
    // Indica que foto (perspectiva) deve ser tirada
    var flag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("FLAG = \(flag)")
        if flag == 0{
            self.imagem_guia.image = UIImage.init(named: "modelo_frontal")
        }
        if flag == 1{
            self.imagem_guia.image = UIImage.init(named: "modelo_perfil")
        }
        if flag == 2{
            self.imagem_guia.image = UIImage.init(named: "modelo_nasal")
        }
        
        if self.imagem_recuperada != nil{
            self.performSegueWithIdentifier("segue_localizar", sender: self);
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Funcao de configuracoes padrao do dispositivo de captura, da previsualizacao e imagem de saida
    
    override func viewWillAppear(animated: Bool) {
        sessao_captura = AVCaptureSession()
        sessao_captura!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let dispositivo_captura = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // var erro: NSError?
        var entrada : AVCaptureDeviceInput?
        do{
            entrada = try AVCaptureDeviceInput(device: dispositivo_captura)
        }
        catch _ {
            entrada = nil
            print("Algo deu errado")
        }
        
        if entrada != nil && sessao_captura!.canAddInput(entrada){
            sessao_captura!.addInput(entrada)
        }
        
        imagem_saida = AVCaptureStillImageOutput()
        imagem_saida?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        sessao_captura!.addOutput(imagem_saida)
        
        camada_preview = AVCaptureVideoPreviewLayer(session: sessao_captura)
        
        camada_preview!.frame = preview_imagem.bounds
        
        preview_imagem.layer.addSublayer(camada_preview!)
        preview_imagem.layer.addSublayer(quadro_corte.layer)
        
        
        sessao_captura?.startRunning();
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segue_localizar" && self.imagem_capturada != nil{
            if let localizar = segue.destinationViewController as? LocalizarPontosViewController{
                if self.imagem_capturada.image != nil{
                    localizar.imagem_cortada = self.imagem_capturada.image
                }
                else{
                    localizar.imagem_cortada = self.imagem_recuperada
                }
                localizar.pontos_localizados = self.dicionario
                localizar.delegate = self
            }
        }
    }
    
    
    // Funcao que efetiva a captura da imagem e a recorta em um quadro de tamanho e posicao determinados em self.quadro_corte
    
    @IBAction func capturar_imagem(sender: AnyObject) {
        
        if let conexao_video = imagem_saida!.connectionWithMediaType(AVMediaTypeVideo) {
            imagem_saida!.captureStillImageAsynchronouslyFromConnection(conexao_video, completionHandler: {(sample_buffer, erro) in
                let dados_imagem = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample_buffer)
                let fornecedor = CGDataProviderCreateWithCFData(dados_imagem)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(fornecedor, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                let imagem = CameraViewController.fixImageOrientation(UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right))
                
                let x_crop = imagem.size.width*self.quadro_corte.frame.origin.x/(self.camada_preview?.frame.width)!
                let y_crop = imagem.size.height*self.quadro_corte.frame.origin.y/(self.camada_preview?.frame.height)!
                let width_crop = imagem.size.width*self.quadro_corte.frame.size.width/(self.camada_preview?.frame.width)!
                let height_crop = imagem.size.height*self.quadro_corte.frame.size.height/(self.camada_preview?.frame.height)!
                
                self.imagem_capturada.image = CameraViewController.cropToSquare(imagem, rect: CGRectMake(x_crop, y_crop, width_crop, height_crop))
                print("DEBUGGING");
                self.delegate!.atribuir_imagem(self.imagem_capturada.image!, flag: self.flag)
                print("DEBUGGING");
            })
            
            
        }
    }
    
    // Funcao que recorta uma imagem de entrada
    
    static func cropToSquare(originalImage: UIImage, rect:CGRect) -> UIImage {
        
        let imageRef: CGImageRef =  CGImageCreateWithImageInRect(originalImage.CGImage, rect)!
        
        let newImage: UIImage = UIImage(CGImage: imageRef)
        
        print("width = \(newImage.size.width) | height = \(newImage.size.height)")
        
//        let mediana: GPUImageMedianFilter = GPUImageMedianFilter()
//        mediana.forceProcessingAtSize(CGSizeMake(500, 500))
//        
//        let newImageGPU: UIImage = mediana.imageByFilteringImage(newImage)
//        let newImageRef = CGImageCreateWithImageInRect(newImageGPU.CGImage, CGRectMake(0, 0, 500, 500))
//        let newImageGPU2 = UIImage(CGImage: newImageRef!)
        
        return newImage
    }

    // Funcao que corrige problemas de orientacao da imagem original
    
    static func fixImageOrientation(src:UIImage)->UIImage {
        
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
    
    func marcar_pontos(dic: [String : NSValue]) {
        delegate.atribuir_marcacao(dic, flag: flag)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
