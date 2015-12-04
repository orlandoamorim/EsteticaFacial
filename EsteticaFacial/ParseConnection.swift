//
//  ParseCommunication.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 12/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import Parse
import SwiftyDrop

/**
 # Comunicação com o Servidor
 Esta classe possui as funções responsaveis por salvar, atualizar e pegar dados do servidor.
 
 São elas:
 * **adicionarFicha**: Adiconar uma nova ficha no servidor.
 * **atualizarFicha**: Atuliza, se necessario, os dados de uma ficha no servidor.
 * **getFromServer**: Pega todos os dados contidos no servidro referente a uma ficha.
 * **getFromParseImgFrontal**: Baixa a imagem Frontal e os Pontos Frontal do servidor.
 * **getFromParseImgPerfil**: Baixa a imagem Perfil e os Pontos Perfil do servidor.
 * **getFromParseImgNasal**: Baixa a imagem Nasal e os Pontos Nasal do servidor.
 * **getFromParseThumbnailImgFrontal**: Baixa o Thumbnail da imagem Frontal e os Pontos Frontal do servidor.
 * **getFromParseThumbnailImgPerfil**: Baixa o Thumbnail da imagem Perfil e os Pontos Perfil do servidor.
 * **getFromParseThumbnailImgNasal**: Baixa o Thumbnail da imagem Nasal e os Pontos Nasal do servidor.
 */

