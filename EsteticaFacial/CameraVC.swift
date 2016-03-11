//
//  CameraVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/12/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import AVFoundation
import KYShutterButton
import TOCropViewController


class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate, NovoPacienteDelegate{

    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var libraryImages: UIButton!
    @IBOutlet weak var cameraButton: KYShutterButton!
    @IBOutlet weak var cancelarBtn: UIButton!
    @IBOutlet weak var cameraToolbar: UIToolbar!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var capturedImage: UIImageView = UIImageView()
    var imageTypesSelected:imageTypes = .Frontal
    var imageGetFrom:imageGet = .Camera
    
    var dicionario: [String:NSValue]?
    var pontosFrontalFrom:pontosFrontalType = .Nil
    var pontosPerfilFrom:pontosPerfilType = .Nil
    var pontosNasalFrom:pontosNasalType = .Nil
    
    var flashBtn:UIBarButtonItem = UIBarButtonItem()
    var imagemGuiaBtn:UIBarButtonItem = UIBarButtonItem()
    var spaceButton:UIBarButtonItem = UIBarButtonItem()
    
    var delegate: NovoPacienteDelegate! = nil
    
    var imageGuiaState:Bool = Bool()
    var cropViewController = TOCropViewController()


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageGuiaState = true
        Helpers.inicializeImageView(type: false, view:self.cameraView, imageTypesSelected: self.imageTypesSelected, x: nil, y: nil, width: nil, height: nil)
        
        self.flashBtn = UIBarButtonItem(image: UIImage(named: "FlashOff"), style: UIBarButtonItemStyle.Done, target: self, action: "flashState:")
        self.spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        self.imagemGuiaBtn = UIBarButtonItem(image: UIImage(named: "userFavi-32"), style: UIBarButtonItemStyle.Done, target: self, action: "imagemGuiaState:")
        flashBtn.tintColor = UIColor.whiteColor()
        imagemGuiaBtn.tintColor = UIColor.orangeColor()
        
        cameraToolbar.setItems([flashBtn, spaceButton, imagemGuiaBtn], animated: true)
        

