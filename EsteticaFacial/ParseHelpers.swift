//
//  struct ParseDataModel.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 10/11/15.
//  Copyright © 2015 UFPI. All rights reserved.
//

import UIKit
import Parse

struct ParseHelpers {
    
    // MARK: - Formatador
    
    func dataFormatter() -> NSDateFormatter {
        
        let formatador: NSDateFormatter = NSDateFormatter()
        let localizacao = NSLocale(localeIdentifier: "pt_BR")
        formatador.locale = localizacao
        formatador.dateStyle =  NSDateFormatterStyle.ShortStyle
        formatador.dateFormat = "dd/MM/yyyy"
        
        return formatador
    }
    
    // MARK: - Criar ThumbNail
    
    func criar_thumbnail(imagem:UIImage)->UIImage{
        let thumbnail_size : CGSize = CGSizeMake(70.0, 70.0)

        
        let rect = CGRectMake(0,0,thumbnail_size.width,thumbnail_size.height)
        UIGraphicsBeginImageContext(rect.size)
        imagem.drawInRect(rect)
        let picture1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(picture1)
        let img = UIImage(data:imageData!)
        
        return img!
    }
    
    // MARK: - Verificador de imagens
    func imageIgual(image1:UIImage, image2:UIImage)->Bool{
        let imageData1:NSData = UIImageJPEGRepresentation(image1, 1.0)!
        let imageData2:NSData = UIImageJPEGRepresentation(image2, 1.0)!
        
        return imageData1.isEqualToData(imageData2)
    }
    
    
    // MARK: - Conversores de Dicionarios
    
    func convertAnyObjectToAny(anyObjectDict:[String: AnyObject]) -> [String: Any?] {
        
        var anyDict = [String: Any?]()
        
        for key in anyObjectDict.keys {
            anyDict.updateValue(anyObjectDict[key], forKey: key)
        }
        return anyDict
    }
    
