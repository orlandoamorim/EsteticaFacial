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

enum imageTypes {
    case Frontal, Perfil, Nasal
}

enum contentTypes {
    case Adicionar, Atualizar, Nil
}

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
        switch contentToDisplay {
            case .Adicionar: performSegueWithIdentifier("SegueCamera", sender: nil)
            case .Atualizar: performSegueWithIdentifier("SegueShowImage", sender: nil)
            case .Nil : return
        }
    }
    @IBAction func btnPerfil(sender: AnyObject) {
        imageTypesSelected = .Perfil
        switch contentToDisplay {
            case .Adicionar: performSegueWithIdentifier("SegueCamera", sender: nil)
            case .Atualizar: performSegueWithIdentifier("SegueShowImage", sender: nil)
            case .Nil : return

        }
    }
    @IBAction func btnNasal(sender: AnyObject) {
        imageTypesSelected = .Nasal
        switch contentToDisplay {
            case .Adicionar: performSegueWithIdentifier("SegueCamera", sender: nil)
            case .Atualizar: performSegueWithIdentifier("SegueShowImage", sender: nil)
            case .Nil : return
        }
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
        switch imageTypesSelected {
            case .Frontal:  self.pontosFrontalAtual = dic
            case .Perfil:   self.pontosPerfilAtual = dic
            case .Nasal:    self.pontosNasalAtual = dic
        }
    }
    
    //CameraViewDelegate
    func marcar_pontos(dic: [String : NSValue]) {
        atribuir_marcacao(dic, imageTypesSelected: imageTypesSelected)
    }
    
    //--------------------
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

        if segue.identifier == "SegueCamera"{
            if let camera = segue.destinationViewController as? CameraViewController{
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
            if let localizar = segue.destinationViewController as? LocalizarPontosViewController{
                localizar.delegate = self

                switch imageTypesSelected {
                    case .Frontal:  localizar.imagem_cortada = self.btn_imagem_frontal.currentImage
                                    localizar.pontos_localizados = self.pontosFrontalAtual
                    
                    case .Perfil:   localizar.imagem_cortada = self.btn_imagem_perfil.currentImage
                                    localizar.pontos_localizados = self.pontosPerfilAtual

                    case .Nasal:    localizar.imagem_cortada = self.btn_imagem_nasal.currentImage
                                    localizar.pontos_localizados = self.pontosNasalAtual
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

