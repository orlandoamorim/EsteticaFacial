//
//  ProcessarImagemVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 27/12/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class ProcessarImagemVC: UIViewController,UIScrollViewDelegate {


    @IBOutlet weak var processarToolbar: UIToolbar!
    
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image:UIImage!
    
    var delegate : NovoPacienteDelegate! = nil
    var ponto_escolhido : PontoView?
    
    var imageTypesSelected:imageTypes = .Frontal
    var imageGetFrom:imageGet = .Camera
    
    var dicionario: [String:NSValue]?
    var pontosFrontalFrom:pontosFrontalType = .Nil
    var pontosPerfilFrom:pontosPerfilType = .Nil
    var pontosNasalFrom:pontosNasalType = .Nil

    var testeBo:Bool = Bool()
    
    static let infinity : CGFloat = 9999999.9
    var pontos_views : NSMutableArray = NSMutableArray()
    var toque_inicial : CGPoint = CGPointMake(0.0, 0.0)
    var ponto_escolhido_inicial : CGPoint = CGPointMake(0.0, 0.0)
    var pontoInicial:CGPoint?
    
    var reloadBtn:UIBarButtonItem = UIBarButtonItem()
    var voltarBtn:UIBarButtonItem = UIBarButtonItem()
    var spaceButton:UIBarButtonItem = UIBarButtonItem()
    var salvarBtn:UIBarButtonItem = UIBarButtonItem()


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testeBo = false
        
        self.voltarBtn = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: "dismiss:")
        self.reloadBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: nil, action: "novaFoto:")
        self.spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        self.salvarBtn = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Done, target: self, action: "salvarAlteracoes:")
        
        
        self.reloadBtn.tintColor = UIColor.whiteColor()
        self.voltarBtn.tintColor = UIColor.whiteColor()

        self.salvarBtn.tintColor = UIColor.blueColor()

        processarToolbar.setItems([voltarBtn, spaceButton,reloadBtn, spaceButton,salvarBtn], animated: true)
        
        //-- TESTE
        imageView = UIImageView(image: image)
        
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        
        setZoomScale()
        
        setupGestureRecognizer()
        inserirPontos()
        view.addSubview(scrollView)
        view.addSubview(processarToolbar)

    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let longPressRec = UILongPressGestureRecognizer(target: self, action: "gerenciarPontoTocado:")
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(longPressRec)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
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
    
    // MARK: - Inserir Pontos
    func inserirPontos(){
        for (nome,local) in self.dicionario!{
            if pontosFrontalFrom == .Local || pontosPerfilFrom == .Local || pontosNasalFrom == .Local {
                let p = PontoView()
                let l = CGPoint(x: (self.imageView.image?.size.width)!*(local.CGPointValue().x/1914), y: (self.imageView.image?.size.height)!*(local.CGPointValue().y/1914))
                p.inicializar(nome , posicao: l)
                //Atualizando
                dicionario?.updateValue(NSValue(CGPoint:l), forKey: nome)
                self.testeBo = true
                
                self.imageView.layer.addSublayer(p.layer)
                self.pontos_views.addObject(p)
                
            }else if pontosFrontalFrom == .Servidor || pontosPerfilFrom == .Servidor || pontosNasalFrom == .Servidor || pontosFrontalFrom == .Atualizado || pontosPerfilFrom == .Atualizado || pontosNasalFrom == .Atualizado {
                let p = PontoView()
                let l = local
                
                p.inicializar(nome , posicao: l.CGPointValue())
                
                self.imageView.layer.addSublayer(p.layer)
                self.pontos_views.addObject(p)
            }
        }
        
        if self.testeBo == true {
            switch imageTypesSelected {
            case .Frontal: pontosFrontalFrom = .Servidor
            case .Perfil: pontosPerfilFrom = .Servidor
            case .Nasal: pontosNasalFrom = .Servidor
            }
        }
    }
    
    func gerenciarPontoTocado(recognizer:UILongPressGestureRecognizer){
        let toque = recognizer.locationInView(recognizer.view)
        print("TOQUE")
        if recognizer.state == UIGestureRecognizerState.Began{
            self.ponto_escolhido = LocalizarPontosViewController.menor_distancia_em_array(self.pontos_views, ponto: toque)
            toque_inicial = toque
            ponto_escolhido_inicial = (self.ponto_escolhido?.local)!
            self.ponto_escolhido?.ponto_view.image = UIImage(named: "ponto_vermelho")
            print("\(self.ponto_escolhido?.local)")
            self.pontoInicial = self.ponto_escolhido!.local
        }
        else if recognizer.state == UIGestureRecognizerState.Changed{
            let x = toque.x - toque_inicial.x
            let y = toque.y - toque_inicial.y
            self.ponto_escolhido?.frame = CGRectMake(x+ponto_escolhido_inicial.x, y+ponto_escolhido_inicial.y, (self.ponto_escolhido?.frame.width)!, (self.ponto_escolhido?.frame.height)!)
            print("\(self.ponto_escolhido?.local)")

            self.ponto_escolhido?.local = (self.ponto_escolhido?.frame.origin)!
            self.ponto_escolhido?.ponto_view.image = UIImage(named: "ponto_vermelho")
        }
        else if recognizer.state == UIGestureRecognizerState.Ended{
            dicionario?.updateValue(NSValue(CGPoint:(ponto_escolhido?.local)!), forKey:(ponto_escolhido?.nome)!)
            print("\(self.ponto_escolhido?.local)")
            
            switch imageTypesSelected {
            case .Frontal: pontosFrontalFrom = .Atualizado
            case .Perfil: pontosPerfilFrom = .Atualizado
            case .Nasal: pontosNasalFrom = .Atualizado
            }
            
            if pontoInicial != self.ponto_escolhido!.local {
                self.ponto_escolhido?.ponto_view.image = UIImage(named: "ponto_verde")
            }else{
                self.ponto_escolhido?.ponto_view.image = UIImage(named: "ponto_azul")
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
    
    func dismiss(button: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func novaFoto(button: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func salvarAlteracoes(button: UIBarButtonItem){
        if delegate != nil {
            delegate.atribuir_imagem(image, imageTypesSelected: imageTypesSelected)
//            delegate.atribuir_marcacao(dicionario! , imageTypesSelected: imageTypesSelected)
            delegate.atribuir_marcacao(dicionario!, imageTypesSelected: imageTypesSelected, pontosFrontalFrom: pontosFrontalFrom, pontosPerfilFrom: pontosPerfilFrom, pontosNasalFrom: pontosNasalFrom)
            if self.imageGetFrom == .Camera || self.imageGetFrom == .Biblioteca  {
                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }else if self.imageGetFrom == .Servidor  {
                self.dismissViewControllerAnimated(true, completion: nil)

            }
            

        }
//        self.presentingViewController?.presentingViewController?.popoverPresentationController
    }

}