class ParseConnection: NSObject {
    
    
    static func getAllFromParse(block: ((objects:[PFObject]?, error:NSError?) -> Void)){
        let query = PFQuery(className:"Paciente")
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        print(PFUser.currentUser()!.username!)
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.orderByAscending("nome")
        
        switch Helpers.verificaSwitch() {
        case "realizadas":
            query.whereKey("cirurgia_realizada", equalTo: true)
            print("realizadas")
        case "nao_realizadas":
            query.whereKey("cirurgia_realizada", equalTo: false)
            print("nao_realizadas")
            
        default: break
        }
        
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            block(objects: objects, error: error)
        }
    }

    
    /**
     Salva a `Ficha` *assincronamente* no servidor e executa o bloco de retorno.
     
     - Parameter formValues: Todos os valores da ficha. ex: nome, telefone...
     
     - Parameter dicFormValues: Todos os valores da ficha do plano cirurgico. ex: Enxerto de Sheen, Raiz...
          
     - Parameter imagemFrontal: Imagem Frontal.

     - Parameter imagemPerfil: Imagem de Perfil.
     
     - Parameter imagemNasal: Imagem Nasal.
     
     - Parameter PontosPerfil: Pontos Perfil.
     
     - Parameter pontosFrontal: Pontos Frontal.
     
     - Parameter pontosNasal: Pontos Nasal.

     
     - Parameter `Bloco`: Para executar. Ele contem os seguintes argumentos: `^(BOOL sucesso, NSError *error)`.
     
     */
    
    
    static func adicionarFicha(formValues:[String : Any?],dicFormValues:[String : Any?],imagemPerfil:UIImage?,imagemFrontal:UIImage?,imagemNasal:UIImage?,pontosFrontalAtual:[String:NSValue]?,pontosPerfilAtual:[String:NSValue]?,pontosNasalAtual:[String:NSValue]?,completion: ((sucesso: Bool?,erro: NSError?) -> Void)){
        
        var parseObject:PFObject!
        let iniciar_dicionarios = Helpers.iniciar_dicionarios()

        let formValues = Helpers.convertAnyToAnyObject(formValues)

        //******** Secao 0

        parseObject = PFObject(className: "Paciente")
        //parseObject.ACL = PFACL(user: PFUser.currentUser()!)
        parseObject["username"] = PFUser.currentUser()!.username
        parseObject["nome"] = formValues["nome"]
        parseObject["sexo"] = formValues["sexo"]
        parseObject["etnia"] = formValues["etnia"]
        parseObject["data_nascimento"] = Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate(formValues["data_nascimento"] as! NSDate)

        
        if  formValues["email"] != nil {
            parseObject["email"] = formValues["email"]
        }
        if  formValues["telefone"] != nil {
            parseObject["telefone"] = formValues["telefone"]
        }

        //******** Secao 1

        if !NSDictionary(dictionary: Helpers.convertAnyToAnyObject(dicFormValues)).isEqualToDictionary(Helpers.convertAnyToAnyObject(iniciar_dicionarios.dicFormValues)) {
            print("dic_plano_cirurgico")
            
            let dic_plano_cirurgico:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(Helpers.convertAnyToAnyObject(dicFormValues)))!
            parseObject.setObject(dic_plano_cirurgico, forKey: "dic_plano_cirurgico")
        }
        
        parseObject["cirurgia_realizada"] = formValues["cirurgia_realizada"]
        
        //******** Secao 2

        if  formValues["notas"] != nil {
            parseObject["notas"] = formValues["notas"]
        }

        //******** Imagens
        
        if imagemFrontal != nil {
                let thumb_frontal = Helpers.criar_thumbnail(imagemFrontal!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_frontal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemFrontal)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_frontal")
                parseObject.setObject(imageFileFrontal, forKey: "img_frontal")
                
                //pontos_frontal
                if pontosFrontalAtual! != iniciar_dicionarios.pontos_frontal! {
                    print("pontos_frontal")
                    let pontos_frontal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontosFrontalAtual!))!
                    parseObject.setObject(pontos_frontal, forKey: "pontos_frontal")
                }
                
            
        }
        
        if imagemPerfil != nil {
                let thumb_perfil = Helpers.criar_thumbnail((imagemPerfil)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_perfil, 1.0)!)!
                let imageFilePerfil:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemPerfil)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_perfil")
                parseObject.setObject(imageFilePerfil, forKey: "img_perfil")
                
                //pontos_frontal
                if pontosPerfilAtual! != iniciar_dicionarios.pontos_perfil! {
                    print("pontos_perfil")
                    let pontos_perfil:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontosPerfilAtual!))!
                    parseObject.setObject(pontos_perfil, forKey: "pontos_perfil")
                }
                
            
        }
        

        
        if imagemNasal != nil {
                let thumb_nasal = Helpers.criar_thumbnail((imagemNasal)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_nasal, 1.0)!)!
                let imageFileNasal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemNasal)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_nasal")
                parseObject.setObject(imageFileNasal, forKey: "img_nasal")
                
                //pontos_frontal
                if pontosNasalAtual! != iniciar_dicionarios.pontos_nasal! {
                    print("pontos_nasal")
                    let pontos_nasal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontosNasalAtual!))!
                    parseObject.setObject(pontos_nasal, forKey: "pontos_nasal")
                }
                
            
        }
        
        parseObject.saveInBackgroundWithBlock { (success, error) -> Void in
            completion(sucesso: success, erro: error)
        }
    }
    
    
    /**
     Atualiza a `Ficha` *assincronamente* no servidor e executa o bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser atualizado.

     - Parameter formValuesServidor: Todos os valores da ficha  presentes atualmente no servidor. ex: nome, telefone...
     - Parameter formValues: Todos os valores da ficha. ex: nome, telefone...
     
     - Parameter dicFormValuesServidor: Todos os valores da ficha do plano cirurgico presente atualmente no servidor. ex: Enxerto de Sheen, Raiz...
     - Parameter dicFormValuesAtual: Todos os valores da ficha do plano cirurgico. ex: Enxerto de Sheen, Raiz...

     - Parameter imagemFrontalServidor: Imagem Frontal presente no servidor.
     - Parameter imagemFrontalAtual: Imagem Frontal atualizada.

     - Parameter imagemPerfilServidor: Imagem Perfil presente no servidor.
     - Parameter imagemPerfilAtual: Imagem Perfil atualizada.
     
     - Parameter imagemNasalServidor: Imagem Nasal presente no servidor.
     - Parameter imagemNasalAtual: Imagem Nasal atualizada.
     
     - Parameter pontosFrontalServidor: Pontos Frontal presente no servidor.
     - Parameter pontosFrontalAtual: Pontos Frontal atualizada.
     
     - Parameter pontosPerfilServidor: Pontos Perfil presente no servidor.
     - Parameter pontosPerfilAtual: Pontos Perfil atualizada.
     
     - Parameter pontosNasalServidor: Pontos Nasal presente no servidor.
     - Parameter pontosNasalAtual: Pontos Nasal atualizada.
     
     - Parameter `Bloco`: Para executar. Ele contem os seguintes argumentos: `^(BOOL sucesso, NSError *error)`.
     
     */
    
    
    static func atualizarFicha(parseObject:PFObject
        , formValuesServidor:[String : Any?], formValuesAtual:[String : Any?]
        , dicFormValuesServidor:[String : Any?], dicFormValuesAtual:[String : Any?]
        , imagemFrontalServidor:UIImage?=nil, imagemFrontalAtual:UIImage?=nil
        , imagemPerfilServidor:UIImage?=nil, imagemPerfilAtual:UIImage?=nil
        , imagemNasalServidor:UIImage?=nil, imagemNasalAtual:UIImage?=nil
        , pontosFrontalServidor:[String:NSValue]?, pontosFrontalAtual:[String:NSValue]?
        , pontosPerfilServidor:[String:NSValue]?, pontosPerfilAtual:[String:NSValue]?
        , pontosNasalServidor:[String:NSValue]?, pontosNasalAtual:[String:NSValue]?
        , completion: ((sucesso: Bool?,erro: NSError?) -> Void)){
        
        
        let formValuesAtual = Helpers.convertAnyToAnyObject(formValuesAtual)
        let formValuesAntigo = Helpers.convertAnyToAnyObject(formValuesServidor)
        
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
        
        if Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate(formValuesAtual["data_nascimento"] as! NSDate) != Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate(formValuesAntigo["data_nascimento"] as! NSDate) {
            parseObject["data_nascimento"] = Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate(formValuesAtual["data_nascimento"] as! NSDate)
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
        if !NSDictionary(dictionary: Helpers.convertAnyToAnyObject(dicFormValuesServidor)).isEqualToDictionary(Helpers.convertAnyToAnyObject(dicFormValuesAtual)) {
            print("dic_plano_cirurgico")
            
            let dic_plano_cirurgico:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(Helpers.convertAnyToAnyObject(dicFormValuesAtual)))!
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
            if !Helpers.comparaImagem(imagemPerfilServidor!, image2: imagemPerfilAtual!){
                let thumb_perfil = Helpers.criar_thumbnail((imagemPerfilAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_perfil, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemPerfilAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_perfil")
                parseObject.setObject(imageFileFrontal, forKey: "img_perfil")
            }
            
            //pontos_perfil
            if !NSDictionary(dictionary: pontosPerfilServidor!).isEqualToDictionary(pontosPerfilAtual!) {
                print("pontos_perfil")
                let pontosPerfilAtual:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontosPerfilAtual!))!
                parseObject.setObject(pontosPerfilAtual, forKey: "pontos_perfil")
            }
        }
        
        if imagemFrontalAtual != nil {
            if !Helpers.comparaImagem(imagemFrontalServidor!, image2: imagemFrontalAtual!){
                let thumb_frontal = Helpers.criar_thumbnail((imagemFrontalAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_frontal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemFrontalAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_frontal")
                parseObject.setObject(imageFileFrontal, forKey: "img_frontal")
            }
            //pontos_frontal
            if !NSDictionary(dictionary: pontosFrontalServidor!).isEqualToDictionary(pontosFrontalAtual!) {
                print("pontos_frontal")
                let pontos_frontal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontosFrontalAtual!))!
                parseObject.setObject(pontos_frontal, forKey: "pontos_frontal")
            }
        }
        
        if imagemNasalAtual != nil {
            if !Helpers.comparaImagem(imagemNasalServidor!, image2: imagemNasalAtual!){
                let thumb_nasal = Helpers.criar_thumbnail((imagemNasalAtual)!)
                
                let imageFileThumb:PFFile = PFFile(data: UIImageJPEGRepresentation(thumb_nasal, 1.0)!)!
                let imageFileFrontal:PFFile = PFFile(data: UIImageJPEGRepresentation((imagemNasalAtual)!, 1.0)!)!
                
                parseObject.setObject(imageFileThumb, forKey: "thumb_nasal")
                parseObject.setObject(imageFileFrontal, forKey: "img_nasal")
            }
            
            //pontos_frontal
            if !NSDictionary(dictionary: pontosNasalServidor!).isEqualToDictionary(pontosNasalAtual!) {
                print("pontos_nasal")
                let pontos_nasal:PFFile = PFFile(data: NSKeyedArchiver.archivedDataWithRootObject(pontosNasalAtual!))!
                parseObject.setObject(pontos_nasal, forKey: "pontos_nasal")
            }
        }
        
        
        //******** Salvando Atualizacao
        
        parseObject.saveInBackgroundWithBlock { (success, error) -> Void in
            completion(sucesso: success, erro: error)
        }
        
    }
    
    
    /**
     Baixa os dados da `Ficha` e do `Plano Cirurgico` *assincronamente* do servidor e executa o bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter `Bloco`: Para executar. Ele contem os seguintes argumentos: `^(BOOL sucesso, NSError *error)`.
     - Returns: Dicionario **[String : Any?]** com as informacoes da ficha do usuario.

     */
    
    static func getFichaFromServer(parseObject:PFObject, resultBlockForm: ((formValues:  [String : Any?]) -> Void), resultBlockDic: ((dicFormValues:  [String : Any?]) -> Void), progressBlockDic: ((progress: Float?) -> Void)){
        
        var formValues:[String : Any?] = [String : Any?]()
        
        formValues["nome"] = parseObject.objectForKey("nome") as! String
        formValues["sexo"] = parseObject.objectForKey("sexo") as! String
        formValues["etnia"] = parseObject.objectForKey("etnia") as! String
        formValues["data_nascimento"] = Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).dateFromString(parseObject.objectForKey("data_nascimento") as! String)!
        
        
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
                    resultBlockDic(dicFormValues: Helpers.convertAnyObjectToAny(dados))
                }
                
                }) { (progress) -> Void in
                    progressBlockDic(progress: Float(progress))
                    print("Baixando |dic_plano_cirurgico| -> \(Float(progress))")
            }
        }
        
        resultBlockForm(formValues: formValues)
    }
    
    /**
     Baixa a `Imagem Frontal` referente a `Ficha` *assincronamente* e executa os bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlockImage : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlockPontos : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     */
    
    static func getFromParseImgFrontal(parseObject:PFObject
        ,resultBlockImage: ((data: NSData?,error: NSError?) -> Void), progressBlockImage: ((progress: Float?) -> Void)
        ,resultBlockPontos: ((pontos: [String : NSValue]?,error: NSError?) -> Void), progressBlockPontos: ((progress: Float?) -> Void)) {
        if let img_frontal = parseObject.objectForKey("img_frontal") as? PFFile{
            
            img_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in

                    resultBlockImage(data: data, error: error)
                    
                    //DIC FRONTAL
                    if let pontos_frontal = parseObject.objectForKey("pontos_frontal") as? PFFile{
                        
                        pontos_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            resultBlockPontos(pontos: NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue], error: error)
                            
                            }) { (progress) -> Void in
                                progressBlockPontos(progress: Float(progress))
                        }
                }

                
                }) { (progress) -> Void in
                    progressBlockImage(progress: Float(progress))
            }
        }
    }
    
    /**
     Baixa a `Imagem Perfil` referente a `Ficha` *assincronamente* e executa os bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlockImage : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlockPontos : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     */
    
   static func getFromParseImgPerfil(parseObject:PFObject
        ,resultBlockImage: ((data: NSData?,error: NSError?) -> Void), progressBlockImage: ((progress: Float?) -> Void)
        ,resultBlockPontos: ((pontos: [String : NSValue]?,error: NSError?) -> Void), progressBlockPontos: ((progress: Float?) -> Void)) {
            if let img_perfil = parseObject.objectForKey("img_perfil") as? PFFile{
                
                img_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        resultBlockImage(data: data, error: nil)
                        //DIC FRONTAL
                        if let pontos_perfil = parseObject.objectForKey("pontos_perfil") as? PFFile{
                            
                            pontos_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                resultBlockPontos(pontos: NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue], error: error)
                                
                                }) { (progress) -> Void in
                                    progressBlockPontos(progress: Float(progress))
                            }
                        }
                    }) { (progress) -> Void in
                        progressBlockImage(progress: Float(progress))
                }
            }
    }
    
    
    /**
     Baixa a `Imagem Nasal` referente a `Ficha` *assincronamente* e executa os bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlockImage : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlockPontos : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     */

    static func getFromParseImgNasal(parseObject:PFObject
        ,resultBlockImage: ((data: NSData?,error: NSError?) -> Void), progressBlockImage: ((progress: Float?) -> Void)
        ,resultBlockPontos: ((pontos: [String : NSValue]?,error: NSError?) -> Void), progressBlockPontos: ((progress: Float?) -> Void)) {
            if let img_nasal = parseObject.objectForKey("img_nasal") as? PFFile{
                
                img_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        resultBlockImage(data: data, error: error)
                        
                        //DIC FRONTAL
                        if let pontos_nasal = parseObject.objectForKey("pontos_nasal") as? PFFile{
                            
                            pontos_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                    resultBlockPontos(pontos: NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue], error: error)
                                
                                }) { (progress) -> Void in
                                    progressBlockPontos(progress: Float(progress))
                            }
                        }
                    
                    }) { (progress) -> Void in
                        progressBlockImage(progress: Float(progress))
                }
            }
    }


    /**
     Baixa a `Thumbnail da Imagem Frontal` referente a `Ficha` *assincronamente* e executa os bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlock : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.

     */
    
    static func getFromParseThumbnailImgFrontal(parseObject:PFObject,resultBlock: ((data: NSData?,error: NSError?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let thumb_frontal = parseObject.objectForKey("thumb_frontal") as? PFFile{
            
            thumb_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                resultBlock(data: data, error: error)
            
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    /**
     Baixa a `Thumbnail da Imagem Perfil` referente a `Ficha` *assincronamente* e executa os bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlock : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     
     */
    
    static func getFromParseThumbnailImgPerfil(parseObject:PFObject,resultBlock: ((data: NSData?,error: NSError?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let thumb_perfil = parseObject.objectForKey("thumb_perfil") as? PFFile{
            
            thumb_perfil.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    resultBlock(data: data, error: error)
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    /**
     Baixa a `Thumbnail da Imagem Nasal` referente a `Ficha` *assincronamente* e executa os bloco de retorno.
     
     - Parameter parseObject: O PFObject a ser baixado.
     
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(NSData data, NSError *error)`.
     - Parameter progressBlock : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     
     */
    
    static func getFromParseThumbnailImgNasal(parseObject:PFObject,resultBlock: ((data: NSData?,error: NSError?) -> Void), progressBlock: ((progress: Float?) -> Void)) {
        if let thumb_nasal = parseObject.objectForKey("thumb_nasal") as? PFFile{
            
            thumb_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    resultBlock(data: data, error: error)
                
                }) { (progress) -> Void in
                    progressBlock(progress: Float(progress))
            }
        }
    }
    
    /**
     Baixa a `Imagem do Usuario`  *assincronamente* e executa os bloco de retorno.
          
     - Parameter resultBlock : Para executar. Ele contem os seguintes argumentos: `^(UIIMAGE image, NSError *error)`.
     - Parameter progressBlock : Para executar. Ele contem os seguintes argumentos: `^(FLOAT progress)`.
     
     */
    
    static func getUserImage(resultBlock: ((data: NSData?,error: NSError?) -> Void), progressBlock: ((progress: Float?) -> Void)){
        let query:PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if let userImage = object["userImage"] as? PFFile {
                            userImage.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                    resultBlock(data: data, error: error)
                                }, progressBlock: { (progress) -> Void in
                                        progressBlock(progress: Float(progress))
                            })
                        }else{
                            //retorna nil se o usuario nao possuir nenhuma imagem.
                            resultBlock(data: nil, error: nil)
                        }
                    }
                    
                }
            }
        }
    }
}
