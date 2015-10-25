//
//  AUPacienteVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import XLForm
import ImageIO
import Parse

protocol NovoPacienteDelegate{
    func atribuir_imagem(imagem: UIImage, flag:Int)
    func atribuir_marcacao(dic:[String:NSValue], flag:Int)
}

//AUPacienteVC => Adciconar e Atualizacao de Paciente

class AUPacienteVC:XLFormViewController, NovoPacienteDelegate  {
    
    var parseObject:PFObject!
    
    //Verificador para saber se e Add ou Update
    var type:String = String()
    
    //Camera BTN
    @IBOutlet weak var btn_imagem_frontal: UIButton!
    @IBOutlet weak var btn_imagem_perfil: UIButton!
    @IBOutlet weak var btn_imagem_nasal: UIButton!
    
    var pontos_frontal : [String:NSValue]?
    var pontos_perfil : [String:NSValue]?
    var pontos_nasal : [String:NSValue]?
    
    let thumbnail_size : CGSize = CGSizeMake(70.0, 70.0)
    
    var nomePaciente:String = String()
    var sexoPaciente:String = String()
    var etniaPaciente:String = String()
    var dataNascimento:NSDate = NSDate()
    var notas:String = String()

    private enum Tags : String {
        case Nome = "nome"
        case Etnia = "etnia"
        case Sexo = "Sexo"
        case DataNascimento = "dataNascimento"
        case Notas = "notas"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    //Inicializando a Tabela
    func initializeForm() {
        
        var form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        
        form = XLFormDescriptor(title: "Paciente")
        form.rowNavigationOptions = XLFormRowNavigationOptions.Enabled
        
        //---------------------------------
        
        section = XLFormSectionDescriptor()
        form.addFormSection(section)
        
        // Name
        row = XLFormRowDescriptor(tag: Tags.Nome.rawValue, rowType: XLFormRowDescriptorTypeText, title: "Nome")
        row.required = true
        if nomePaciente != "" {
            row.value = nomePaciente
        }else{
            print("OPA 1")
        }
        section.addFormRow(row)
        
        
        // Sexo
        row = XLFormRowDescriptor(tag: Tags.Sexo.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: "Sexo")
        row.selectorOptions = ["Masculino", "Feminino"]
        if sexoPaciente != "" {
            row.value = sexoPaciente
        }else{
            print("OPA 2")
            row.value = "Masculino"
        }
        row.required = true
        section.addFormRow(row)
        
        // Etinia
        row = XLFormRowDescriptor(tag: Tags.Etnia.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: "Raca")
        row.selectorOptions = ["Caucasiano","Negróide","Asiático"]
        if etniaPaciente != "" {
            row.value = etniaPaciente
        }else{
            print("OPA 3")
            row.value = "Caucasiano"
        }
        row.required = true
        section.addFormRow(row)
        
        // Data Nascimento
        row = XLFormRowDescriptor(tag: Tags.DataNascimento.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title: "Data de Nascimento:")
        row.cellConfig.setObject(NSDate(), forKey: "maximumDate")
        row.cellConfig.setObject(UIFont(name: "AppleSDGothicNeo-Regular", size: 16)!, forKey: "textLabel.font")
        if dataNascimento != "" {
            row.value = dataNascimento
        }else{
            row.value = NSDate()
        }
        row.required = true
        section.addFormRow(row)
        
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Notas")
        form.addFormSection(section)
        
        
        // Notes
        row = XLFormRowDescriptor(tag: Tags.Notas.rawValue, rowType:XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure["textView.placeholder"] = "Este paciente ..."
        if notas != "" {
            row.value = notas
        }else{
            print("OPA 5")
        }
        section.addFormRow(row)
        self.form = form
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.iniciar_dicionarios()
        print("TAMANHO \(btn_imagem_frontal.frame)")
        
        if parseObject != nil {
                        
            self.nomePaciente = parseObject.objectForKey("nome") as! String
            self.sexoPaciente = parseObject.objectForKey("sexo") as! String
            self.etniaPaciente = parseObject.objectForKey("etnia") as! String
            self.dataNascimento = dataFormatter().dateFromString(parseObject.objectForKey("data_nascimento") as! String)!
            
            if let notas = parseObject.objectForKey("notas") as? String {
                self.notas = notas
            }
            
            //IMG FRONTAL
            if let img_frontal = parseObject.objectForKey("img_frontal") as? PFFile{
                
                img_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        self.btn_imagem_frontal.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                    }
                    
                    }) { (progress) -> Void in
                        print("Baixando |img_frontal| -> \(Float(progress))")
                }
                
            }else{
                btn_imagem_frontal.setImage(UIImage(named: "modelo_frontal"), forState: UIControlState.Normal)
            }
            