        self.libraryImages.addTarget(self, action: "getLibraryImages:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cameraButton.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelarBtn.addTarget(self, action: "dismissView:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //**************//
//        print(imagemGuia.frame.size)
        
        //**************//
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Platform.isSimulator {
            print("NOTE: Simulador nao possui camera.")
        }else{
            previewLayer!.frame = cameraView.bounds
        }
        Helpers().getLatestPhotos { (images) -> () in
            self.libraryImages.setBackgroundImage(images[0], forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func takePhoto(sender: KYShutterButton) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let imagem = TratamentoEntrada.corrigir_orientacao(UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right))
                    
//                    let x_crop = imagem.size.width*self.imagemGuia.frame.origin.x/(self.previewLayer?.frame.width)!
//                    let y_crop = imagem.size.height*self.imagemGuia.frame.origin.y/(self.previewLayer?.frame.height)!
//                    let width_crop = imagem.size.width*self.imagemGuia.frame.size.width/(self.previewLayer?.frame.width)!
//                    let height_crop = imagem.size.height*self.imagemGuia.frame.size.height/(self.previewLayer?.frame.height)!
//                    
//                    self.capturedImage.image = TratamentoEntrada.recortar_imagem(imagem, rect: CGRectMake(x_crop, y_crop, width_crop, height_crop))
                    
                    self.imageGetFrom = .Camera
                    self.captureSession?.stopRunning()
                    self.inicializeCropViewController(imagem)

                }
            })
        }
    }

    
    func getLibraryImages(sender: UIButton) {
        //Criando o objeto que pode ter acesso a nossa camera e nossa biblioteca
        let imagePicker: UIImagePickerController = UIImagePickerController()
        
        //Liagando o Delegate
        imagePicker.delegate = self
        
        //Determinamos que o nosso image picker vai abrir o app de camera
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.editing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image: UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        self.capturedImage.image = image
        imageGetFrom = .Biblioteca
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.inicializeCropViewController(image)
        }
    }
    
    func inicializeCropViewController(image: UIImage){
//        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
//        UIDevice.currentDevice().
        cropViewController = TOCropViewController(image: image)
        
        cropViewController.delegate = self
//        cropViewController.toolbar.resetButtonEnabled = false
        cropViewController.defaultAspectRatio =  TOCropViewControllerAspectRatio.RatioSquare
//        cropViewController.lockedAspectRatio = true
//        cropViewController.cropView.aspectLockEnabled = false
//        cropViewController.cropView.l
        print(cropViewController.toolbarPosition.rawValue)
        switch cropViewController.toolbarPosition.rawValue {
        case 0: print("90")
        case 1: print("180")
        case 2: print("360")
        case 3: print("ihh")
        default: print("NADA")
        }
        
        cropViewController.toolbar.resetButton.hidden = true
        cropViewController.toolbar.clampButton.hidden = true
        cropViewController.cropView.cropBoxResizeEnabled = false
        cropViewController.toolbar.rotateButton.addTarget(self, action: "ajust", forControlEvents: UIControlEvents.TouchUpInside)
        self.presentViewController(cropViewController, animated: true) { () -> Void in
            self.ajust()
        }


        
    }
    
    func ajust(){
        Helpers.removeImageView(cropViewController.cropView)
        TOCropViewControllerAspectRatio.RatioSquare
        Helpers.inicializeImageView(type: true, view:cropViewController.cropView, imageTypesSelected: imageTypesSelected, x: cropViewController.cropView.cropBoxFrame.origin.x, y: cropViewController.cropView.cropBoxFrame.origin.y, width: cropViewController.cropView.cropBoxFrame.size.width, height: cropViewController.cropView.cropBoxFrame.size.height)
        
    }
    
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {

        cropViewController.dismissViewControllerAnimated(true) { () -> Void in
            
            self.capturedImage.image = image
            
//            print("****")
//            print("x -> \(cropViewController.cropView.cropBoxFrame.origin.x) || y -> \(cropViewController.cropView.cropBoxFrame.origin.y)")
//            print("****")
//            print("cropBoxFrame -> \(cropViewController.cropView.cropBoxFrame.size)")
//            print("--")
//            print("image.size -> \(image.size)")
//            print("--")
//            print(cropRect)
//            print("--")
//            print(angle)
//            print("****")
            
            self.performSegueWithIdentifier("PontosSegue", sender: nil)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "PontosSegue" && self.capturedImage.image != nil{
            if let processImagemVC = segue.destinationViewController as? ProcessarImagemVC{
                processImagemVC.delegate = self
                
                processImagemVC.imageGetFrom = self.imageGetFrom
                processImagemVC.imageTypesSelected = self.imageTypesSelected
                
                processImagemVC.image = self.capturedImage.image!
                processImagemVC.dicionario = self.dicionario
                
                processImagemVC.pontosFrontalFrom = self.pontosFrontalFrom
                processImagemVC.pontosPerfilFrom = self.pontosPerfilFrom
                processImagemVC.pontosNasalFrom = self.pontosNasalFrom
            }
        }
    }
    
    
    func flashState(button: UIBarButtonItem) {
        let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        // check if the device has torch
        if avDevice.hasTorch {
            // lock your device for configuration
            do {
                _ = try avDevice.lockForConfiguration()
            } catch {
                print("NOTE: Simulador nao possui flash.")
            }
            
            // check if your torchMode is on or off. If on turns it off otherwise turns it on
            if avDevice.torchActive {
                avDevice.torchMode = AVCaptureTorchMode.Off
                self.flashBtn.image = UIImage(named: "FlashOff")
                flashBtn.tintColor = UIColor.whiteColor()

            } else {
                // sets the torch intensity to 100%
                do {
                    _ = try avDevice.setTorchModeOnWithLevel(1.0)
                } catch {
                    print("NOTE: Simulador nao possui flash.")
                }
                self.flashBtn.image = UIImage(named: "FlashOn")
                flashBtn.tintColor = UIColor.yellowColor()
            }
            // unlock your device
            avDevice.unlockForConfiguration()
        }

    }
    
    func imagemGuiaState(button: UIBarButtonItem) {
        if imageGuiaState == true {
            self.imageGuiaState = false
            self.imagemGuiaBtn.tintColor = UIColor.whiteColor()
            Helpers.removeImageView(cameraView)
        }else{
            self.imageGuiaState = true
            self.imagemGuiaBtn.tintColor = UIColor.orangeColor()
            Helpers.inicializeImageView(type: false, view: self.cameraView, imageTypesSelected: self.imageTypesSelected, x: nil, y: nil, width: nil, height: nil)
        }
    }

    
    func dismissView(sender: UIButton) {
        captureSession?.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func atribuir_imagem(imagem: UIImage, imageTypesSelected: imageTypes) {
        self.delegate.atribuir_imagem(imagem, imageTypesSelected: imageTypesSelected)
    }
    
    func atribuir_marcacao(dic: [String : NSValue], imageTypesSelected: imageTypes, pontosFrontalFrom: pontosFrontalType, pontosPerfilFrom: pontosPerfilType, pontosNasalFrom: pontosNasalType) {
        self.delegate.atribuir_marcacao(dic, imageTypesSelected: imageTypesSelected, pontosFrontalFrom: pontosFrontalFrom, pontosPerfilFrom: pontosPerfilFrom, pontosNasalFrom: pontosNasalFrom)

    }

}
