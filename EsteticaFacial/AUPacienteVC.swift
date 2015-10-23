//
//  AUPacienteVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import XLForm
import CoreData
import ImageIO

protocol NovoPacienteDelegate{
    func atribuir_imagem(imagem: UIImage, flag:Int)
    func atribuir_marcacao(dic:[String:CGPoint], flag:Int)
}

//AUPacienteVC => Adciconar e Atualizacao de Paciente

class AUPacienteVC:XLFormViewController, NovoPacienteDelegate  {
    
    //CoreData
    var ficha: Paciente!
    var moContext: NSManagedObjectContext?
    var entity: NSEntityDescription?
    
    //Verificador para saber se e Add ou Update
    var type:String = String()
    
    //Camera BTN
    @IBOutlet weak var btn_imagem_frontal: UIButton!
    @IBOutlet weak var btn_imagem_perfil: UIButton!
    @IBOutlet weak var btn_imagem_nasal: UIButton!
    
    var pontos_frontal : [String:CGPoint]?
    var pontos_perfil : [String:CGPoint]?
    var pontos_nasal : [String:CGPoint]?
    
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
        row = XLFormRowDescriptor(tag: Tags.Sexo.rawValue, rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Sexo")
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
        row = XLFormRowDescriptor(tag: Tags.Etnia.rawValue, rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Raca")
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
        if dataNascimento != "" {
            row.value = dataNascimento
        }else{
            print("OPA 4")
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
        
        if ficha != nil {
            self.nomePaciente = ficha.nome!
            self.sexoPaciente = ficha.sexo!
            self.etniaPaciente = ficha.etnia!
            self.dataNascimento = ficha.nascimento!
            
            if ficha.notas != nil {
                self.notas = ficha.notas!
            }
            
            if let imageData = ficha.thumb_frontal{
                btn_imagem_frontal.setImage(UIImage(data: imageData), forState: UIControlState.Normal)
            }else {
                btn_imagem_frontal.setImage(UIImage(named: "modelo_frontal"), forState: UIControlState.Normal)
            }
            
            if let imageData = ficha.thumb_nasal{
                btn_imagem_nasal.setImage(UIImage(data: imageData), forState: UIControlState.Normal)
            }else {
                btn_imagem_nasal.setImage(UIImage(named: "modelo_nasal"), forState: UIControlState.Normal)
            }
            
            if let imageData = ficha.thumb_perfil{
                btn_imagem_perfil.setImage(UIImage(data: imageData), forState: UIControlState.Normal)
            }else {
                btn_imagem_perfil.setImage(UIImage(named: "modelo_perfil"), forState: UIControlState.Normal)
            }
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moContext = appDelegate.managedObjectContext
        
        // Cria um managedObject pronto para ser inserido
        let ficha = NSEntityDescription.insertNewObjectForEntityForName("Paciente", inManagedObjectContext: moContext) as! Paciente
        
        if let nome:String = form.formRowWithTag(Tags.Nome.rawValue)!.value as? String {
            ficha.nome = nome
        }
        if let sexo:String = form.formRowWithTag(Tags.Sexo.rawValue)!.value as? String {
            ficha.sexo = sexo
        }
        if let etnia:String = form.formRowWithTag(Tags.Etnia.rawValue)!.value as? String {
            ficha.etnia = etnia
        }
        if let dataNascimento:NSDate = form.formRowWithTag(Tags.DataNascimento.rawValue)!.value as? NSDate{
            
            let data = dataFormatter().stringFromDate(dataNascimento)
            
            ficha.nascimento = dataFormatter().dateFromString(data)
        }
        
        if let notas:String = form.formRowWithTag(Tags.Notas.rawValue)!.value as? String {
            ficha.notas = notas
        }
        
        //Imagens
        
        var thumb_frontal : UIImage
        if btn_imagem_frontal.imageView?.image != nil{
            thumb_frontal = self.criar_thumbnail((btn_imagem_frontal.imageView?.image)!)
            print("CHEGOU AKI")
            ficha.thumb_frontal = UIImageJPEGRepresentation(thumb_frontal, 1.0)
            print("CHEGOU AKI")
        }
        
        
    
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            do {
                try moContext.save()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        })
        
        
        
    }
    
    // MARK: - Update
    
    func update() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moContext = appDelegate.managedObjectContext
        
        
        if let nome:String = form.formRowWithTag(Tags.Nome.rawValue)!.value as? String {
            ficha!.nome = nome
        }
        if let sexo:String = form.formRowWithTag(Tags.Sexo.rawValue)!.value as? String {
            ficha!.sexo = sexo
        }
        if let etnia:String = form.formRowWithTag(Tags.Etnia.rawValue)!.value as? String {
            ficha!.etnia = etnia
        }
        if let dataNascimento:NSDate = form.formRowWithTag(Tags.DataNascimento.rawValue)!.value as? NSDate{
            
            let data = dataFormatter().stringFromDate(dataNascimento)
            
            ficha!.nascimento = dataFormatter().dateFromString(data)!
        }
        
        if let notas:String = form.formRowWithTag(Tags.Notas.rawValue)!.value as? String {
            ficha!.notas = notas
        }
        
        //Imagens
        
        var thumb_frontal : UIImage
        if btn_imagem_frontal.imageView?.image != nil{
            thumb_frontal = self.criar_thumbnail((btn_imagem_frontal.imageView?.image)!)
            print("CHEGOU AKI")
            ficha.thumb_frontal = UIImageJPEGRepresentation(thumb_frontal, 1.0)
            print("CHEGOU AKI")
        }
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            do {
                try moContext.save()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        })
        
        
        
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
            "Triquio":CGPointMake(1005, 550),
            "Arco_Esquerdo":CGPointMake(675, 770),
            "Glabela":CGPointMake(988, 831),
            "Arco_Direito":CGPointMake(1310, 770),
            "Canto_Lateral_Esquerdo":CGPointMake(582, 936),
            "Limbo_Lateral_Esquerdo":CGPointMake(692, 934),
            "Canto_Medial_Esquerdo":CGPointMake(844, 934),
            "Nasio":CGPointMake(990, 934),
            "Canto_Medial_Direito":CGPointMake(1137, 934),
            "Limbo_Lateral_Direito":CGPointMake(1291, 934),
            "Canto_Lateral_Direito":CGPointMake(1386, 934),
            "Orbitario_Esquerdo":CGPointMake(720, 1114),
            "Orbitario_Direito":CGPointMake(1264, 1114),
            "Asa_Nasal_Esquerda":CGPointMake(860, 1320),
            "Asa_Nasal_Direita":CGPointMake(1117, 1320),
            "Vermilion_Esquerda":CGPointMake(916, 1520),
            "Vermilion_Direita":CGPointMake(1035, 1520),
            "Fenda":CGPointMake(978, 1583),
            "Labiomental_Crease":CGPointMake(976, 1720),
            "Mento":CGPointMake(976, 1880)]
        
