//
//  EditarImagemVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 26/12/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class EditarImagemVC: UIViewController,UIScrollViewDelegate{

    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelarBtn: UIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imagemGuia: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var editarToolbar: UIToolbar!
    
    var image:UIImage = UIImage()
    var imageView: UIImageView = UIImageView()
    
    var imageTypesSelected:imageTypes = .Frontal
    var imageGetFrom:imageGet = .Camera
    var dicionario: [String:NSValue]?

    var editState:Bool = Bool()
    
    var editarBtn:UIBarButtonItem = UIBarButtonItem()
    var imagemGuiaBtn:UIBarButtonItem = UIBarButtonItem()
    var spaceButton:UIBarButtonItem = UIBarButtonItem()
    var salvarBtn:UIBarButtonItem = UIBarButtonItem()

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagemGuia.layer.cornerRadius = 4
        self.imagemGuia.layer.masksToBounds = true
        self.imagemGuia.layer.borderWidth = 1
        self.imagemGuia.layer.borderColor = UIColor.whiteColor().CGColor
        self.imagemGuia.hidden = true
        
//        self.imageScrollView.layer.cornerRadius = 4
//        self.imageScrollView.layer.masksToBounds = true
//        self.imageScrollView.layer.borderWidth = 1
//        self.imageScrollView.layer.borderColor = UIColor.whiteColor().CGColor

        switch imageTypesSelected {
        case.Frontal:   self.imagemGuia.image = UIImage(named: "modelo_frontal")
        case.Perfil:    self.imagemGuia.image = UIImage(named: "modelo_perfil")
        case.Nasal:     self.imagemGuia.image = UIImage(named: "modelo_nasal")
        }
        
        imageScrollView.delegate = self
        imageView.frame = CGRectMake(0, 0, imageScrollView.frame.size.width, imageScrollView.frame.size.height)
//        imageView.image = self.imagemGuia.image
        imageView.userInteractionEnabled = true
        imageScrollView.addSubview(imageView)
        loadImage()
        
        self.editarBtn = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.Done, target: self, action: "editar:")
        self.spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        self.imagemGuiaBtn = UIBarButtonItem(image: UIImage(named: "userFavi-32"), style: UIBarButtonItemStyle.Done, target: self, action: "imagemGuiaState:")
        
        self.salvarBtn = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Done, target: self, action: "salvarAlteracoes:")
        
        self.editarBtn.tintColor = UIColor.whiteColor()
        self.imagemGuiaBtn.tintColor = UIColor.whiteColor()
        self.salvarBtn.tintColor = UIColor.orangeColor()

        backgroundImage.image = image
        imageScrollView.hidden = true
        editarToolbar.setItems([editarBtn, spaceButton], animated: true)
//        
//        switch imageGetFrom {
//        case .Camera:   backgroundImage.image = image
//                        imageScrollView.hidden = true
//                        editarToolbar.setItems([editarBtn, spaceButton], animated: true)
//        case .Biblioteca:   addEffect()
//                            backgroundImage.image = image
//                            imageScrollView.hidden = false
//                            editarToolbar.setItems([spaceButton, imagemGuiaBtn], animated: true)
//            
//        }

        
        self.okBtn.addTarget(self, action: "addPontos:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelarBtn.addTarget(self, action: "dismissView:", forControlEvents: UIControlEvents.TouchUpInside)
        
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
    
    func loadImage(){
        imageView.image = image
        imageView.contentMode = UIViewContentMode.Center
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        
        imageScrollView.contentSize = image.size
        
        let scrollViewFrame = imageScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / imageScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / imageScrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        
        imageScrollView.minimumZoomScale = minScale
        imageScrollView.maximumZoomScale = 2
        imageScrollView.zoomScale = minScale
        
        centerScrollViewContents()
    }
    
    func centerScrollViewContents(){
        let boundsSize = imageScrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }
        
        imageView.frame = contentsFrame
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    


    func addPontos(sender: UIButton) {
        self.performSegueWithIdentifier("PontosSegue", sender: nil)
    }
    
    func cropImage() -> UIImage {
//        let x_crop = imagem.size.width*self.imagemGuia.frame.origin.x/(self.previewLayer?.frame.width)!
//        let y_crop = imagem.size.height*self.imagemGuia.frame.origin.y/(self.previewLayer?.frame.height)!
//        let width_crop = imagem.size.width*self.imagemGuia.frame.size.width/(self.previewLayer?.frame.width)!
//        let height_crop = imagem.size.height*self.imagemGuia.frame.size.height/(self.previewLayer?.frame.height)!
//        
//        self.capturedImage.image = TratamentoEntrada.recortar_imagem(imagem, rect: CGRectMake(x_crop, y_crop, width_crop, height_crop))
        
//        let x = imageScrollView.
        
        
        
        UIGraphicsBeginImageContextWithOptions(imageScrollView.bounds.size, true, UIScreen.mainScreen().scale)
        let offset = imageScrollView.contentOffset
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y)
        imageScrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        
//        
//        let alert = UIAlertController(title: "Image saved", message: "Your image has been saved to your camera roll", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
        print("TAMANHO DA IMAGEM \(image.size)")
        return image
    }

    func editar(button: UIBarButtonItem) {
        
        if editState == true {
            self.editState = false
        
            removeEffect()
            self.editarBtn.title = "Editar"
            self.editarBtn.tintColor = UIColor.whiteColor()
            self.imageScrollView.hidden = true
            self.imagemGuia.hidden = true
            self.editarToolbar.setItems([editarBtn, spaceButton], animated: true)

        }else{
            self.editState = true
            
            addEffect()
            self.editarBtn.title = "Cancelar"
            self.editarBtn.tintColor = UIColor.redColor()
            self.imageScrollView.hidden = false
            self.editarToolbar.setItems([editarBtn,spaceButton, imagemGuiaBtn,spaceButton, salvarBtn], animated: true)

        }
    }
    
    func imagemGuiaState(button: UIBarButtonItem) {
        if self.imagemGuia.hidden == true {
            self.imagemGuia.hidden = false
            self.imagemGuiaBtn.tintColor = UIColor.orangeColor()
        }else {
            self.imagemGuia.hidden = true
            self.imagemGuiaBtn.tintColor = UIColor.whiteColor()

        }
    }
    
    func salvarAlteracoes(button: UIBarButtonItem){
        self.editState = false
        backgroundImage.image = cropImage()
        image = cropImage()
//        imageView.image = cropImage()
        loadImage()

        removeEffect()
        self.editarBtn.title = "Editar"
        self.editarBtn.tintColor = UIColor.whiteColor()
        self.imageScrollView.hidden = true
        self.imagemGuia.hidden = true
        self.editarToolbar.setItems([editarBtn, spaceButton], animated: true)

    }
    
    func addEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImage.bounds
        backgroundImage.addSubview(blurEffectView)
    }
    
    func removeEffect(){
        self.backgroundImage.subviews.forEach ({
            if $0 is UIVisualEffectView {
                $0.removeFromSuperview()
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PontosSegue"{
            if let localizar = segue.destinationViewController as? ProcessarImagemVC{
                localizar.imageTypesSelected = self.imageTypesSelected
                localizar.image = self.image
                localizar.dicionario = dicionario

            }
        }
    }
    
    func dismissView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}