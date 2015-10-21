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
    @IBOutlet weak var view_conteudo: UIView!
    var imagem_view: UIImageView?
    var pontos_localizados : [String:CGPoint]?
    var imagem_cortada : UIImage?

    @IBOutlet weak var container_imagem: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.iniciar_views()
       // self.scrollViewDidZoom(self.container_imagem)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        self.view_conteudo.frame = CGRectMake(0, 0, (imagem_cortada?.size)!.width, (imagem_cortada?.size)!.height)
        self.container_imagem.contentSize = CGSizeMake(self.view_conteudo.frame.width, self.view_conteudo.frame.height)
        
        self.imagem_view = UIImageView()
        self.imagem_view?.userInteractionEnabled = true
        //self.imagem_view?.alpha = 0.4
        self.imagem_view?.addGestureRecognizer(reconhecedor)
        self.imagem_view!.frame = self.view_conteudo.frame
        self.imagem_view!.image = imagem_cortada
        
        
        self.container_imagem.addSubview(self.imagem_view!)
        self.inserir_pontos()
        
        
        print("TAMANHO DO VIEW CONTEUDO \(self.view_conteudo.frame)")
      
        
        container_imagem.minimumZoomScale = 0.2
        container_imagem.maximumZoomScale = 2.0
        container_imagem.zoomScale = (imagem_cortada?.size)!.width/container_imagem.frame.width
        
        
        print("TAMANHO DO SCROLL \(self.container_imagem)")
    }
    
    func inserir_pontos(){
        for (nome,local) in self.pontos_localizados!{
            print("Nome do ponto: \(nome) | Local: \(local)")
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
        print("REGIAO DO TOQUE: \(toque)");
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
//            toque_inicial = CGPointMake(0.0, 0.0)
//            self.ponto_escolhido_inicial = CGPointMake(0.0, 0.0)
//            self.ponto_escolhido = nil
            print("\(self.ponto_escolhido?.local)| VIEW CONTEUDO \(self.view_conteudo.frame)")
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
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
//        var zoom_view = self.imagem_view
//        var zvf = zoom_view?.frame
//        if(zvf!.size.width < scrollView.bounds.size.width)
//        {
//            zvf = CGRectMake((scrollView.bounds.size.width - zvf!.size.width) / 2.0, (zvf?.origin.y)!, (zvf?.size.width)!, (zvf?.size.height)!)
//        }
//        else
//        {
//            zvf = CGRectMake(0.0, (zvf?.origin.y)!, (zvf?.size.width)!, (zvf?.size.height)!)
//        }
//        if(zvf!.size.height < scrollView.bounds.size.height)
//        {
//            zvf = CGRectMake((zvf?.origin.x)!, (scrollView.bounds.size.height - zvf!.size.height) / 2.0, (zvf?.size.width)!, (zvf?.size.height)!)
//        }
//        else
//        {
//            zvf = CGRectMake((zvf?.origin.x)!, 0.0, (zvf?.size.width)!, (zvf?.size.height)!)
//        }
//        print("\(zvf)")
//        zoom_view!.frame = zvf!
//        print("\(zoom_view?.frame)")
        // NSLog(@"ZOOM %f %f %f",_scroll_imagem.minimumZoomScale,_scroll_imagem.maximumZoomScale,_scroll_imagem.zoomScale);
       // NSLog(@"VALORES %f %f",zoomView.frame.size.width,zoomView.frame.size.height);
    }
}
