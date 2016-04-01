//
//  ProcessarImagemVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 27/12/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit

class ProcessImageVC: UIViewController {

    // MARK: - Constants
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image:UIImage?
    
    var delegate : RecordPointsDelegate! = nil
    var imageType:ImageTypes = .Front
    let imageTypeProcess:[ImageTypes] = [.Front, .ProfileRight, .Nasal]
    var points: [String:NSValue]?
    var pointsUpdated: [String:NSValue]?
    let (frontPoints, profilePoints, nasalPoints) = Helpers.iniciar_dicionarios()

    
    static let infinity : CGFloat = 9999999.9
    
    var pointsViews : NSMutableArray = NSMutableArray()
    var pointChoosed : PontoView?
    var initialTouch : CGPoint = CGPointMake(0.0, 0.0)
    var pointInitialChoosed : CGPoint = CGPointMake(0.0, 0.0)
    var pointInitial:CGPoint?
    
    var voltarBtn:UIBarButtonItem = UIBarButtonItem()
    var spaceButton:UIBarButtonItem = UIBarButtonItem()
    var salvarBtn:UIBarButtonItem = UIBarButtonItem()
    
    // MARK: - @IBOutlets
    @IBOutlet weak var processToolbar: UIToolbar!
    
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPoints(){
        if self.points == nil {
            switch imageType {
            case .Front:        self.points = self.frontPoints
                                self.pointsUpdated = self.frontPoints
                
            case .ProfileRight: self.points = self.profilePoints
                                self.pointsUpdated = self.profilePoints
                
            case .Nasal:        self.points = self.nasalPoints
                                self.pointsUpdated = self.nasalPoints
                
            case .ObliqueLeft:  return
                
            case .ProfileLeft:  return
                
            case .ObliqueRight: return
                
            }
        }
        inserirPontos()

    }
    
    func setUI(){
        self.voltarBtn = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(ProcessImageVC.dismiss(_:)))
        self.spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        self.salvarBtn = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ProcessImageVC.salvarAlteracoes(_:)))
        
        
        self.voltarBtn.tintColor = UIColor.whiteColor()
        self.salvarBtn.tintColor = UIColor.blueColor()
        
        
        imageView = UIImageView(image: image)
        
        let height = view.frame.height
        let width = view.frame.width
        let x = view.frame.origin.x
        let y = view.frame.origin.y
        
        self.scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: width, height: height - self.processToolbar.frame.height) )
        self.scrollView.backgroundColor = UIColor.blackColor()
        self.scrollView.contentSize = imageView.bounds.size
        self.scrollView.addSubview(imageView)
        self.scrollView.delegate = self
        
        setZoomScale()
        
        
        if imageTypeProcess.contains(imageType) {
            setupGestureRecognizer()
            self.setPoints()
            processToolbar.setItems([voltarBtn, spaceButton,salvarBtn], animated: true)
        }else{
            processToolbar.setItems([voltarBtn, spaceButton], animated: true)

        }
        
        view.addSubview(scrollView!)
        view.addSubview(processToolbar)
    }
    
    
    func dismiss(button: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func salvarAlteracoes(button: UIBarButtonItem){
        if delegate != nil {
            delegate.updateData(points: self.pointsUpdated, ImageType: imageType)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}

extension ProcessImageVC: UIScrollViewDelegate{

    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView!.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        let imageViewSize = self.imageView!.bounds.size
        let scrollViewSize = self.scrollView!.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        self.scrollView!.minimumZoomScale = min(widthScale, heightScale)
        self.scrollView!.zoomScale = 1.0
    }
    
    
    // MARK: - Inserir Pontos
    func inserirPontos(){
        for (nome,local) in self.points!{
            if self.points! == self.frontPoints! || self.points! == self.profilePoints! || self.points! == self.nasalPoints! {
                let p = PontoView()
                let l = CGPoint(x: (self.imageView!.image?.size.width)!*(local.CGPointValue().x/1914), y: (self.imageView!.image?.size.height)!*(local.CGPointValue().y/1914))
                p.inicializar(nome , posicao: l)
                //Atualizando
                self.pointsUpdated?.updateValue(NSValue(CGPoint:l), forKey: nome)
                
                self.imageView!.layer.addSublayer(p.layer)
                self.pointsViews.addObject(p)
                
            }else {
                let p = PontoView()
                let l = local
                p.inicializar(nome , posicao: l.CGPointValue())
                
                self.imageView!.layer.addSublayer(p.layer)
                self.pointsViews.addObject(p)
            }
        }
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ProcessImageVC.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView!.addGestureRecognizer(doubleTap)
        
        let longPressRec = UILongPressGestureRecognizer(target: self, action: #selector(ProcessImageVC.gerenciarPontoTocado(_:)))
        self.imageView!.userInteractionEnabled = true
        self.imageView!.addGestureRecognizer(longPressRec)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (self.scrollView!.zoomScale > self.scrollView!.minimumZoomScale) {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.maximumZoomScale, animated: true)
        }
    }
    
    func gerenciarPontoTocado(recognizer:UILongPressGestureRecognizer){
        let toque = recognizer.locationInView(recognizer.view)
        if recognizer.state == UIGestureRecognizerState.Began{
            self.pointChoosed = LocalizarPontosViewController.menor_distancia_em_array(self.pointsViews, ponto: toque)
            initialTouch = toque
            pointInitialChoosed = (self.pointChoosed?.local)!
            self.pointChoosed?.ponto_view.image = UIImage(named: "ponto_vermelho")
            self.pointInitial = self.pointChoosed!.local
        }
        else if recognizer.state == UIGestureRecognizerState.Changed{
            let x = toque.x - initialTouch.x
            let y = toque.y - initialTouch.y
            self.pointChoosed?.frame = CGRectMake(x+pointInitialChoosed.x, y+pointInitialChoosed.y, (self.pointChoosed?.frame.width)!, (self.pointChoosed?.frame.height)!)
            
            self.pointChoosed?.local = (self.pointChoosed?.frame.origin)!
            self.pointChoosed?.ponto_view.image = UIImage(named: "ponto_vermelho")
        }
        else if recognizer.state == UIGestureRecognizerState.Ended{
            self.pointsUpdated?.updateValue(NSValue(CGPoint:(pointChoosed?.local)!), forKey:(pointChoosed?.nome)!)
            if pointInitial != self.pointChoosed!.local {
                self.pointChoosed?.ponto_view.image = UIImage(named: "ponto_verde")
            }else{
                self.pointChoosed?.ponto_view.image = UIImage(named: "ponto_azul")
            }
            
        }
    }
    
    static func distancia_entre_pontos(p1:CGPoint, p2:CGPoint) -> CGFloat{
        return pow((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y),0.5)
    }
    
    static func menor_distancia_em_array(array: NSMutableArray , ponto: CGPoint)->PontoView{
        var min = infinity
        var escolhido : PontoView?
        for obj in array{
            let p = obj as? PontoView
            
            let dist = distancia_entre_pontos((p?.local)!, p2: ponto)
            if dist < min {
                min = dist
                escolhido = p
            }
        }
        return escolhido!
    }


}
