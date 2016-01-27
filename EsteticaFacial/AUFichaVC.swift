//
//  AUFichaVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 09/11/15.
//  Copyright © 2015 UFPI. All rights reserved.
//

import UIKit
import Parse
import Eureka
import SwiftyDrop

class AUFichaVC: FormViewController, NovoPacienteDelegate,ProcedimentoCirurgico, CameraViewDelegate {
    
    var parseObject:PFObject!
    var alertView:SCLAlertViewResponder?
    
    @IBOutlet weak var header: UIView!
    //Camera BTN
    @IBOutlet weak var btn_imagem_frontal: UIButton!
    @IBOutlet weak var btn_imagem_perfil: UIButton!
    @IBOutlet weak var btn_imagem_nasal: UIButton!
    
    var imagemFrontalServidor:UIImage = UIImage()
    var imagemPerfilServidor:UIImage = UIImage()
    var imagemNasalServidor:UIImage = UIImage()
    
    
    var pontosFrontalServidor : [String:NSValue]?
    var pontosPerfilServidor : [String:NSValue]?
    var pontosNasalServidor : [String:NSValue]?
    
    //Verificadores para saber se os pontos foram atualizados pelo usuario
    var pontosFrontalAtual : [String:NSValue]?
    var pontosPerfilAtual : [String:NSValue]?
    var pontosNasalAtual : [String:NSValue]?
    
    var formValuesServidor:[String : Any?] = [String : Any?]()
    
    //Procedimentos Cirurgicos
    var dicFormValuesServidor:[String : Any?] = [String : Any?]()
    var dicFormValuesAtual:[String : Any?] = [String : Any?]()
    
    var imageTypesSelected:imageTypes = .Frontal
    var contentToDisplay:contentTypes = .Nil
    
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        let iniciar_dicionarios = Helpers.iniciar_dicionarios()
        
        pontosFrontalServidor = iniciar_dicionarios.pontos_frontal
        pontosFrontalAtual = iniciar_dicionarios.pontos_frontal
        pontosPerfilServidor = iniciar_dicionarios.pontos_perfil
        pontosPerfilAtual = iniciar_dicionarios.pontos_perfil
        pontosNasalServidor = iniciar_dicionarios.pontos_nasal
        pontosNasalAtual = iniciar_dicionarios.pontos_nasal
        dicFormValuesServidor = iniciar_dicionarios.dicFormValues
        dicFormValuesAtual = iniciar_dicionarios.dicFormValues
        
        self.imagemFrontalServidor = UIImage(named: "modelo_frontal")!
        self.imagemPerfilServidor = UIImage(named: "modelo_perfil")!
        self.imagemNasalServidor = UIImage(named: "modelo_nasal")!
        
        
        let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        centroDeNotificacao.addObserver(self, selector: "noData", name: "noData", object: nil)
        