    func convertAnyToAnyObject(anyDict:[String: Any?]) -> [String: AnyObject] {
        
        var anyObjectDict = [String: AnyObject]()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                anyObjectDict[key] = string
            }else if let bool = anyDict[key]! as? Bool {
                anyObjectDict[key] = bool
            }else if let data = anyDict[key]! as? NSDate {
                anyObjectDict[key] = data
            }
        }
        return anyObjectDict
    }
    
    func convertAnyToAny(anyDict:[String: Any?]) -> [String: Any] {
        
        var anyToAnyDict = [String: Any]()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                anyToAnyDict[key] = string
            }else if let bool = anyDict[key]! as? Bool {
                anyToAnyDict[key] = bool
            }else if let data = anyDict[key]! as? NSDate {
                anyToAnyDict[key] = data
            }
        }
        
        return anyToAnyDict
    }
    
    func verifyFormValues(anyDict:[String: Any?]) -> (Bool,String) {
        
        var verifyFormValues = [String: Any]()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                verifyFormValues[key] = string
            }else if let bool = anyDict[key]! as? Bool {
                verifyFormValues[key] = bool
            }else if let data = anyDict[key]! as? NSDate {
                verifyFormValues[key] = data
            }else if key ==  "email" || key ==  "telefone" || key ==  "btn_plano_cirurgico" || key ==  "btn_cirurgia_realizada" || key == "notas"{
                continue
            }else{
                return (false,key)
            }
        }
        
        return (true,"ok")
    }
    
    // MARK: - Dicionarios
    
    func iniciar_dicionarios() -> ([String:NSValue]?, [String:NSValue]?, [String:NSValue]?, [String : Any?]){
        var pontos_frontal : [String:NSValue]?
        var pontos_perfil : [String:NSValue]?
        var pontos_nasal : [String:NSValue]?
        var dicFormValues:[String : Any?] = [String : Any?]()
        
        pontos_frontal = [
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
        
        pontos_perfil = [
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
        
        pontos_nasal = [
            "Ponto_Superior_Esquerdo":NSValue(CGPoint: CGPointMake(700, 805)),
            "Ponto_Superior_Direito":NSValue(CGPoint: CGPointMake(1207, 782)),
            "Ponto_Inferior_Esquerdo":NSValue(CGPoint: CGPointMake(477, 1394)),
            "Ponto_Inferior_Direito":NSValue(CGPoint: CGPointMake(1478, 1396)),
            "Asa_Esquerda":NSValue(CGPoint: CGPointMake(146, 1285)),
            "Asa_Direita":NSValue(CGPoint: CGPointMake(1740, 1337)),
            "Juncao_Esquerda":NSValue(CGPoint: CGPointMake(200, 1588)),
            "Juncao_Direita":NSValue(CGPoint: CGPointMake(1683, 1657))]
        
        
        //Plano Cirurgico
        dicFormValues = ["enxerto_de_sheen": "Tipo I Esmagado", "suturas": "Intradomal", "raiz": "Reducao Raspa", "fechada": false, "osso": "Raspa", "dorso": "Nao Tocado", "incisoes": "Inter", "transversa": "Nenhum Transversa", "aberta": true, "lateral": "Nenhum Lateral", "medial": "Nenhum Medial", "enxerto_de_ponta": "Tampao", "liberacao": "Resseccao Cefalica", "cartilagem": "Abaixada"]
        
        return (pontos_frontal,pontos_perfil,pontos_nasal,dicFormValues)
    }
    
    //------------------------------------------
    
    func getFromParse(parseObject:PFObject, completion: ((dicFormValues:  [String : Any?]) -> Void)) -> ([String : Any?]){
        
        var formValues:[String : Any?] = [String : Any?]()

        formValues["nome"] = parseObject.objectForKey("nome") as! String
        formValues["sexo"] = parseObject.objectForKey("sexo") as! String
        formValues["etnia"] = parseObject.objectForKey("etnia") as! String
        formValues["data_nascimento"] = dataFormatter().dateFromString(parseObject.objectForKey("data_nascimento") as! String)!
        
        
        if let email = parseObject.objectForKey("email") as? String {
            formValues["email"] = email
        }
        
        if let telefone = parseObject.objectForKey("telefone") as? String {
            formValues["telefone"] = telefone
        }
        
        formValues["cirurgia_realizada"] = parseObject.objectForKey("cirurgia_realizada") as! Bool
        
        if let notasP = parseObject.objectForKey("notas") as? String {
            formValues["notas"] = notasP
        }
          
        //DIC PLANO CIRURGICO
        if let dic_plano_cirurgico = parseObject.objectForKey("dic_plano_cirurgico") as? PFFile{
            
            dic_plano_cirurgico.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let dados = NSKeyedUnarchiver.unarchiveObjectWithData(data!)! as! [String:AnyObject]
                    completion(dicFormValues: self.convertAnyObjectToAny(dados))
                }
                
                }) { (progress) -> Void in
                    print("Baixando |dic_plano_cirurgico| -> \(Float(progress))")
            }
        }
        return formValues
    }
    
    // MARK: - Pegando as Imagens em alta qualidade
    func getFromParseImgFrontal(parseObject:PFObject,completion: ((image: UIImage?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let img_frontal = parseObject.objectForKey("img_frontal") as? PFFile{
            
            img_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    completion(image: image)
                }
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    func getFromParseImgPerfil(parseObject:PFObject,completion: ((image: UIImage?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let img_perfil = parseObject.objectForKey("img_perfil") as? PFFile{
            
            img_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    completion(image: image)
                }
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    func getFromParseImgNasal(parseObject:PFObject,completion: ((image: UIImage?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let img_nasal = parseObject.objectForKey("img_nasal") as? PFFile{
            
            img_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    completion(image: image)
                }
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    // MARK: - Pegando os thumbnail das imagens
    
    func getFromParseThumbnailImgFrontal(parseObject:PFObject,completion: ((image: UIImage?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let thumb_frontal = parseObject.objectForKey("thumb_frontal") as? PFFile{
            
            thumb_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    completion(image: image)
                }
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    func getFromParseThumbnailImgPerfil(parseObject:PFObject,completion: ((image: UIImage?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let thumb_perfil = parseObject.objectForKey("thumb_perfil") as? PFFile{
            
            thumb_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    completion(image: image)
                }
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    func getFromParseThumbnailImgNasal(parseObject:PFObject,completion: ((image: UIImage?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let thumb_nasal = parseObject.objectForKey("thumb_nasal") as? PFFile{
            
            thumb_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    completion(image: image)
                }
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    // MARK: - Adiconado nova Ficha
    
    func addFicha(formValues:[String : Any?],dicFormValues:[String : Any?],dicFormValuesAtual:[String : Any?],imagemPerfil:UIImage?=nil,imagemPerfilAtual:UIImage?=nil,imagemFrontal:UIImage?=nil,imagemFrontalAtual:UIImage?=nil,imagemNasal:UIImage?=nil,imagemNasalAtual:UIImage?=nil,pontos_frontal:[String:NSValue]?=nil,pontos_frontal_update:[String:NSValue]?=nil,pontos_perfil:[String:NSValue]?=nil,pontos_perfil_update:[String:NSValue]?=nil,pontos_nasal:[String:NSValue]?=nil,pontos_nasal_update:[String:NSValue]?=nil,completion: ((success: Bool?,error: NSError?) -> Void)){
        
        let formValues = convertAnyToAnyObject(formValues)
        var parseObject:PFObject!

        parseObject = PFObject(className: "Paciente")
//        parseObject.ACL = PFACL(user: PFUser.currentUser()!)
        parseObject["username"] = PFUser.currentUser()!.username
        parseObject["nome"] = formValues["nome"]
        parseObject["sexo"] = formValues["sexo"]
        parseObject["etnia"] = formValues["etnia"]
        parseObject["data_nascimento"] = dataFormatter().stringFromDate(formValues["data_nascimento"] as! NSDate)
        
        if  formValues["email"] != nil {
            parseObject["email"] = formValues["email"]
        }
        if  formValues["telefone"] != nil {
            parseObject["telefone"] = formValues["telefone"]
        }
        if  formValues["notas"] != nil {
            parseObject["notas"] = formValues["notas"]
        }

        parseObject["cirurgia_realizada"] = formValues["cirurgia_realizada"]
        
        if imagemPerfilAtual != nil {
            if !self.imageIgual(imagemPerfil!, image2: imagemPerfilAtual!){
                let thumb_perfil = self.criar_thumbnail((imagemPerfilAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_perfil, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemPerfilAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_perfil")
                parseObject.setObject(imageFileFrontal, forKey: "img_perfil")
                
                //pontos_frontal
                if pontos_perfil! != pontos_perfil_update! {
                    print("pontos_perfil")
                    let pontos_perfil:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontos_perfil!))!
                    parseObject.setObject(pontos_perfil, forKey: "pontos_perfil")
                }

            }
        }
        
        if imagemFrontalAtual != nil {
            if !self.imageIgual(imagemFrontal!, image2: imagemFrontalAtual!){
                let thumb_frontal = self.criar_thumbnail((imagemFrontalAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_frontal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemFrontalAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_frontal")
                parseObject.setObject(imageFileFrontal, forKey: "img_frontal")
                
                //pontos_frontal
                if pontos_frontal! != pontos_frontal_update! {
                    print("pontos_frontal")
                    let pontos_frontal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontos_frontal!))!
                    parseObject.setObject(pontos_frontal, forKey: "pontos_frontal")
                }
                
            }
        }
        
        if imagemNasalAtual != nil {
            if !self.imageIgual(imagemNasal!, image2: imagemNasalAtual!){
                let thumb_nasal = self.criar_thumbnail((imagemNasalAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_nasal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemNasalAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_nasal")
                parseObject.setObject(imageFileFrontal, forKey: "img_nasal")
                
                //pontos_frontal
                if pontos_nasal! != pontos_nasal_update! {
                    print("pontos_nasal")
                    let pontos_nasal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontos_nasal!))!
                    parseObject.setObject(pontos_nasal, forKey: "pontos_nasal")
                }
                
            }
        }

        //dic_plano_cirurgico
        if !NSDictionary(dictionary: convertAnyToAnyObject(dicFormValues)).isEqualToDictionary(convertAnyToAnyObject(dicFormValuesAtual)) {
            print("dic_plano_cirurgico")
            
            let dic_plano_cirurgico:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(ParseHelpers().convertAnyToAnyObject(dicFormValuesAtual)))!
            parseObject.setObject(dic_plano_cirurgico, forKey: "dic_plano_cirurgico")
        }
        
        parseObject.saveInBackgroundWithBlock { (success, error) -> Void in
            completion(success: success, error: error)
        }
    }
    
    
    // MARK: - Func Update ficha
    
    func atualizaFicha(parseObject:PFObject, formValuesAntigo:[String : Any?], formValuesAtual:[String : Any?],dicFormValues:[String : Any?],dicFormValuesAtual:[String : Any?],imagemPerfil:UIImage?=nil,imagemPerfilAtual:UIImage?=nil,imagemFrontal:UIImage?=nil,imagemFrontalAtual:UIImage?=nil,imagemNasal:UIImage?=nil,imagemNasalAtual:UIImage?=nil,pontos_frontal:[String:NSValue]?=nil,pontos_frontal_update:[String:NSValue]?=nil,pontos_perfil:[String:NSValue]?=nil,pontos_perfil_update:[String:NSValue]?=nil,pontos_nasal:[String:NSValue]?=nil,pontos_nasal_update:[String:NSValue]?=nil,completion: ((success: Bool?,error: NSError?) -> Void)){
        
        let formValuesAtual = convertAnyToAnyObject(formValuesAtual)
        let formValuesAntigo = convertAnyToAnyObject(formValuesAntigo)
        
        //******** Secao 0
        
        if  formValuesAtual["nome"] as? String != formValuesAntigo["nome"] as? String {
            parseObject["nome"] = formValuesAtual["nome"]
        }
        
        if  formValuesAtual["sexo"] as? String != formValuesAntigo["sexo"] as? String {
            parseObject["sexo"] = formValuesAtual["sexo"]
        }
        
        if  formValuesAtual["etnia"] as? String != formValuesAntigo["etnia"] as? String {
            parseObject["etnia"] = formValuesAtual["etnia"]
        }
        
        if dataFormatter().stringFromDate(formValuesAtual["data_nascimento"] as! NSDate) != dataFormatter().stringFromDate(formValuesAntigo["data_nascimento"] as! NSDate) {
            parseObject["data_nascimento"] = dataFormatter().stringFromDate(formValuesAtual["data_nascimento"] as! NSDate)
        }
        
        
        if let _ = formValuesAtual["email"]  {
            if let telefoneAntigo = formValuesAntigo["email"]  {
                if  formValuesAtual["email"] as? String != telefoneAntigo as? String {
                    parseObject["email"] = formValuesAtual["email"]
                }
            }else{
                parseObject["email"] = formValuesAtual["email"]
            }
        }else {
            if let _ = formValuesAntigo["email"]  {
                parseObject.removeObjectForKey("email")
            }
        }
        
        
        if let _ = formValuesAtual["telefone"]  {
            if let telefoneAntigo = formValuesAntigo["telefone"]  {
                if  formValuesAtual["telefone"] as? String != telefoneAntigo as? String {
                    parseObject["telefone"] = formValuesAtual["telefone"]
                }
            }else{
                parseObject["telefone"] = formValuesAtual["telefone"]
            }
        }else {
            if let _ = formValuesAntigo["telefone"]  {
                parseObject.removeObjectForKey("telefone")
            }
        }
        
        //******** Secao 1
        
        //dic_plano_cirurgico
        if !NSDictionary(dictionary: convertAnyToAnyObject(dicFormValues)).isEqualToDictionary(convertAnyToAnyObject(dicFormValuesAtual)) {
            print("dic_plano_cirurgico")
            
            let dic_plano_cirurgico:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(ParseHelpers().convertAnyToAnyObject(dicFormValuesAtual)))!
            parseObject.setObject(dic_plano_cirurgico, forKey: "dic_plano_cirurgico")
        }
        
        
        if  formValuesAtual["cirurgia_realizada"] as? Bool != formValuesAntigo["cirurgia_realizada"] as? Bool {
            parseObject["cirurgia_realizada"] = formValuesAtual["cirurgia_realizada"]
        }
        
        //******** Secao 2
        
        if let _ = formValuesAtual["notas"]  {
            if let telefoneAntigo = formValuesAntigo["notas"]  {
                if  formValuesAtual["notas"] as? String != telefoneAntigo as? String {
                    parseObject["notas"] = formValuesAtual["notas"]
                }
            }else{
                parseObject["notas"] = formValuesAtual["notas"]
            }
        }else {
            if let _ = formValuesAntigo["notas"]  {
                parseObject.removeObjectForKey("notas")
            }
        }

        
        //******** Imagens
        
        if imagemPerfilAtual != nil {
            if !self.imageIgual(imagemPerfil!, image2: imagemPerfilAtual!){
                let thumb_perfil = self.criar_thumbnail((imagemPerfilAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_perfil, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemPerfilAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_perfil")
                parseObject.setObject(imageFileFrontal, forKey: "img_perfil")
            }
            
            //pontos_frontal
            if pontos_perfil! != pontos_perfil_update! {
                print("pontos_perfil")
                let pontos_perfil:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontos_perfil!))!
                parseObject.setObject(pontos_perfil, forKey: "pontos_perfil")
            }
        }
        
        if imagemFrontalAtual != nil {
            if !self.imageIgual(imagemFrontal!, image2: imagemFrontalAtual!){
                let thumb_frontal = self.criar_thumbnail((imagemFrontalAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_frontal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemFrontalAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_frontal")
                parseObject.setObject(imageFileFrontal, forKey: "img_frontal")
            }
            
            //pontos_frontal
            if pontos_frontal! != pontos_frontal_update! {
                print("pontos_frontal")
                let pontos_frontal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontos_frontal!))!
                parseObject.setObject(pontos_frontal, forKey: "pontos_frontal")
            }
        }
        
        if imagemNasalAtual != nil {
            if !self.imageIgual(imagemNasal!, image2: imagemNasalAtual!){
                let thumb_nasal = self.criar_thumbnail((imagemNasalAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_nasal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemNasalAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_nasal")
                parseObject.setObject(imageFileFrontal, forKey: "img_nasal")
            }
            
            //pontos_frontal
            if pontos_nasal! != pontos_nasal_update! {
                print("pontos_nasal")
                let pontos_nasal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontos_nasal!))!
                parseObject.setObject(pontos_nasal, forKey: "pontos_nasal")
            }
        }


        //******** Salvando Atualizacao
        
        parseObject.saveInBackgroundWithBlock { (success, error) -> Void in
            completion(success: success, error: error)
        }
    
    }

}
