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
                localizar.pontos_localizados = self.dicionario
                localizar.delegate = self
                if self.imagem_capturada.image != nil{
                    localizar.imagem_cortada = self.imagem_capturada.image
                }
                else{
                    localizar.imagem_cortada = self.imagem_recuperada
                }
                
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
                let imagem = TratamentoEntrada.corrigir_orientacao(UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right))
                
                let x_crop = imagem.size.width*self.quadro_corte.frame.origin.x/(self.camada_preview?.frame.width)!
                let y_crop = imagem.size.height*self.quadro_corte.frame.origin.y/(self.camada_preview?.frame.height)!
                let width_crop = imagem.size.width*self.quadro_corte.frame.size.width/(self.camada_preview?.frame.width)!
                let height_crop = imagem.size.height*self.quadro_corte.frame.size.height/(self.camada_preview?.frame.height)!
                
                self.imagem_capturada.image = TratamentoEntrada.recortar_imagem(imagem, rect: CGRectMake(x_crop, y_crop, width_crop, height_crop))
                self.delegate!.atribuir_imagem(self.imagem_capturada.image!, flag: self.flag)
                
              //  self.imagem_capturada.image = TratamentoEntrada.resize_image(self.imagem_capturada.image!, scale_w: 0.2, scale_h: 0.2)
                
//                let canny = GPUImageCannyEdgeDetectionFilter()
//                canny.lowerThreshold = 0.05
//                canny.upperThreshold = 0.15
//                
//                let output = canny.imageByFilteringImage(self.imagem_capturada.image)
//                self.imagem_capturada.image = output
                
            })
            
            
        }
    }
    
    func marcar_pontos(dic: [String : NSValue]) {
        delegate.atribuir_marcacao(dic, flag: flag)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
