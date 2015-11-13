//
//  struct ParseDataModel.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 10/11/15.
//  Copyright © 2015 UFPI. All rights reserved.
//

import UIKit
import Parse

/**
 # Conjunto de Funções necessarios para todas as classes.

 São elas:
 * **dataFormatter**: Formatador de NSDate.
 * **criar_thumbnail**: Cria um thumbnail de uma imagem.
 * **comparaImagem**: Verifica se duas imagens sao iguais.
 * **convertAnyObjectToAny**: Converte um diconario [String:AnyObject]  para [String:Any?].
 * **convertAnyToAnyObject**: Converte um diconario [String:Any?]  para [String:AnyObject].
 * **convertAnyToAny**: Converte um diconario [String:Any?]  para [String:Any].
 * **verifyFormValues**: Verifica se algum valor obrigatio da ficha esta vazio.
 * **iniciar_dicionarios**: Retorna os valores padroes de alguns dicionarios.
 */

class Helpers: NSObject{
    
    
    /**
    Formatador de NSDate
    
    - Parameter dateFormat: O formato de formatação da hora e data. ex: dd/MM/yyyy
    - Parameter dateStyle: O estilo de formatação da hora e data. ex: .ShortStyle
     
    - Returns:  **NSDateFormatter**.
    
    */
    
    static func dataFormatter(dateFormat dateFormat:String, dateStyle:NSDateFormatterStyle) -> NSDateFormatter {
        
        let formatador: NSDateFormatter = NSDateFormatter()
        formatador.locale = NSLocale.currentLocale()
        formatador.dateStyle = dateStyle
        formatador.dateFormat = dateFormat
        //NSDateFormatterStyle.ShortStyle
        //"dd/MM/yyyy"
        
        return formatador
    }
    
    /**
     Cria um thumbnail com as dimensoes informadas. Se nao forem informadas(necessariamente os dois), sera criada um thumbnail de 70x70.
     
     - Parameter imagem: Imagem para que seja criado o thumbnail.
     - Parameter width: Largura do thumbnail.
     - Parameter height: Altura do thumbnail.
     
     - Returns:  **UIImage**.
     
     */
    
    static func criar_thumbnail(imagem:UIImage, width: CGFloat?=nil, height: CGFloat?=nil)->UIImage{
        
        let thumbnail_size : CGSize?
        
        if width != nil && height != nil {
            thumbnail_size = CGSizeMake(width!, height!)
        }else{
            thumbnail_size = CGSizeMake(70.0, 70.0)
        }
        
        
        let rect = CGRectMake(0,0,thumbnail_size!.width,thumbnail_size!.height)
        UIGraphicsBeginImageContext(rect.size)
        imagem.drawInRect(rect)
        let picture1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(picture1)
        let img = UIImage(data:imageData!)
        
        return img!
    }
    
    /**
     Compara duas imagens para saber se sao iguais.
     
     - Parameter image1: Primeira Imagem.
     - Parameter image2: Segunda Imagem.
     
     - Returns:  **Bool**.
     
     */
    
    static func comparaImagem(image1:UIImage, image2:UIImage)->Bool{
        let imageData1:NSData = UIImageJPEGRepresentation(image1, 1.0)!
        let imageData2:NSData = UIImageJPEGRepresentation(image2, 1.0)!
        
        return imageData1.isEqualToData(imageData2)
    }
    
    
    // MARK: - Conversores de Dicionarios
  
    /**
    Converte um diconario [String:AnyObject]  para [String:Any?]
    
    - Parameter anyObjectDict: [String: AnyObject]
    
    - Returns:  **[String: Any?]**.
    
    */
    
     static func convertAnyObjectToAny(anyObjectDict:[String: AnyObject]) -> [String: Any?] {
        
        var anyDict = [String: Any?]()
        
        for key in anyObjectDict.keys {
            anyDict.updateValue(anyObjectDict[key], forKey: key)
        }
        return anyDict
    }
    
    /**
    Converte um diconario [String:Any?]  para [String:AnyObject].
    
    - Parameter anyDict: [String: Any?]
    
    - Returns:  **[String: AnyObject]**.
    
    */
    
    static func convertAnyToAnyObject(anyDict:[String: Any?]) -> [String: AnyObject] {
        
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
    
    /**
    Converte um diconario [String:Any?]  para [Any].
    
    - Parameter anyDict: [String: Any?]
    
    - Returns:  **[String: Any]**.
    
    */
    
    static func convertAnyToAny(anyDict:[String: Any?]) -> [String: Any] {
        
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
    
    /**
    Verifica se algum valor obrigatio da ficha esta vazio.
    
    - Parameter anyDict: [String: Any?]
    
    - Returns:  **Bool**.
    - Returns:  **String** Aplicacoes futuras.
    */
    
    static func verifyFormValues(anyDict:[String: Any?]) -> (Bool,String) {
        
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
    
    /**
    Retorna os diconarios dos pontos frontais, perfis, nasais e do plano cirurgico.
    
    - Returns:  **[String:NSValue]?** Diconario dos pontos Frontais.  **[String:NSValue]?** Diconario dos pontos  de Perfis.  **[String:NSValue]?** Diconario dos pontos Nasais.  **[String : Any?]** Diconario padrão do Plano Cirurgico, necessario para evitar consumo exarcebado de banda.

    */
    
    static func iniciar_dicionarios() -> (pontos_frontal:[String:NSValue]?, pontos_perfil:[String:NSValue]?, pontos_nasal:[String:NSValue]?, dicFormValues:[String : Any?]){
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
        
        
        dicFormValues = ["enxerto_de_sheen": "Tipo I Esmagado", "suturas": "Intradomal", "raiz": "Reducao Raspa", "fechada": false, "osso": "Raspa", "dorso": "Nao Tocado", "incisoes": "Inter", "transversa": "Nenhum Transversa", "aberta": true, "lateral": "Nenhum Lateral", "medial": "Nenhum Medial", "enxerto_de_ponta": "Tampao", "liberacao": "Resseccao Cefalica", "cartilagem": "Abaixada"]
        
        return (pontos_frontal,pontos_perfil,pontos_nasal,dicFormValues)
    }
    
}