        self.pontos_perfil = [
            "Triquio":CGPointMake(1394, 390),
            "Glabela":CGPointMake(1557, 722),
            "Nasio":CGPointMake(1510, 831),
            "Rinio":CGPointMake(1579, 916),
            "Ponta_Nariz":CGPointMake(1645, 1078),
            "Columela":CGPointMake(1595, 1131),
            "Subnasal":CGPointMake(1505, 1142),
            "Labio_Superior":CGPointMake(1543, 1260),
            "Fenda_Oral":CGPointMake(1512, 1308),
            "Labio_Inferior":CGPointMake(1547, 1352),
            "Supramental":CGPointMake(1491, 1434),
            "Pogonio":CGPointMake(1520, 1542),
            "Mento":CGPointMake(1455, 1677),
            "Cervical":CGPointMake(1212, 1655),
            "Tragion":CGPointMake(908, 997),
            "Orbitario":CGPointMake(1425, 994)]
        
        self.pontos_nasal = [
            "Ponto_Superior_Esquerdo":CGPointMake(700, 805),
            "Ponto_Superior_Direito":CGPointMake(1207, 782),
            "Ponto_Inferior_Esquerdo":CGPointMake(477, 1394),
            "Ponto_Inferior_Direito":CGPointMake(1478, 1396),
            "Asa_Esquerda":CGPointMake(146, 1285),
            "Asa_Direita":CGPointMake(1740, 1337),
            "Juncao_Esquerda":CGPointMake(200, 1588),
            "Juncao_Direita":CGPointMake(1683, 1657)]
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
                //   btn_imagem_frontal.setImage(camera.imagem_capturada.image!, forState: UIControlState.Normal)
            }
        }
        
        if segue.identifier == "segue_img_perfil"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 1
                camera.dicionario = self.pontos_perfil
            }
        }
        
        if segue.identifier == "segue_img_nasal"{
            if let camera = segue.destinationViewController as? CameraViewController{
                camera.delegate = self
                camera.flag = 2
                camera.dicionario = self.pontos_nasal
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
    
    func atribuir_marcacao(dic: [String : CGPoint], flag: Int) {
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
