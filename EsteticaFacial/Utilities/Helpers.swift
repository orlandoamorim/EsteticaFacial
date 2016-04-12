//
//  struct ParseDataModel.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 10/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import AssetsLibrary
import DeviceKit

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
            }else if let teste = anyDict[key]! as? [String]{
                anyObjectDict[key] = teste
            }else if let arrayStrings = anyDict[key]! as? Set<String> {
                anyObjectDict[key] = getArrayFromSet(arrayStrings)
            }
        }
        return anyObjectDict
    }
    
    /**
    Converte um diconario [String:Any?]  para [String: Any].
    
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
            }else if let arrayStrings = anyDict[key]! as? Set<String> {
                anyToAnyDict[key] = getArrayFromSet(arrayStrings)
            }
        }
        
        return anyToAnyDict
    }
    
    /**
    Verifica se algum valor obrigatio da ficha esta vazio.
    
    - Parameter anyDict: [String: Any?]
    
    - Returns:  **Bool**.
    - Returns:  **String** Usado para formular aviso para o usuario.
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
            }else if key == "btn_recover_patient" || key == "btn_show_surgeries" || key ==  "mail" || key ==  "phone" || key ==  "btn_plano_cirurgico" || key ==  "btn_cirurgia_realizada" || key ==  "surgeryRealized" || key == "note"{
                continue
            }else{
                return (false,key)
            }
        }
        
        return (true,"ok")
    }
    
    /**
     Retorna um formulario padrao para os Planos Cirurgicos
     
     - Returns:  **[String : Any?]**.
     */
    
    static func surgicalPlanningForm() -> [String : Any?] {
//        let dicFormValues:[String : AnyObject] = ["enxerto_de_sheen": ["Tipo I Esmagado"], "suturas": ["Intradomal"], "raiz": ["Reducao Raspa"], "osso": ["Raspa"], "dorso": ["Nao Tocado"], "incisoes": ["Inter"], "transversa": ["Nenhum Transversa"], "abordagem": false, "lateral": ["Nenhum Lateral"], "medial": ["Nenhum Medial"], "enxerto_de_ponta": ["Tampao"], "liberacao": ["Resseccao Cefalica"], "cartilagem": ["Abaixada"],"abordagem_opcoes": "Retrograda"]
        let dicFormValues:[String : AnyObject] = ["abordagem": false]
        
        var formArray: [String : Any?] = [String : Any?]()
        
        for (key, value) in dicFormValues {
            if let string = value as? String {
                formArray.updateValue(string , forKey: key)
            }else if let bool = value as? Bool {
                formArray.updateValue(bool , forKey: key)
            }else if let stringArray = value as? [String] {
                let set: NSSet = NSSet(array: stringArray)
                formArray.updateValue(set as! Set<String>, forKey: key )
            }
            
        }
        return formArray
    }
    
    
    // MARK: - Dicionarios
    
    /**
    Retorna os diconarios dos pontos frontais, perfis, nasais e do plano cirurgico.
    
    - Returns:  **[String:NSValue]?** Diconario dos pontos Frontais.  **[String:NSValue]?** Diconario dos pontos  de Perfis.  **[String:NSValue]?** Diconario dos pontos Nasais.  **[String : Any?]** Diconario padrão do Plano Cirurgico, necessario para evitar consumo exarcebado de banda.

    */
    
    static func iniciar_dicionarios() -> (pontos_frontal:[String:NSValue]?, pontos_perfil:[String:NSValue]?, pontos_nasal:[String:NSValue]?){
        var pontos_frontal : [String:NSValue]?
        var pontos_perfil : [String:NSValue]?
        var pontos_nasal : [String:NSValue]?
        
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
        
        return (pontos_frontal,pontos_perfil,pontos_nasal)
    }
    
    /**
     Vaerifica qual tipo de conteudo o usuario deseja mostrar na tableview
     
     - Returns:  **String**.
     */
    
    static func verificaSwitch()->String{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefaults.valueForKey("switchCT") != nil) {
            let switchCT = userDefaults.valueForKey("switchCT")
            
            if switchCT as! String == "realizadas" {
                return "realizadas"
            }else if switchCT as! String == "nao_realizadas" {
                return "nao_realizadas"
            }else if switchCT as! String == "todas" {
                return "todas"
            }
        }else {
            userDefaults.setValue("Todas", forKey: "switchCT")
            userDefaults.synchronize()
            return "todas"
        }
        
        return "todas"
    }
    
    /**
     Retorna a ultima foto da galeria.
     
     - Returns:  **[UIImage]**.
     */
    
    func getLatestPhotos(completion completionBlock : ([UIImage] -> ()))   {
        let library = ALAssetsLibrary()
        var count = 0
        var images : [UIImage] = []
        var stopped = false
        
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { (group, stop) -> Void in
            
            group?.setAssetsFilter(ALAssetsFilter.allPhotos())
            
            group?.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: {
                (asset : ALAsset!, index, stopEnumeration) -> Void in
                
                if (!stopped)
                {
                    if count >= 1
                    {
                        
                        stopEnumeration.memory = ObjCBool(true)
                        stop.memory = ObjCBool(true)
                        completionBlock(images)
                        stopped = true
                    }
                    else
                    {
                        // For just the thumbnails use the following line.
                        let cgImage = asset.thumbnail().takeUnretainedValue()
                        
                        // Use the following line for the full image.
//                        let cgImage = asset.defaultRepresentation().fullScreenImage().takeUnretainedValue()
                        
                        if let image:UIImage = UIImage(CGImage: cgImage) {
                            images.append(image)
                            count += 1
                        }
                    }
                }
                
            })
            
            },failureBlock : { error in
                print(error)
        })
    }
    
    static func removeImageView(view:UIView){
        view.subviews.forEach ({
            if $0 is UIImageView {
                $0.removeFromSuperview()
            }
        })
    }
    

    static func inicializeImageView(type type:Bool, view: UIView, imageTypes:ImageTypes, cropBoxFrame: CGRect? = nil) {
        var imageViewObject :UIImageView!
        
        if type {
            print(cropBoxFrame!)
            imageViewObject = UIImageView(frame:cropBoxFrame!)

        }else{
            imageViewObject = inicializeImageViewFrame()
        }
        
        imageViewObject.contentMode = UIViewContentMode.ScaleAspectFill
        
        switch imageTypes {
        case.Front:   imageViewObject.image = UIImage(named: "modelo_frontal")
        case.ProfileRight:    imageViewObject.image = UIImage(named: "modelo_perfil")
        case.ProfileLeft:    imageViewObject.image = nil
        case.ObliqueRight:    imageViewObject.image = nil
        case.ObliqueLeft:    imageViewObject.image = nil
        case.Nasal:     imageViewObject.image = UIImage(named: "modelo_nasal")
        }
        
        imageViewObject.layer.masksToBounds = true
        imageViewObject.layer.borderWidth = 1
        imageViewObject.layer.borderColor = UIColor.whiteColor().CGColor
        
        view.addSubview(imageViewObject)
        
    }
    
    static private func inicializeImageViewFrame() -> UIImageView {
        let device = Device()
        if device == .iPhone4 || device == .iPhone4s {
            switch UIDevice.currentDevice().orientation{
            case .Portrait:             return UIImageView(frame:CGRectMake(14.0, 72.0, 292.0, 292.0))
            case .PortraitUpsideDown:   return UIImageView(frame:CGRectMake(14.0, 72.0, 292.0, 292.0))
            case .LandscapeLeft:        return UIImageView(frame:CGRectMake(14.0, 72.0, 292.0, 292.0))
            case .LandscapeRight:       return UIImageView(frame:CGRectMake(14.0, 72.0, 292.0, 292.0))
            default:                    return UIImageView(frame:CGRectMake(14.0, 72.0, 292.0, 292.0))
            }

        }else if device == .iPhone5 || device == .iPhone5c || device == .iPhone5s {
            switch UIDevice.currentDevice().orientation{
            case .Portrait:             return UIImageView(frame:CGRectMake(14.0, 116.0, 292.0, 292.0))
            case .PortraitUpsideDown:   return UIImageView(frame:CGRectMake(14.0, 116.0, 292.0, 292.0))
            case .LandscapeLeft:        return UIImageView(frame:CGRectMake(14.0, 116.0, 292.0, 292.0))
            case .LandscapeRight:       return UIImageView(frame:CGRectMake(14.0, 116.0, 292.0, 292.0))
            default:                    return UIImageView(frame:CGRectMake(14.0, 116.0, 292.0, 292.0))
            }

        }else if device == .Simulator(.iPhone6) || device == .Simulator(.iPhone6s) {
            switch UIDevice.currentDevice().orientation{
            case .Portrait:             return UIImageView(frame:CGRectMake(14.0, 138.0, 347.0, 347.0))
            case .PortraitUpsideDown:   return UIImageView(frame:CGRectMake(14.0, 138.0, 347.0, 347.0))
            case .LandscapeLeft:        return UIImageView(frame:CGRectMake(14.0, 138.0, 347.0, 347.0))
            case .LandscapeRight:       return UIImageView(frame:CGRectMake(14.0, 138.0, 347.0, 347.0))
            default:                    return UIImageView(frame:CGRectMake(14.0, 138.0, 347.0, 347.0))
            }
            
        } else if device == .iPhone6Plus || device == .iPhone6sPlus {
            switch UIDevice.currentDevice().orientation{
            case .Portrait:             return UIImageView(frame:CGRectMake(14.0, 153.0, 386.0, 386.0))
            case .PortraitUpsideDown:   return UIImageView(frame:CGRectMake(14.0, 153.0, 386.0, 386.0))
            case .LandscapeLeft:        return UIImageView(frame:CGRectMake(14.0, 153.0, 386.0, 386.0))
            case .LandscapeRight:       return UIImageView(frame:CGRectMake(14.0, 153.0, 386.0, 386.0))
            default:                    return UIImageView(frame:CGRectMake(14.0, 153.0, 386.0, 386.0))
            }
            
        } else if device == .iPad3 {
            switch UIDevice.currentDevice().orientation{
            case .Portrait:             return UIImageView(frame:CGRectMake(14.0, 120.0, 740.0, 740.0))
            case .PortraitUpsideDown:   return UIImageView(frame:CGRectMake(14.0, 120.0, 740.0, 740.0))
            case .LandscapeLeft:        return UIImageView(frame:CGRectMake(120.0, 14.0, 740.0, 740.0))
            case .LandscapeRight:       return UIImageView(frame:CGRectMake(120.0, 14.0, 740.0, 740.0))
            default:                    return UIImageView(frame:CGRectMake(120.0, 14.0, 740.0, 740.0))
            }
            
        }
        
        return UIImageView(frame:CGRectMake(14.0, 116.0, 292.0, 292.0))
    }
    
    
    static func getArrayFromSet(set:NSSet)-> NSArray {
        return set.map ({ String($0) })
    }
    
    static func setTitle(title:String, subtitle:String) -> UIView {
        //Create a label programmatically and give it its property's
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0)) //x, y, width, height where y is to offset from the view center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        //Create a label for the Subtitle
        let subtitleLabel = UILabel(frame: CGRectMake(0, 18, 0, 0))
        subtitleLabel.backgroundColor = UIColor.clearColor()
        subtitleLabel.textColor = UIColor.lightGrayColor()
        subtitleLabel.font = UIFont.systemFontOfSize(12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        // Create a view and add titleLabel and subtitleLabel as subviews setting
        let titleView = UIView(frame: CGRectMake(0, 0, max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), 30))
        
        // Center title or subtitle on screen (depending on which is larger)
        if titleLabel.frame.width >= subtitleLabel.frame.width {
            var adjustment = subtitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subtitleLabel.frame.width/2)
            subtitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        return titleView
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//    let getImage =  UIImage(data: NSData(contentsOfURL: NSURL(string: self.remoteImage)))
//    UIImageJPEGRepresentation(getImage, 100).writeToFile(imagePath, atomically: true)
//    
//    dispatch_async(dispatch_get_main_queue()) {
//    self.image?.image = getImage
//    return
//    }
//    }
}