        switch contentToDisplay {
        case .Adicionar:
            self.title = "Add Ficha"
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed:")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Plain, target: self, action: "getFormValues")
            
        case .Atualizar:
            ParseConnection.getFichaFromServer(parseObject, resultBlockForm: { (formValues) -> Void in
                self.formValuesServidor = formValues
                }, resultBlockDic: { (dicFormValues) -> Void in
                    self.dicFormValuesServidor = dicFormValues
                    self.dicFormValuesAtual = dicFormValues
                }, progressBlockDic: { (progress) -> Void in
                    
            })
            form.setValues(self.formValuesServidor)
            
            self.tableView?.reloadData()
            
            
            ParseConnection.getFromParseImgFrontal(parseObject
                , resultBlockImage: { (data, error) -> Void in
                    if error == nil {
                        self.btn_imagem_frontal.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                        self.imagemFrontalServidor = UIImage(data: data!)!
                    }else{
                        Drop.down("Erro ao baixar imagem frontal. Objeto nao encontrado.", state: .Error)
                    }
                }, progressBlockImage: { (progress) -> Void in
                    if progress == 100.0{
                        self.btn_imagem_frontal.enabled = true
                    }else{
                        self.btn_imagem_frontal.enabled = false
                    }
                    
                    print("Baixando |Imgem Frontal| -> \(progress!)")
                }, resultBlockPontos: { (pontos, error) -> Void in
                    if error == nil {
                        self.pontosFrontalServidor = pontos
                        self.pontosFrontalAtual = pontos
                    }else{
                        Drop.down("Erro ao baixar pontos frontal. Objeto nao encontrado.", state: .Error)
                    }
                    
                }, progressBlockPontos: { (progress) -> Void in
                    print("Baixando |Pontos Frontal| -> \(progress!)")
            })
            
            
            ParseConnection.getFromParseImgPerfil(parseObject
                , resultBlockImage: { (data, error) -> Void in
                    if error == nil {
                        self.btn_imagem_perfil.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                        self.imagemPerfilServidor = UIImage(data: data!)!
                    }else{
                        Drop.down("Erro ao baixar imagem perfil. Objeto nao encontrado.", state: .Error)
                    }
                }, progressBlockImage: { (progress) -> Void in
                    if progress == 100.0{
                        self.btn_imagem_perfil.enabled = true
                    }else{
                        self.btn_imagem_perfil.enabled = false
                    }
                    print("Baixando |Imgem Perfil| -> \(progress!)")
                }, resultBlockPontos: { (pontos, error) -> Void in
                    if error == nil {
                        self.pontosPerfilServidor = pontos
                        self.pontosPerfilAtual = pontos
                    }else{
                        Drop.down("Erro ao baixar pontos perfil. Objeto nao encontrado.", state: .Error)
                    }
                    
                }, progressBlockPontos: { (progress) -> Void in
                    print("Baixando |Pontos Perfil| -> \(progress!)")
            })
            
            ParseConnection.getFromParseImgNasal(parseObject
                , resultBlockImage: { (data, error) -> Void in
                    if error == nil {
                        self.btn_imagem_nasal.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                        self.imagemNasalServidor = UIImage(data: data!)!
                    }else{
                        Drop.down("Erro ao baixar imagem nasal. Objeto nao encontrado.", state: .Error)
                    }
                }, progressBlockImage: { (progress) -> Void in
                    if progress == 100.0{
                        self.btn_imagem_nasal.enabled = true
                    }else{
                        self.btn_imagem_nasal.enabled = false
                    }
                    print("Baixando |Imgem Nasal| -> \(progress!)")
                }, resultBlockPontos: { (pontos, error) -> Void in
                    if error == nil {
                        self.pontosNasalServidor = pontos
                        self.pontosNasalAtual = pontos
                    }else{
                        Drop.down("Erro ao baixar pontos nasal. Objeto nao encontrado.", state: .Error)
                    }
                    
                }, progressBlockPontos: { (progress) -> Void in
                    print("Baixando |Pontos Nasal| -> \(progress!)")
            })
            
            
            self.title = "Atualizar Ficha"
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.Plain, target: self, action: "getFormValues")
        case .Nil : noData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //--------------------
    
