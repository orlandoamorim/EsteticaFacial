//
//  VerifyImageVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 31/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import TOCropViewController
import AssetsLibrary
import DeviceKit

class VerifyImageVC: UIViewController{

    var delegate:ImageVerification!
    var capturedImage:UIImage?
    var croppedImage:UIImage?
    
    var imageType:ImageTypes = .Front
    let imageTypeCrop:[ImageTypes] = [.Front, .ProfileRight, .Nasal]
    
    var cropViewController = TOCropViewController()
    
    enum HelpImageState {
        case On, Off
    }
    var helpImageState:HelpImageState = .Off
    
    let library:ALAssetsLibrary = ALAssetsLibrary()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var undo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        undo.hidden = true
        imageView.image = capturedImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okBtn(sender: AnyObject) {
        let alert:UIAlertController = UIAlertController(title: NSLocalizedString("", comment:""), message: NSLocalizedString("Agora que você escolheu a imagem correta, vamos recortar a imagem para pegarmos apenas aquilo que nos interessa.", comment:""), preferredStyle: UIAlertControllerStyle.ActionSheet)
        if let popView = alert.popoverPresentationController {
            popView.sourceView = sender as! UIButton
            popView.sourceRect = sender.bounds
        }
        
        if imageTypeCrop.contains(imageType) {

            if croppedImage == nil {
                alert.addAction(UIAlertAction(title: "Recortar", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.askImageguia(sender)
                }))
            }else{
                alert.message = NSLocalizedString("Tome cuidado ao recortar uma imagem ja recortada. Isto pode ocasionar perda da qualiade da imagem.", comment:"")
                alert.addAction(UIAlertAction(title: NSLocalizedString("Usar esta Imagem", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.askSaveImage(sender)
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recortar Novamente", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.askImageguia(sender)
                }))
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: UIAlertActionStyle.Cancel, handler: nil))
            
        }else{
            if croppedImage == nil {
                alert.message = NSLocalizedString("Agora que você escolheu a imagem correta, vamos recortar a imagem para pegarmos apenas aquilo que nos interessa. Obs: Esta imagem não sera processada, então o recorte da mesma não é necessario.", comment:"")
                alert.addAction(UIAlertAction(title: NSLocalizedString("Usar esta Imagem", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.askSaveImage(sender)

                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recortar", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.presentCropViewController(self.imageView.image!)
                }))
            }else{
                alert.message = NSLocalizedString("Tome cuidado ao recortar uma imagem ja recortada. Isto pode ocasionar perda da qualiade da imagem. Obs: Esta imagem não sera processada, então o recorte da mesma não é necessario.", comment:"")
                alert.addAction(UIAlertAction(title: NSLocalizedString("Usar esta Imagem", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.askSaveImage(sender)

                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Recortar Novamente", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.presentCropViewController(self.imageView.image!)
                }))
            }
            
        
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.layoutIfNeeded()

    }
    
    func askImageguia(sender: AnyObject){
        let alert:UIAlertController = UIAlertController(title: NSLocalizedString("", comment:""), message: NSLocalizedString("Deseja usar imagem guia. Ela pode lhe ajudar na hora de recortar a imagem", comment:""), preferredStyle: UIAlertControllerStyle.ActionSheet)
        if let popView = alert.popoverPresentationController {
            popView.sourceView = sender as! UIButton
            popView.sourceRect = sender.bounds
        }


        alert.addAction(UIAlertAction(title: NSLocalizedString("Usar", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.helpImageState = .On
            self.presentCropViewController(self.imageView.image!)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Não Usar", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.helpImageState = .Off
            self.presentCropViewController(self.imageView.image!)
        }))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.layoutIfNeeded()

    }
    
    
    func askSaveImage(sender: AnyObject){
        let alert:UIAlertController = UIAlertController(title: NSLocalizedString("", comment:""), message: NSLocalizedString("Desaja salvar esta imagem na biblioteca de fotos?", comment:""), preferredStyle: UIAlertControllerStyle.ActionSheet)
        if let popView = alert.popoverPresentationController {
            popView.sourceView = sender as! UIButton
            popView.sourceRect = sender.bounds
        }
        
            
        if croppedImage == nil {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Salvar Imagem", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.library.writeImageDataToSavedPhotosAlbum(UIImagePNGRepresentation(self.imageView.image!) , metadata: nil, completionBlock: nil)
                self.delegate.imageVerification(image: self.imageView.image, ImageVerify: ImageVerificationType.Ok)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Nao Salvar", comment:""), style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.delegate.imageVerification(image: self.imageView.image, ImageVerify: ImageVerificationType.Ok)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
        }else{
            //Imagem Original
            alert.addAction(UIAlertAction(title: NSLocalizedString("Apenas Original", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.library.writeImageDataToSavedPhotosAlbum(UIImagePNGRepresentation(self.capturedImage!) , metadata: nil, completionBlock: nil)
                self.delegate.imageVerification(image: self.imageView.image, ImageVerify: ImageVerificationType.Ok)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            //Apenas Recortada
            alert.addAction(UIAlertAction(title: NSLocalizedString("Apenas Recortada", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.library.writeImageDataToSavedPhotosAlbum(UIImagePNGRepresentation(self.imageView.image!) , metadata: nil, completionBlock: nil)
                self.delegate.imageVerification(image: self.imageView.image, ImageVerify: ImageVerificationType.Ok)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            //Original e Recortada
            alert.addAction(UIAlertAction(title: NSLocalizedString("Original e Recortada", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.library.writeImageDataToSavedPhotosAlbum(UIImagePNGRepresentation(self.capturedImage!) , metadata: nil, completionBlock: nil)
                self.library.writeImageDataToSavedPhotosAlbum(UIImagePNGRepresentation(self.imageView.image!) , metadata: nil, completionBlock: nil)
                self.delegate.imageVerification(image: self.imageView.image, ImageVerify: ImageVerificationType.Ok)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Nao Salvar", comment:""), style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.delegate.imageVerification(image: self.imageView.image, ImageVerify: ImageVerificationType.Ok)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.layoutIfNeeded()

    }
    
    
    
    @IBAction func undoBtn(sender: AnyObject) {
        if croppedImage != nil {
            let alert:UIAlertController = UIAlertController(title: "", message: NSLocalizedString("Aqui você pode voltar a usar a imagem original proveniente ou da Camera ou da sua BibLioteca", comment:""), preferredStyle: UIAlertControllerStyle.ActionSheet)
            if let popView = alert.popoverPresentationController {
                popView.sourceView = sender as! UIButton
                popView.sourceRect = sender.bounds
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Voltar Foto Original", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.undo.hidden = true
                self.croppedImage = nil
                self.imageView.image = self.capturedImage!
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: UIAlertActionStyle.Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            alert.view.layoutIfNeeded()

        }
    }
    
    
    @IBAction func cancelBtn(sender: AnyObject) {
        self.delegate.imageVerification(image: nil, ImageVerify: ImageVerificationType.Retake)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension VerifyImageVC:  TOCropViewControllerDelegate {
    
    func updateImageGuiaView(){
        Helpers.removeImageView(cropViewController.cropView)
        print(self.cropViewController.cropView.cropBoxFrame)
        Helpers.inicializeImageView(type: true, view: cropViewController.cropView , imageTypes: imageType, cropBoxFrame: cropViewController.cropView.cropBoxFrame)
    }
    
    
    func presentCropViewController(image: UIImage) {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioLocked = true
        cropViewController.defaultAspectRatio =  TOCropViewControllerAspectRatio.RatioSquare
        self.cropViewController = cropViewController
        
        presentViewController(self.cropViewController, animated: true, completion: nil)
        print(self.cropViewController.cropView.cropBoxFrame)
        switch helpImageState {
        case .On:
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateImageGuiaView), name: UIDeviceOrientationDidChangeNotification, object: nil)
                Helpers.inicializeImageView(type: true, view: cropViewController.cropView , imageTypes: imageType, cropBoxFrame: cropViewController.cropView.cropBoxFrame)
            
        case .Off: print("")
        }
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismissViewControllerAnimated(true) { () -> Void in
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.croppedImage = image
            self.imageView.image = image
            self.undo.hidden = false
        }
    }
}
