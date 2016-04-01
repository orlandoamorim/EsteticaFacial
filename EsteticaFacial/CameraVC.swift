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
import AssetsLibrary
import DeviceKit

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    // MARK: - Constants
    
    var delegate: RecordImageDelegate! = nil
    var imageType:ImageTypes = .Front

    let cameraManager = CameraManager()
    var cropViewController = TOCropViewController()
    let library:ALAssetsLibrary = ALAssetsLibrary()
    
    var capturedImage: UIImage?

    // MARK: - @IBOutlets
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var libraryImages: UIButton!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var helpImageBtn: UIButton!
    
    @IBOutlet weak var cameraToolbar: UIToolbar!
    @IBOutlet weak var cancelBtn: UIButton!

    
    var flashBarBtn:UIBarButtonItem = UIBarButtonItem()
    var helpImageBarBtn:UIBarButtonItem = UIBarButtonItem()
    var spaceBarBtn:UIBarButtonItem = UIBarButtonItem()
    
    enum HelpImageState {
        case On, Off
    }
    var helpImageState:HelpImageState = .Off

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        setCameraAjusts()
        print(imageType)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.resumeCaptureSession()
        
        Helpers().getLatestPhotos { (images) -> () in
            self.libraryImages.setBackgroundImage(images[0], forState: UIControlState.Normal)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self)
        cameraManager.stopCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLayout() {
        if !Device().isPad {
            self.flashBarBtn = UIBarButtonItem(image: UIImage(named: "FlashOff"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(CameraVC.flashState))
            self.spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            
            self.helpImageBarBtn = UIBarButtonItem(image: UIImage(named: "modelOffIcon"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(imagemGuiaState))
            
            
            cameraToolbar.setItems([flashBarBtn, spaceBarBtn, helpImageBarBtn], animated: true)
            
        }else{
            
            self.helpImageBtn.setImage(UIImage(named: "modelOffIcon"), forState: UIControlState.Normal)
            self.helpImageBtn.addTarget(self, action: #selector(imagemGuiaState), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.flashBtn.addTarget(nil, action: #selector(CameraVC.flashState) , forControlEvents: UIControlEvents.TouchUpInside)
            
        }
        let imageTypeCrop:[ImageTypes] = [.Front, .ProfileRight, .Nasal]

        if !imageTypeCrop.contains(imageType) {
            print("ENTROU ERRO")
            if Device().isPad {
                self.helpImageBtn.enabled = false
            }else{
                self.helpImageBarBtn.enabled = false
            }
        }
        
        self.cameraBtn.setImage(UIImage(named:"cameraButton" ), forState: UIControlState.Normal)
        self.cameraBtn.setImage(UIImage(named:"cameraButtonHighlighted" ), forState: UIControlState.Highlighted)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
//        Helpers.inicializeImageView(type: false, view:self.cameraView, imageTypesSelected: self.imageType, x: nil, y: nil, width: nil, height: nil)
        
        
        self.libraryImages.addTarget(self, action: #selector(CameraVC.getLibraryImages(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.cameraBtn.addTarget(self, action: #selector(takePhoto), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.cancelBtn.addTarget(self, action: #selector(dismiss), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func setCameraAjusts(){
        cameraManager.showAccessPermissionPopupAutomatically = true
        
        let currentCameraState = cameraManager.currentCameraStatus()
        print(currentCameraState)
        if currentCameraState == .AccessDenied {

        } else if currentCameraState == .NoDeviceFound {
            
        } else if currentCameraState == .NotDetermined {

        } else if currentCameraState == .Ready {
            addCameraToView()
        }
        if !cameraManager.hasFlash {
            
            if Device().isPad {
                self.flashBtn.hidden = true
            }else{
                self.cameraToolbar.setItems([spaceBarBtn, helpImageBarBtn], animated: true)
            }
        }
    }
    
    private func addCameraToView(){
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.StillImage)
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    internal func rotate() {
        let rotation = currentRotation()
        let rads = CGFloat(radians(rotation))
        
        UIView.animateWithDuration(0.3) {
            self.cameraBtn.transform = CGAffineTransformMakeRotation(rads)
            self.libraryImages.transform = CGAffineTransformMakeRotation(rads)
            
            self.view.subviews.forEach ({
                if $0 is UIImageView {
                    $0.transform = CGAffineTransformMakeRotation(rads)
                }
            })
        }
    }
    
    internal func radians(degrees: Double) -> Double {
        return degrees / 180 * M_PI
    }
    
    internal func currentRotation() -> Double {
        var rotation: Double = 0
        
        if UIDevice.currentDevice().orientation == .LandscapeLeft {
            rotation = 90
        } else if UIDevice.currentDevice().orientation == .LandscapeRight {
            rotation = 270
        } else if UIDevice.currentDevice().orientation == .PortraitUpsideDown {
            rotation = 180
        }
        
        return rotation
    }
    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.Portrait
//    }
    
    func takePhoto() {
        switch (cameraManager.cameraOutputMode) {
        case .StillImage:
            cameraManager.capturePictureWithCompletition({ (image, error) -> Void in
                self.capturedImage = image
                print(image)
                self.performSegueWithIdentifier("VerifyImageSegue", sender: nil)
            })
        case .VideoWithMic, .VideoOnly:
            return
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
        self.capturedImage = image
        print(image)
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("VerifyImageSegue", sender: nil)
        }
    }
    
//    func inicializeCropViewController(image: UIImage){
//        cropViewController = TOCropViewController(image: image)
//        
//        cropViewController.delegate = self
//        cropViewController.defaultAspectRatio =  TOCropViewControllerAspectRatio.RatioSquare
//        cropViewController.toolbar.resetButton.hidden = true
//        cropViewController.toolbar.clampButton.hidden = true
//        cropViewController.cropView.cropBoxResizeEnabled = false
//        cropViewController.toolbar.rotateButton.addTarget(self, action: #selector(CameraVC.ajust), forControlEvents: UIControlEvents.TouchUpInside)
//        self.presentViewController(cropViewController, animated: true) { () -> Void in
//            self.ajust()
//        }
//
//
//        
//    }
//    
//    func ajust(){
//        Helpers.removeImageView(cropViewController.cropView)
//        TOCropViewControllerAspectRatio.RatioSquare
//        Helpers.inicializeImageView(type: true, view:cropViewController.cropView, imageTypesSelected: imageType, x: cropViewController.cropView.cropBoxFrame.origin.x, y: cropViewController.cropView.cropBoxFrame.origin.y, width: cropViewController.cropView.cropBoxFrame.size.width, height: cropViewController.cropView.cropBoxFrame.size.height)
//        
//    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "VerifyImageSegue" && self.capturedImage != nil{
            let controller = segue.destinationViewController as! VerifyImageVC
            
            controller.delegate = self
            controller.capturedImage = self.capturedImage
            controller.imageType = self.imageType
        }
        
    }
    
    
    func flashState() {
        switch (cameraManager.changeFlashMode()) {
        case .Off:
            if Device().isPad{
                self.flashBtn.setImage(UIImage(named: "flashOffIcon"), forState: UIControlState.Normal)
            }else{
                self.flashBarBtn.image = UIImage(named: "flashOffIcon")
            }
        case .On:
            if Device().isPad{
                self.flashBtn.setImage(UIImage(named: "flashOnIcon"), forState: UIControlState.Normal)
            }else{
                self.flashBarBtn.image = UIImage(named: "flashOnIcon")
            }
        case .Auto:
            if Device().isPad{
                self.flashBtn.setImage(UIImage(named: "flashAutoIcon"), forState: UIControlState.Normal)
            }else{
                self.flashBarBtn.image = UIImage(named: "flashAutoIcon")
            }
        }
    }
    
    func imagemGuiaState() {
        if helpImageState == .On {
            helpImageState = .Off
            if Device().isPad{
                self.helpImageBtn.setImage(UIImage(named: "modelOffIcon"), forState: UIControlState.Normal)
            }else{
                self.helpImageBarBtn = UIBarButtonItem(image: UIImage(named: "modelOffIcon"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(imagemGuiaState))
            }
            Helpers.removeImageView(cameraView)
        }else if helpImageState == .Off{
            helpImageState = .On

            if Device().isPad{
                self.helpImageBtn.setImage(UIImage(named: "modelOnIcon"), forState: UIControlState.Normal)
            }else{
                self.helpImageBarBtn = UIBarButtonItem(image: UIImage(named: "modelOnIcon"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(imagemGuiaState))
            }
            Helpers.inicializeImageView(type: false, view: self.cameraView, imageTypes: self.imageType)
        }
    }

}

extension CameraVC: ImageVerification{
    
    func imageVerification(image image: UIImage?, ImageVerify: ImageVerificationType) {
        switch ImageVerify {
        case .Retake:
            self.capturedImage = image
            return
        case .Ok:
            print("AQUI")
            self.delegate.updateData(image: image!, ImageType: self.imageType)
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
}

