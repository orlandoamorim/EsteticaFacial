//
//  LocalizarPontosViewController.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 19/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class LocalizarPontosViewController: UIViewController,UIScrollViewDelegate {
    
    static let infinity : CGFloat = 9999999.9
    
    var delegate : CameraViewDelegate! = nil
    
    var pontos_views : NSMutableArray = NSMutableArray()
    var ponto_escolhido : PontoView?
    var toque_inicial : CGPoint = CGPointMake(0.0, 0.0)
    var ponto_escolhido_inicial : CGPoint = CGPointMake(0.0, 0.0)
    
    @IBOutlet weak var reconhecedor: UIGestureRecognizer!
    var imagem_view: UIImageView?
    var pontos_localizados : [String:CGPoint]?
    var imagem_cortada : UIImage?

    @IBOutlet weak var container_imagem: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container_imagem.translatesAutoresizingMaskIntoConstraints = false
        self.iniciar_views()
       // self.scrollViewDidZoom(self.container_imagem)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("CONTAINER ZOOM SCALE: \(container_imagem.minimumZoomScale) | CONTAINER FRAME = \(self.container_imagem.frame)");
        container_imagem.minimumZoomScale = self.container_imagem.contentSize.height/self.container_imagem.frame.size.height > self.container_imagem.contentSize.width/self.container_imagem.frame.size.width ? self.container_imagem.frame.size.height/self.container_imagem.contentSize.height : self.container_imagem.frame.size.width/self.container_imagem.contentSize.width
        container_imagem.zoomScale = container_imagem.minimumZoomScale
      //  self.conteudo_view.frame = CGRectMake(0, 0, (self.imagem_cortada?.size.width)!, (self.imagem_cortada?.size.height)!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func iniciar_views(){
        
        self.container_imagem.contentSize = (self.imagem_cortada?.size)!
        
        self.imagem_view = UIImageView()
        self.imagem_view?.userInteractionEnabled = true
        self.imagem_view?.addGestureRecognizer(reconhecedor)
        self.imagem_view!.frame = CGRectMake(0, 0, (self.imagem_cortada?.size.width)!, (self.imagem_cortada?.size.height)!)
        self.imagem_view!.image = imagem_cortada
        
        
        self.container_imagem.addSubview(self.imagem_view!)
        self.inserir_pontos()
      
        container_imagem.minimumZoomScale = self.container_imagem.contentSize.height/self.container_imagem.frame.size.height > self.container_imagem.contentSize.width/self.container_imagem.frame.size.width ? self.container_imagem.frame.size.height/self.container_imagem.contentSize.height : self.container_imagem.frame.size.width/self.container_imagem.contentSize.width
        container_imagem.maximumZoomScale = 2.0
        container_imagem.zoomScale = container_imagem.minimumZoomScale
        
        
    }
    
    func inserir_pontos(){
        for (nome,local) in self.pontos_localizados!{
            let p = PontoView()
            let l = local
            p.inicializar(nome , posicao: l)
            
            self.imagem_view!.layer.addSublayer(p.layer)
            self.pontos_views.addObject(p)
        }
    }

    @IBAction func confirmar_pontos(sender: UIBarButtonItem) {
        delegate.marcar_pontos(pontos_localizados!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func confirmar(sender: AnyObject) {
        delegate.marcar_pontos(pontos_localizados!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func gerenciar_longo_toque(recognizer:UILongPressGestureRecognizer){
        let toque = recognizer.locationInView(recognizer.view)
        
        if recognizer.state == UIGestureRecognizerState.Began{
            self.ponto_escolhido = LocalizarPontosViewController.menor_distancia_em_array(self.pontos_views, ponto: toque)
            toque_inicial = toque
            ponto_escolhido_inicial = (self.ponto_escolhido?.local)!
            print("\(self.ponto_escolhido?.local)")
        }
        else if recognizer.state == UIGestureRecognizerState.Changed{
            let x = toque.x - toque_inicial.x
            let y = toque.y - toque_inicial.y
            self.ponto_escolhido?.frame = CGRectMake(x+ponto_escolhido_inicial.x, y+ponto_escolhido_inicial.y, (self.ponto_escolhido?.frame.width)!, (self.ponto_escolhido?.frame.height)!)
            self.ponto_escolhido?.local = (self.ponto_escolhido?.frame.origin)!
        }
        else if recognizer.state == UIGestureRecognizerState.Ended{
            pontos_localizados?.updateValue((ponto_escolhido?.local)!, forKey:(ponto_escolhido?.nome)!)
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imagem_view
    }
}