            //IMG PERFIL
            if let img_perfil = parseObject.objectForKey("img_perfil") as? PFFile{
                
                img_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        self.btn_imagem_perfil.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                    }
                    
                    }) { (progress) -> Void in
                        print("Baixando |img_perfil| -> \(Float(progress))")
                }
                
            }else{
                btn_imagem_perfil.setImage(UIImage(named: "modelo_perfil"), forState: UIControlState.Normal)
            }
            
            //IMG NASAL
            if let img_nasal = parseObject.objectForKey("img_nasal") as? PFFile{
                
                img_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        self.btn_imagem_nasal.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                    }
                    
                    }) { (progress) -> Void in
                        print("Baixando |img_nasal| -> \(Float(progress))")
                }
                
            }else{
                btn_imagem_nasal.setImage(UIImage(named: "modelo_nasal"), forState: UIControlState.Normal)
            }
            

            
            
            //DIC FRONTAL
            if let pontos_frontal = parseObject.objectForKey("pontos_frontal") as? PFFile{
                
                pontos_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        self.pontos_frontal = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue]
                    }
                    
                    }) { (progress) -> Void in
                        print("Baixando |pontos_frontal| -> \(Float(progress))")
                }
            }
            
            //DIC PERFIL
            if let pontos_perfil = parseObject.objectForKey("pontos_perfil") as? PFFile{
                
                pontos_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        self.pontos_perfil = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue]
                    }
                    
                    }) { (progress) -> Void in
                        print("Baixando |pontos_perfil| -> \(Float(progress))")
                }
            }
            
            
            //DIC NASAL
            if let pontos_nasal = parseObject.objectForKey("pontos_nasal") as? PFFile{
                
                pontos_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        self.pontos_nasal = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue]
                    }
                    
                    }) { (progress) -> Void in
                        print("Baixando |pontos_nasal| -> \(Float(progress))")
                }
            }
        }else {
            self.parseObject = PFObject(className: "Paciente")

        }
        

        
        //BTN Cancelar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPressed:")
        
        if type == "Add" {
            //BTN Salvar
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "verify:")
        }else if type == "Update" {
            //BTN Update
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: UIBarButtonItemStyle.Plain, target: self, action: "verify:")
        }
        self.view.tintColor = UIColor(red: 76/255, green: 107/255, blue: 148/255, alpha: 1.0)
        
        initializeForm()

    }
    
    //MARK: - Pressionou o btn Cancelar
    
    func cancelPressed(button: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Pressionou o btn Salvar
    
    func verify(button: UIBarButtonItem)
    {
        let array = self.formValidationErrors()
        for errorItem in array {
            let error = errorItem as! NSError
            let validationStatus : XLFormValidationStatus = error.userInfo[XLValidationStatusErrorKey] as! XLFormValidationStatus
            
            if  validationStatus.rowDescriptor!.tag == Tags.Nome.rawValue           ||
                validationStatus.rowDescriptor!.tag == Tags.DataNascimento.rawValue       ||
                validationStatus.rowDescriptor!.tag == Tags.Sexo.rawValue   ||
                validationStatus.rowDescriptor!.tag == Tags.Etnia.rawValue {
                    if let cell = self.tableView.cellForRowAtIndexPath(self.form.indexPathOfFormRow(validationStatus.rowDescriptor!)!) {
                        self.animateCell(cell)
                    }
            }
        }
        
        self.tableView.endEditing(true)
        
        if array.count == 0 {
            if type == "Add" {
                add()
            }else if type == "Update" {
                update()
            }
        }
        
    }
    
    //MARK: - Salvando Ficha
    
    func add () {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.showWait("Salvando", subTitle: "Aguarde...")
        
        self.parseObject["username"] = PFUser.currentUser()!.username

        
        if let nome:String = form.formRowWithTag(Tags.Nome.rawValue)!.value as? String {
            parseObject.setValue(nome, forKey: "nome")
        }
        if let sexo:String = form.formRowWithTag(Tags.Sexo.rawValue)!.value as? String {
            parseObject.setValue(sexo, forKey: "sexo")
        }
        if let etnia:String = form.formRowWithTag(Tags.Etnia.rawValue)!.value as? String {
            parseObject.setValue(etnia, forKey: "etnia")
        }
        if let dataNascimento:NSDate = form.formRowWithTag(Tags.DataNascimento.rawValue)!.value as? NSDate{
            
            let data = dataFormatter().stringFromDate(dataNascimento)
            parseObject.setValue(data, forKey: "data_nascimento")

        }
        
        if let notas:String = form.formRowWithTag(Tags.Notas.rawValue)!.value as? String {
            parseObject.setValue(notas, forKey: "notas")

        }
        
        //Imagens
        
        if btn_imagem_frontal.currentImage != nil{
            let thumb_frontal = self.criar_thumbnail((btn_imagem_frontal.currentImage)!)
            
            let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_frontal, 1.0)!)!
            let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((btn_imagem_frontal.currentImage)!, 1.0)!)!
            
            parseObject.setObject(imageFileThumb, forKey: "thumb_frontal")
            parseObject.setObject(imageFileFrontal, forKey: "img_frontal")
        }
        
        if btn_imagem_perfil.currentImage != nil{
            let thumb_perfil = self.criar_thumbnail((btn_imagem_perfil.currentImage)!)
            
            let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_perfil, 1.0)!)!
            let imageFilePerfil:PFFile = PFFile(data: UIImageJPEGRepresentation((btn_imagem_perfil.currentImage)!, 1.0)!)!
            
            parseObject.setObject(imageFileThumb, forKey: "thumb_perfil")
            parseObject.setObject(imageFilePerfil, forKey: "img_perfil")

        }
        
        if btn_imagem_nasal.currentImage != nil{
            let thumb_nasal = self.criar_thumbnail((btn_imagem_nasal.currentImage)!)
            
            let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_nasal, 1.0)!)!
            let imageFileNasal:PFFile = PFFile(data: UIImageJPEGRepresentation((btn_imagem_nasal.currentImage)!, 1.0)!)!
            
            parseObject.setObject(imageFileThumb, forKey: "thumb_nasal")
            parseObject.setObject(imageFileNasal, forKey: "img_nasal")
        }
        
        //Pontos
    
        //pontos_frontal
        let pontos_frontal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(self.pontos_frontal!))!
        parseObject.setObject(pontos_frontal, forKey: "pontos_frontal")
        
        //pontos_perfil
        let pontos_perfil:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(self.pontos_perfil!))!
        parseObject.setObject(pontos_perfil, forKey: "pontos_perfil")
        
        //pontos_nasal
        let pontos_nasal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(self.pontos_nasal!))!
        parseObject.setObject(pontos_nasal, forKey: "pontos_nasal")
        
        parseObject.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    alertView.hideView()
                    
                    let alertView = SCLAlertView()
                    alertView.showSuccess("UFPI", subTitle: "Dados salvos com sucesso.", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
                })
            }else {
                alertView.hideView()
                
                alertView.showError("UFPI", subTitle: "Algum erro ocorreu ao salvar o arquivo. Informe o erro a equipe de desenvolvimento", closeButtonTitle: "OK")
            }
        }
    }
    
    // MARK: - Update
    
    func update() {
        
        if let nome:String = form.formRowWithTag(Tags.Nome.rawValue)!.value as? String {
            if nomePaciente != nome {
                parseObject.setValue(nome, forKey: "nome")
            }
        }
        if let sexo:String = form.formRowWithTag(Tags.Sexo.rawValue)!.value as? String {
            if sexoPaciente != sexo {
                parseObject.setValue(sexo, forKey: "sexo")
            }
        }
        if let etnia:String = form.formRowWithTag(Tags.Etnia.rawValue)!.value as? String {
            if etniaPaciente != etnia {
                parseObject.setValue(etnia, forKey: "etnia")
            }
        }
        if let dataNascimentoUpdate:NSDate = form.formRowWithTag(Tags.DataNascimento.rawValue)!.value as? NSDate{
            let dataAntiga = dataFormatter().stringFromDate(dataNascimento)
            let dataUpdate = dataFormatter().stringFromDate(dataNascimentoUpdate)
            
            if dataAntiga != dataUpdate {
                parseObject.setValue(dataUpdate, forKey: "data_nascimento")
            }
            
        }
        
        if let notas:String = form.formRowWithTag(Tags.Notas.rawValue)!.value as? String {
            if self.notas != notas {
                parseObject.setValue(notas, forKey: "notas")
            }
        }

        
        /*
            Add verificacao para saber se as imagens mudaram
        */
        
        //Imagens
        
        if btn_imagem_frontal.currentImage != nil{
            let thumb_frontal = self.criar_thumbnail((btn_imagem_frontal.currentImage)!)
            
            let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_frontal, 1.0)!)!
            let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((btn_imagem_frontal.currentImage)!, 1.0)!)!
            
            parseObject.setObject(imageFileThumb, forKey: "thumb_frontal")
            parseObject.setObject(imageFileFrontal, forKey: "img_frontal")
        }
        
        if btn_imagem_perfil.currentImage != nil{
            let thumb_perfil = self.criar_thumbnail((btn_imagem_perfil.currentImage)!)
            
            let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_perfil, 1.0)!)!
            let imageFilePerfil:PFFile = PFFile(data: UIImageJPEGRepresentation((btn_imagem_perfil.currentImage)!, 1.0)!)!
            
            parseObject.setObject(imageFileThumb, forKey: "thumb_perfil")
            parseObject.setObject(imageFilePerfil, forKey: "img_perfil")
            
        }
        
        if btn_imagem_nasal.currentImage != nil{
            let thumb_nasal = self.criar_thumbnail((btn_imagem_nasal.currentImage)!)
            
            let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_nasal, 1.0)!)!
            let imageFileNasal:PFFile = PFFile(data: UIImageJPEGRepresentation((btn_imagem_nasal.currentImage)!, 1.0)!)!
            
            parseObject.setObject(imageFileThumb, forKey: "thumb_nasal")
            parseObject.setObject(imageFileNasal, forKey: "img_nasal")
        }
        
        //Pontos
        
        //pontos_frontal
        let pontos_frontal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(self.pontos_frontal!))!
        parseObject.setObject(pontos_frontal, forKey: "pontos_frontal")
        
        //pontos_perfil
        let pontos_perfil:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(self.pontos_perfil!))!
        parseObject.setObject(pontos_perfil, forKey: "pontos_perfil")
        
        //pontos_nasal
        let pontos_nasal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(self.pontos_nasal!))!
        parseObject.setObject(pontos_nasal, forKey: "pontos_nasal")
        
        parseObject.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            }
        }
    }
    
    //MARK: - Helperph
    
    func animateCell(cell: UITableViewCell) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values =  [0, 20, -20, 10, 0]
        animation.keyTimes = [0, (1 / 6.0), (3 / 6.0), (5 / 6.0), 1]
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.additive = true
        cell.layer.addAnimation(animation, forKey: "shake")
    }
    
    // MARK: - Formatador
    
    func dataFormatter() -> NSDateFormatter {
        
        let formatador: NSDateFormatter = NSDateFormatter()
        let localizacao = NSLocale(localeIdentifier: "pt_BR")
        formatador.locale = localizacao
        formatador.dateStyle =  NSDateFormatterStyle.ShortStyle
        formatador.dateFormat = "dd/MM/yyyy"
        
        return formatador
    }

    // Rever esta funcao
    
    // MARK: - Dicionarios
    
    func iniciar_dicionarios(){
        self.pontos_frontal = [
            "Triquio":NSValue(CGPoint: CGPointMake(1005, 550)),
            "Arco_Esquerdo":NSValue(CGPoint: CGPointMake(675, 770)),
            "Glabela":NSValue(CGPoint: CGPointMake(988, 831)),
            "Arco_Direito":NSValue(CGPoint: CGPointMake(1310, 770)),
            "Canto_Lateral_Esquerdo":NSValue(CGPoint: CGPointMake(582, 936)),
            "Limbo_Lateral_Esquerdo":NSValue(CGPoint: CGPointMake(692, 934)),
            "Canto_Medial_Esquerdo":NSValue(CGPoint: CGPointMake(844, 934)),
            "Nasio":NSValue(CGPoint: CGPointMake(990, 934)),
            "Canto_Medial_Direito":NSValue(CGPoint: CGPointMake(1137, 934)),
            "Limbo_Lateral_Direito":NSValue(CGPoint: CGPointMake(1291, 934)),
            "Canto_Lateral_Direito":NSValue(CGPoint: CGPointMake(1386, 934)),
            "Orbitario_Esquerdo":NSValue(CGPoint: CGPointMake(720, 1114)),
            "Orbitario_Direito":NSValue(CGPoint: CGPointMake(1264, 1114)),
            "Asa_Nasal_Esquerda":NSValue(CGPoint: CGPointMake(860, 1320)),
            "Asa_Nasal_Direita":NSValue(CGPoint: CGPointMake(1117, 1320)),
            "Vermilion_Esquerda":NSValue(CGPoint: CGPointMake(916, 1520)),
            "Vermilion_Direita":NSValue(CGPoint: CGPointMake(1035, 1520)),
            "Fenda":NSValue(CGPoint: CGPointMake(978, 1583)),
            "Labiomental_Crease":NSValue(CGPoint: CGPointMake(976, 1720)),
            "Mento":NSValue(CGPoint: CGPointMake(976, 1880))]
        
        self.pontos_perfil = [
            "Triquio":NSValue(CGPoint: CGPointMake(1394, 390)),
            "Glabela":NSValue(CGPoint: CGPointMake(1557, 722)),
            "Nasio":NSValue(CGPoint: CGPointMake(1510, 831)),
            "Rinio":NSValue(CGPoint: CGPointMake(1579, 916)),
            "Ponta_Nariz":NSValue(CGPoint: CGPointMake(1645, 1078)),
            "Columela":NSValue(CGPoint: CGPointMake(1595, 1131)),
            "Subnasal":NSValue(CGPoint: CGPointMake(1505, 1142)),
            "Labio_Superior":NSValue(CGPoint: CGPointMake(1543, 1260)),
            "Fenda_Oral":NSValue(CGPoint: CGPointMake(1512, 1308)),
            "Labio_Inferior":NSValue(CGPoint: CGPointMake(1547, 1352)),
            "Supramental":NSValue(CGPoint: CGPointMake(1491, 1434)),
            "Pogonio":NSValue(CGPoint: CGPointMake(1520, 1542)),
            "Mento":NSValue(CGPoint: CGPointMake(1455, 1677)),
            "Cervical":NSValue(CGPoint: CGPointMake(1212, 1655)),
            "Tragion":NSValue(CGPoint: CGPointMake(908, 997)),
            "Orbitario":NSValue(CGPoint: CGPointMake(1425, 994))]
        
        self.pontos_nasal = [
            "Ponto_Superior_Esquerdo":NSValue(CGPoint: CGPointMake(700, 805)),
            "Ponto_Superior_Direito":NSValue(CGPoint: CGPointMake(1207, 782)),
            "Ponto_Inferior_Esquerdo":NSValue(CGPoint: CGPointMake(477, 1394)),
            "Ponto_Inferior_Direito":NSValue(CGPoint: CGPointMake(1478, 1396)),
            "Asa_Esquerda":NSValue(CGPoint: CGPointMake(146, 1285)),
            "Asa_Direita":NSValue(CGPoint: CGPointMake(1740, 1337)),
            "Juncao_Esquerda":NSValue(CGPoint: CGPointMake(200, 1588)),
            "Juncao_Direita":NSValue(CGPoint: CGPointMake(1683, 1657))]
    }
    
    // MARK: - Criar ThumbNail

    func criar_thumbnail(imagem:UIImage)->UIImage{
        let rect = CGRectMake(0,0,thumbnail_size.width,thumbnail_size.height)
        UIGraphicsBeginImageContext(rect.size)
        imagem.drawInRect(rect)
        let picture1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(picture1)
        let img = UIImage(data:imageData!)
        
        return img!
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segue_img_frontal"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 0
                camera.dicionario = self.pontos_frontal
                if self.btn_imagem_frontal.currentImage != nil{
                    camera.imagem_recuperada = self.btn_imagem_frontal.currentImage
                }
            }
        }
        
        if segue.identifier == "segue_img_perfil"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 1
                camera.dicionario = self.pontos_perfil
                if self.btn_imagem_perfil.currentImage != nil{
                    camera.imagem_recuperada = self.btn_imagem_perfil.currentImage
                }
            }
        }
        
        if segue.identifier == "segue_img_nasal"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 2
                camera.dicionario = self.pontos_nasal
                if self.btn_imagem_nasal.currentImage != nil{
                    camera.imagem_recuperada = self.btn_imagem_nasal.currentImage
                }
            }
        }
    }
    
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
    
    func atribuir_marcacao(dic: [String : NSValue], flag: Int) {
        if flag==0{
            self.pontos_frontal = dic
        }
        if flag==1{
            self.pontos_perfil = dic
        }
        if flag==2{
            self.pontos_nasal = dic
        }
    }
    
}
