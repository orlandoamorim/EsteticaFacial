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

protocol NovoPacienteDelegate{
    func atribuir_imagem(imagem: UIImage, flag:Int)
    func atribuir_marcacao(dic:[String:NSValue], flag:Int)
}

protocol ProcedimentoCirurgico{
    func alterarDic(dicFormValuesAtual:[String : Any?])
}

class AUFichaVC: FormViewController, NovoPacienteDelegate,ProcedimentoCirurgico {

    var parseObject:PFObject!
    var type:String = String()
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
    
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()

        let iniciar_dicionarios = Helpers.iniciar_dicionarios()

        pontosFrontalServidor = iniciar_dicionarios.0
        pontosFrontalAtual = iniciar_dicionarios.0
        pontosPerfilServidor = iniciar_dicionarios.1
        pontosPerfilAtual = iniciar_dicionarios.1
        pontosNasalServidor = iniciar_dicionarios.2
        pontosNasalAtual = iniciar_dicionarios.2
        dicFormValuesServidor = iniciar_dicionarios.3
        dicFormValuesAtual = iniciar_dicionarios.3
        
        self.imagemFrontalServidor = UIImage(named: "modelo_frontal")!
        self.imagemPerfilServidor = UIImage(named: "modelo_perfil")!
        self.imagemNasalServidor = UIImage(named: "modelo_nasal")!
        
        let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        centroDeNotificacao.addObserver(self, selector: "noData", name: "noData", object: nil)
        
        if type == "Adicionando" {
            self.title = "Add Ficha"
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed:")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Plain, target: self, action: "getFormValues")
                        
        }else if type == "Atualizando" {
            
            self.formValuesServidor = ParseConnection.getFromServer(parseObject, completion: { (dicFormValues) -> Void in
                self.dicFormValuesServidor = dicFormValues
                self.dicFormValuesAtual = dicFormValues
            })
            
           form.setValues(self.formValuesServidor)

            self.tableView?.reloadData()
            
            ParseConnection.getFromParseImgFrontal(parseObject
                , resultBlockImage: { (image, error) -> Void in
                    self.btn_imagem_frontal.setImage(image, forState: UIControlState.Normal)
                    self.imagemFrontalServidor = image!
                }, progressBlockImage: { (progress) -> Void in
                    print("Baixando |Imgem Frontal| -> \(progress!)")
                }, resultBlockPontos: { (pontos, error) -> Void in
                    self.pontosFrontalServidor = pontos
                    self.pontosFrontalAtual = pontos
                }, progressBlockPontos: { (progress) -> Void in
                    print("Baixando |Pontos Frontal| -> \(progress!)")
            })
            
            
            ParseConnection.getFromParseImgPerfil(parseObject
                , resultBlockImage: { (image, error) -> Void in
                self.btn_imagem_perfil.setImage(image, forState: UIControlState.Normal)
                self.imagemPerfilServidor = image!
                }, progressBlockImage: { (progress) -> Void in
                    print("Baixando |Imgem Perfil| -> \(progress!)")
                }, resultBlockPontos: { (pontos, error) -> Void in
                    self.pontosPerfilServidor = pontos
                    self.pontosPerfilAtual = pontos
                }, progressBlockPontos: { (progress) -> Void in
                    print("Baixando |Pontos Perfil| -> \(progress!)")
            })
            
            ParseConnection.getFromParseImgNasal(parseObject
                , resultBlockImage: { (image, error) -> Void in
                self.btn_imagem_nasal.setImage(image, forState: UIControlState.Normal)
                self.imagemNasalServidor = image!
                }, progressBlockImage: { (progress) -> Void in
                    print("Baixando |Imgem Nasal| -> \(progress!)")
                }, resultBlockPontos: { (pontos, error) -> Void in
                    self.pontosNasalServidor = pontos
                    self.pontosNasalAtual = pontos
                }, progressBlockPontos: { (progress) -> Void in
                    print("Baixando |Pontos Nasal| -> \(progress!)")
            })
        
            
            self.title = "Atualizar Ficha"

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.Plain, target: self, action: "getFormValues")
            
            
            
        }else {
            noData()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //--------------------

    func getFormValues(){
        alertView = SCLAlertView().showWait("\(type)...", subTitle: "Aguarde...", closeButtonTitle: "Cancelar", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
        let results = Helpers.verifyFormValues(form.values(includeHidden: false))
        
        if !results.0 {
            alertView?.close()
            alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio \(results.1) nao foi preenchido", closeButtonTitle: "OK")
            return
        }
        
        if type == "Adicionando" {
            
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
        }else if type == "Atualizando" {
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
            
//            <<< ActionSheetRow<String>("sexo") {
//                $0.title = "Sexo:"
//                $0.selectorTitle = "Qual o sexo do Paciente?"
//                $0.options = ["Masculino", "Feminino"]
//                $0.value = "Masculino"
//            }
            <<< PickerInlineRow<String>("sexo") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Sexo:"
                row.title = "Qual o sexo do Paciente?"
                row.options = ["Masculino", "Feminino"]
                row.value = row.options[0]
            }
            
            <<< PickerInlineRow<String>("etnia") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Etnia:"
                row.title = "Qual a etnia do Paciente?"
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
    func atribuir_imagem(imagem: UIImage, flag: Int) {
        if flag==0 {
            btn_imagem_frontal.setImage(imagem, forState: UIControlState.Normal)
        }
        if flag==1 {
            btn_imagem_perfil.setImage(imagem, forState: UIControlState.Normal)
        }
        if flag==2 {
            btn_imagem_nasal.setImage(imagem, forState: UIControlState.Normal)
        }
    }
    //NovoPacienteDelegate
    func atribuir_marcacao(dic: [String : NSValue], flag: Int) {
        if flag==0{
            self.pontosFrontalAtual = dic
        }
        if flag==1{
            self.pontosPerfilAtual = dic
        }
        if flag==2{
            self.pontosNasalAtual = dic
        }
    }
    
    //--------------------
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segue_img_frontal"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 0
                camera.dicionario = self.pontosFrontalAtual
                if self.btn_imagem_frontal.currentImage != nil{
                    camera.imagem_recuperada = self.btn_imagem_frontal.currentImage
                }
            }
        }
        
        if segue.identifier == "segue_img_perfil"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 1
                camera.dicionario = self.pontosPerfilAtual
                if self.btn_imagem_perfil.currentImage != nil{
                    camera.imagem_recuperada = self.btn_imagem_perfil.currentImage
                }
            }
        }
        
        if segue.identifier == "segue_img_nasal"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 2
                camera.dicionario = self.pontosNasalAtual
                if self.btn_imagem_nasal.currentImage != nil{
                    camera.imagem_recuperada = self.btn_imagem_nasal.currentImage
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