    func getFormValues(){
        alertView = SCLAlertView().showWait("Carregando", subTitle: "Aguarde...", closeButtonTitle: "Cancelar", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
        let results = Helpers.verifyFormValues(form.values(includeHidden: false))
        
        if !results.0 {
            alertView?.close()
            alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio \(results.1) nao foi preenchido", closeButtonTitle: "OK")
            return
        }
        
        switch contentToDisplay {
        case .Adicionar:
            
            ParseConnection.adicionarFicha(form.values(includeHidden: false)
                , dicFormValues: self.dicFormValuesAtual
                , imagemPerfil: self.btn_imagem_perfil.currentImage
                , imagemFrontal: self.btn_imagem_frontal.currentImage
                , imagemNasal: self.btn_imagem_nasal.currentImage
                , pontosFrontalAtual: self.pontosFrontalAtual
                , pontosPerfilAtual: self.pontosPerfilAtual
                , pontosNasalAtual: self.pontosNasalAtual
                , completion: { (sucesso, erro) -> Void in
                    
                    if erro == nil {
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.alertView?.close()
                            self.alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Dados salvos com sucesso.", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
                        })
                    }else {
                        self.alertView?.close()
                        self.alertView? = SCLAlertView().showError("UFPI", subTitle: "Algum erro ocorreu ao salvar a ficha. Tente novamente em poucos instantes.", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
                    }
                    
            })
            return
        case .Atualizar:
            ParseConnection.atualizarFicha(parseObject
                , formValuesServidor: self.formValuesServidor, formValuesAtual: form.values(includeHidden: false)
                , dicFormValuesServidor: self.dicFormValuesServidor, dicFormValuesAtual: self.dicFormValuesAtual
                , imagemFrontalServidor: self.imagemFrontalServidor, imagemFrontalAtual: self.btn_imagem_frontal.currentImage
                , imagemPerfilServidor: self.imagemPerfilServidor, imagemPerfilAtual: self.btn_imagem_perfil.currentImage
                , imagemNasalServidor: self.imagemNasalServidor, imagemNasalAtual: self.btn_imagem_nasal.currentImage
                , pontosFrontalServidor: self.pontosFrontalServidor, pontosFrontalAtual: self.pontosFrontalAtual
                , pontosPerfilServidor: self.pontosPerfilServidor, pontosPerfilAtual: self.pontosPerfilAtual
                , pontosNasalServidor: self.pontosNasalServidor, pontosNasalAtual: self.pontosNasalAtual
                , completion: { (success, error) -> Void in
                    
                    if error == nil {
                        self.alertView?.close()
                        self.alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Dados Atualizados com sucesso.", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
                    }else {
                        self.alertView?.close()
                        self.alertView? = SCLAlertView().showError("UFPI", subTitle: "Algum erro ocorreu ao atualizar a ficha. Tente novamente em poucos instantes.", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
                    }
                    
            })
            
            return
            
        case .Nil : return
        }
    }
    
    //--------------------
    
    private func initializeForm() {
        
        DateInlineRow.defaultRowInitializer = { row in row.maximumDate = NSDate() }
        
        form +++
            
            Section("Dados do Paciente")
            
            <<< NameRow("nome") {
                $0.title = "Nome:"
            }
            
            <<< PickerInlineRow<String>("sexo") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Sexo:"
                row.options = ["Masculino", "Feminino"]
                row.value = row.options[0]
            }
            
            <<< PickerInlineRow<String>("etnia") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Etnia:"
                row.options = ["Caucasiano","Negróide","Asiático"]
                row.value = row.options[0]
            }
            
            <<< DateInlineRow("data_nascimento") {
                $0.title = "Data de Nascimento:"
                $0.value = NSDate()
                let formatter = NSDateFormatter()
                formatter.locale = .currentLocale()
                formatter.dateStyle = .ShortStyle
                $0.dateFormatter = formatter
            }
            
            <<< EmailRow("email") {
                $0.title = "E-mail:"
            }
            
            <<< PhoneRow("telefone") {
                $0.title = "Telefone:"
            }
            
            +++ Section("Dados da Cirurgia")
            
            <<< ButtonRow("btn_plano_cirurgico") { (row: ButtonRow) -> Void in
                row.title = "Plano Cirurgico"
                row.presentationMode = .SegueName(segueName: "ProcedimentosCirurgicosSegue", completionCallback: nil)
            }
            
            <<< SwitchRow("cirurgia_realizada") {
                $0.title = "Cirurgia Realizada?"
                $0.value = false
                
                }.onChange { [weak self] in
                    if $0.value == true {
                        self?.form.rowByTag("btn_cirurgia_realizada")?.hidden = false
                        self?.form.rowByTag("btn_cirurgia_realizada")?.updateCell()
                    }else if $0.value == false {
                        self?.form.rowByTag("btn_cirurgia_realizada")?.hidden = true
                        self?.form.rowByTag("btn_cirurgia_realizada")?.updateCell()
                    }
            }
            
            <<< ButtonRow("btn_cirurgia_realizada") { (row: ButtonRow) -> Void in
                row.title = "Dados da Cirurgia"
                row.hidden = "$cirurgia_realizada == false"
                
                row.presentationMode = .SegueName(segueName: "ProcedimentosCirurgicosSegue", completionCallback: nil)
            }
            
            +++ Section("Notas")
            
