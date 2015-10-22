//
//  NovoPacienteViewController.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 18/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import CoreData
import ImageIO

protocol NovoPacienteDelegate{
    func atribuir_imagem(imagem: UIImage, flag:Int)
    func atribuir_marcacao(dic:[String:CGPoint], flag:Int)
}

class NovoPacienteViewController: UIViewController,NovoPacienteDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    var pacientes = [NSManagedObject]()
    
    @IBOutlet weak var btn_imagem_frontal: UIButton!
    @IBOutlet weak var btn_imagem_perfil: UIButton!
    @IBOutlet weak var btn_imagem_nasal: UIButton!
    
    @IBOutlet weak var campo_texto_nome: UITextField!
    @IBOutlet weak var campo_texto_sobrenome: UITextField!
    @IBOutlet weak var captura_etnia: UIPickerView!
    @IBOutlet weak var captura_data_nascimento: UIDatePicker!
    
    var pontos_frontal : [String:CGPoint]?
    var pontos_perfil : [String:CGPoint]?
    var pontos_nasal : [String:CGPoint]?
    
    var etnia_selecionada : String = "Caucasiano"
    let thumbnail_size : CGSize = CGSizeMake(70.0, 70.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iniciar_dicionarios()
        print("TAMANHO \(btn_imagem_frontal.frame)")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func remover_teclado(sender: AnyObject) {
        self.resignFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView==self.captura_etnia {
            return 1
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView==self.captura_etnia {
            return 3
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView==self.captura_etnia{
            if row == 0{
                return "Caucasiano"
            }
            else if row == 1{
                return "Negróide"
            }
            else if row == 2{
                return "Asiático"
            }
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.captura_etnia{
            if row == 0{
                etnia_selecionada = "Caucasiano"
            }
            else if row == 1{
                etnia_selecionada = "Negróide"
            }
            else if row == 2{
                etnia_selecionada = "Asiático"
            }
        }
    }
    
    
    // Rever esta funcao
    
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
    
    @IBAction func salvar_dados(sender: AnyObject) {
        self.salvar_paciente()
    }
    
    func salvar_paciente(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Paciente", inManagedObjectContext:managedContext)
        
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        
        person.setValue(campo_texto_nome.text, forKey: "nome")
        person.setValue(campo_texto_sobrenome.text, forKey: "sobrenome")
        person.setValue(etnia_selecionada, forKey: "etnia")
        
        var thumb_frontal : UIImage
        if btn_imagem_frontal.imageView?.image != nil{
            thumb_frontal = self.criar_thumbnail((btn_imagem_frontal.imageView?.image)!)
            print("CHEGOU AKI");
            person.setValue(UIImageJPEGRepresentation(thumb_frontal, 1.0), forKey: "thumb_frontal")
            print("CHEGOU AKI");
        }
        
//        var thumb_perfil : UIImage
//        if btn_imagem_frontal.imageView?.image != nil{
//            thumb_perfil = self.criar_thumbnail((btn_imagem_perfil.imageView?.image)!)
//        }
//        
//        var thumb_nasal : UIImage
//        if btn_imagem_frontal.imageView?.image != nil{
//            thumb_nasal = self.criar_thumbnail((btn_imagem_nasal.imageView?.image)!)
//        }
        
        
        
        do {
            try managedContext.save()
            pacientes.append(person)
            print("Paciente Salvo Com Sucesso")
        } catch let error as NSError  {
            print("Nao foi possivel salvar \(error), \(error.userInfo)")
        }
    }
    
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
}