            <<< TextAreaRow("notas") { $0.placeholder = "Este paciente..." }
    }
    
    //--------------------
    
    
    // MARK: - Tela Sem Dados
    
    func noData(){
        let messageLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        messageLabel.text = "Clique em uma ficha para carregar os dados. "
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 5
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        messageLabel.sizeToFit()
        
        self.tableView!.backgroundView = messageLabel
        self.tableView!.backgroundView?.hidden = false
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.header.hidden = true
        
        self.form.removeAll()
        
        self.navigationItem.rightBarButtonItem = nil
        
        self.tableView!.reloadData()
        self.title = "@UFPI"
        
    }
    
    //--------------------
    @IBAction func btnFrontal(sender: AnyObject) {
        imageTypesSelected = .Frontal
        let bonus = (sender is UITapGestureRecognizer ? true : false)
        if !bonus {
            if sender.state == UIGestureRecognizerState.Began{
                if btn_imagem_frontal.currentImage != nil {
                    showOptions(btn_imagem_frontal)
                }else{
                    performSegueWithIdentifier("SegueCamera", sender: nil)
                }
            }
        }else {
            if btn_imagem_frontal.currentImage != nil {
                performSegueWithIdentifier("SegueShowImage", sender: nil)
            }else{
                performSegueWithIdentifier("SegueCamera", sender: nil)
            }
        }
    }
    @IBAction func btnPerfil(sender: AnyObject) {
        imageTypesSelected = .Perfil
        let bonus = (sender is UITapGestureRecognizer ? true : false)
        if !bonus {
            if sender.state == UIGestureRecognizerState.Began{
                if btn_imagem_perfil.currentImage != nil {
                    showOptions(btn_imagem_perfil)
                }else{
                    performSegueWithIdentifier("SegueCamera", sender: nil)
                }
            }
        }else {
            if btn_imagem_perfil.currentImage != nil {
                performSegueWithIdentifier("SegueShowImage", sender: nil)
            }else{
                performSegueWithIdentifier("SegueCamera", sender: nil)
            }
        }
    }
    @IBAction func btnNasal(sender: AnyObject) {
        imageTypesSelected = .Nasal
        let bonus = (sender is UITapGestureRecognizer ? true : false)
        if !bonus {
            if sender.state == UIGestureRecognizerState.Began{
                if btn_imagem_nasal.currentImage != nil {
                    showOptions(btn_imagem_nasal)
                }else{
                    performSegueWithIdentifier("SegueCamera", sender: nil)
                }
            }
        }else {
            if btn_imagem_nasal.currentImage != nil {
                performSegueWithIdentifier("SegueShowImage", sender: nil)
            }else{
                performSegueWithIdentifier("SegueCamera", sender: nil)
            }
        }
    }
    
    func showOptions(button: UIButton!){
        let alertController = UIAlertController(title: "Analise Facial", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let visualizarImagem = UIAlertAction(title: "Visualizar", style: UIAlertActionStyle.Default) { (visualizar) -> Void in
            self.performSegueWithIdentifier("SegueShowImage", sender: nil)
        }
        
        let novaImagem = UIAlertAction(title: "Nova Imagem", style: UIAlertActionStyle.Default) { (novaImagem) -> Void in
            self.performSegueWithIdentifier("SegueCamera", sender: nil)
        }
        
        let apagarImagem = UIAlertAction(title: "Apagar Imagem", style: UIAlertActionStyle.Destructive) { (apagar) -> Void in
            Drop.down("Apagando Imagem", state: .Info)
            
            switch self.contentToDisplay {
            case .Adicionar:
                switch self.imageTypesSelected {
                case .Frontal: self.btn_imagem_frontal.setImage(nil, forState: UIControlState.Normal)
                case .Perfil: self.btn_imagem_perfil.setImage(nil, forState: UIControlState.Normal)
                case .Nasal: self.btn_imagem_nasal.setImage(nil, forState: UIControlState.Normal)
                }
            case .Atualizar:
                switch self.imageTypesSelected {
                case .Frontal:
                    print("OLA")
                    if ParseConnection.getFromParseImgFrontal(self.parseObject) {
                        self.parseObject.removeObjectForKey("img_frontal")
                        self.parseObject.removeObjectForKey("thumb_frontal")
                        self.parseObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                Drop.down("Imagem deletada com Sucesso.", state: .Success)
                                self.btn_imagem_frontal.setImage(nil, forState: UIControlState.Normal)
                            }else{
                                Drop.down("Erro ao deletar. Tente novamente mais tarde.", state: .Error)
                            }
                        })
                        self.btn_imagem_frontal.setImage(nil, forState: UIControlState.Normal)
                    }
                case .Perfil:
                    if ParseConnection.getFromParseImgPerfil(self.parseObject) {
                        self.parseObject.removeObjectForKey("img_perfil")
                        self.parseObject.removeObjectForKey("thumb_perfil")
                        self.parseObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                Drop.down("Imagem deletada com Sucesso.", state: .Success)
                                self.btn_imagem_perfil.setImage(nil, forState: UIControlState.Normal)
                            }else{
                                Drop.down("Erro ao deletar. Tente novamente mais tarde.", state: .Error)
                            }
                        })
                    }else{
                        self.btn_imagem_perfil.setImage(nil, forState: UIControlState.Normal)
                    }
                case .Nasal:
                    if ParseConnection.getFromParseImgNasal(self.parseObject) {
                        self.parseObject.removeObjectForKey("img_nasal")
                        self.parseObject.removeObjectForKey("thumb_nasal")
                        self.parseObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                Drop.down("Imagem deletada com Sucesso.", state: .Success)
                                self.btn_imagem_nasal.setImage(nil, forState: UIControlState.Normal)
                            }else{
                                Drop.down("Erro ao deletar. Tente novamente mais tarde.", state: .Error)
                            }
                        })
                    }else{
                        self.btn_imagem_nasal.setImage(nil, forState: UIControlState.Normal)
                    }
                }
                self.view.setNeedsDisplay()
            case .Nil : return
            }
            
        }
        
        alertController.addAction(visualizarImagem)
        alertController.addAction(novaImagem)
        alertController.addAction(apagarImagem)
        
        alertController.popoverPresentationController?.sourceView = button
        alertController.popoverPresentationController?.sourceRect = button.bounds
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Pressionou o btn Cancelar
    
    func cancelPressed(button: UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //--------------------
    
    
    // MARK: - Protocols
    
    //Dicionarios
    func alterarDic(dicFormValuesAtual: [String : Any?]) {
        self.dicFormValuesAtual = dicFormValuesAtual
    }
    
    //NovoPacienteDelegate
    func atribuir_imagem(imagem: UIImage, imageTypesSelected:imageTypes) {
        switch imageTypesSelected {
        case .Frontal:  btn_imagem_frontal.setImage(imagem, forState: UIControlState.Normal)
        case .Perfil:   btn_imagem_perfil.setImage(imagem, forState: UIControlState.Normal)
        case .Nasal:    btn_imagem_nasal.setImage(imagem, forState: UIControlState.Normal)
        }
        
    }
    //NovoPacienteDelegate
    func atribuir_marcacao(dic: [String : NSValue], imageTypesSelected:imageTypes) {
        print(imageTypesSelected)
        print(dic)
        switch imageTypesSelected {
        case .Frontal:  self.pontosFrontalAtual = dic
        case .Perfil:   self.pontosPerfilAtual = dic
        case .Nasal:    self.pontosNasalAtual = dic
        }
        print("****")
        print(self.pontosFrontalAtual)
    }
    
    //CameraViewDelegate
    func marcar_pontos(dic: [String : NSValue]) {
        atribuir_marcacao(dic, imageTypesSelected: imageTypesSelected)
    }
    
    //--------------------
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "SegueCamera"{
            if let camera = segue.destinationViewController as? CameraVC{
                camera.delegate = self
                
                switch imageTypesSelected {
                case .Frontal:  camera.imageTypesSelected = .Frontal
                camera.dicionario = self.pontosFrontalAtual
                    
                case .Perfil:   camera.imageTypesSelected = .Perfil
                camera.dicionario = self.pontosPerfilAtual
                    
                case .Nasal:    camera.imageTypesSelected = .Nasal
                camera.dicionario = self.pontosNasalAtual
                }
            }
        }
        
        
        if segue.identifier == "SegueShowImage"{
            if let processarImagemVC = segue.destinationViewController as? ProcessarImagemVC{
                processarImagemVC.delegate = self
                processarImagemVC.imageTypesSelected = self.imageTypesSelected
                processarImagemVC.imageGetFrom = .Servidor
                
                switch imageTypesSelected {
                case .Frontal:  processarImagemVC.image = self.btn_imagem_frontal.currentImage!
                processarImagemVC.dicionario = self.pontosFrontalAtual
                    
                case .Perfil:   processarImagemVC.image = self.btn_imagem_perfil.currentImage!
                processarImagemVC.dicionario = self.pontosPerfilAtual
                    
                case .Nasal:    processarImagemVC.image = self.btn_imagem_nasal.currentImage!
                processarImagemVC.dicionario = self.pontosNasalAtual
                }
            }
        }
        
        if segue.identifier == "ProcedimentosCirurgicosSegue"{
            let controller = segue.destinationViewController as! ProcedimentosCirurgicosVC
            
            controller.delegate = self
            controller.dicFormValues = self.dicFormValuesAtual
        }
    }
}

