//
//  LabInCloudVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 17/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

class LabInCloud:NSObject{
    
    ///Makes an *asynchronous* request to log in a user with specified credentials.
    static func login(username: String, password: String, view:UIViewController){
        PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) in
            if user != nil && error != nil{
                getRecords(view)
            } else {
                alertError(view)
            }
        }
    }
    
    /// Used when user specified credentials returns error
    private static func alertError(view:UIViewController){
        let alert = UIAlertController(title: "LabInCloud", message: "Ocorreu algum erro, tente novamente.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (username) in
            username.placeholder = "Nome de Usuario"
        }
        
        alert.addTextFieldWithConfigurationHandler { (password) in
            password.placeholder = "Senha"
            password.secureTextEntry = true
            
        }
        
        alert.addAction(UIAlertAction(title: "Logar", style: UIAlertActionStyle.Default, handler: { (login) in
            let username = alert.textFields![0]
            let password = alert.textFields![1]
            if username.text == "" || password.text == "" {
                self.alertError(view)
            }else{
               self.login(username.text!, password: password.text!, view: view)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: { (cancel) in
            let sync = view as! SyncVC
            sync.form.rowByTag("LabInCloud")?.baseValue = false
            sync.form.rowByTag("LabInCloud")?.updateCell()
        }))
        
        view.presentViewController(alert, animated: true, completion: nil)
    }
    
    /// Finds objects *asynchronously* and calls *saveIntoRealm*.
    private static func getRecords(view:UIViewController){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("LabInCloud", forKey: "SyncType")
        userDefaults.setValue("CloudStorage", forKey: "SyncImage")
        userDefaults.synchronize()
        let sync = view as! SyncVC
        sync.setSync()
        
        let query = PFQuery(className:"Paciente")
        query.whereKey("userID", equalTo: PFUser.currentUser()!.objectId!) //pyxS81NpAc
//        query.whereKey("userID", equalTo: "pyxS81NpAc") //pyxS81NpAc
        query.orderByAscending("nome")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    saveIntoRealm(objects, view: view)
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    ///Save PFObjects as Record object and *Asynchronously* gets the data from cache if available or fetches its contents from the network.
    private static func saveIntoRealm(objects: [PFObject]?, view:UIViewController) {
        
        let realm = try! Realm()
        
        for object in objects! {
            let create_at = object.createdAt!
            let update_at = object.updatedAt!
            let recordID = NSUUID().UUIDString

            realm.beginWrite()
            
            let patientID = Helpers.generateUUID()

            let patient = Patient()
            patient.id = patientID
            patient.name = object.objectForKey("nome") as! String
            patient.sex = object.objectForKey("sexo") as! String
            patient.ethnic = object.objectForKey("etnia") as! String
            patient.date_of_birth = Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).dateFromString(object.objectForKey("data_nascimento") as! String)!
            patient.phone = object.objectForKey("telefone") as? String
            patient.create_at = create_at
            patient.update_at = update_at
            var note:String = String()
            if object.objectForKey("notas") as? String != nil {
                note = object.objectForKey("notas") as! String
            }
            
            var imagesArray:[Image] = [Image]()
            
            if let img_frontal = object.objectForKey("img_frontal") as? PFFile{
                let front = Image()
                let frontID = Helpers.generateUUID()
                front.id = frontID
                front.recordID = recordID
                front.imageRef = 0.toString()
                front.imageType = "\(ImageTypes.Front.hashValue)"
                front.name = "[0]Front-\(recordID)"
                imagesArray.append(front)
                
                img_frontal.getDataInBackgroundWithBlock({ (imgData, error) in
                    
                    if error == nil {
                        RealmParse.saveFile(fileName: "[0]Front-\(recordID)", fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: imgData!)!)
                    }
                })
            }
            
            if let img_perfil = object.objectForKey("img_perfil") as? PFFile{
                let profileRight = Image()
                let profileID = Helpers.generateUUID()
                profileRight.id = profileID
                profileRight.recordID = recordID
                profileRight.imageRef = 0.toString()
                profileRight.imageType = "\(ImageTypes.ProfileRight.hashValue)"
                profileRight.name = "[0]ProfileRight-\(recordID)"
                imagesArray.append(profileRight)

                img_perfil.getDataInBackgroundWithBlock({ (imgData, error) in
                    
                    if error == nil {
                        RealmParse.saveFile(fileName: "[0]ProfileRight-\(recordID)", fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: imgData!)!)
                    }
                })
            }
        
            if let img_nasal = object.objectForKey("img_nasal") as? PFFile{
                let nasal = Image()
                let nasalID = Helpers.generateUUID()
                nasal.id = nasalID
                nasal.recordID = recordID
                nasal.imageRef = 0.toString()
                nasal.imageType = "\(ImageTypes.Nasal.hashValue)"
                nasal.name = "[0]Nasal-\(recordID)"
                imagesArray.append(nasal)

                img_nasal.getDataInBackgroundWithBlock({ (imgData, error) in
                    
                    if error == nil {
                        RealmParse.saveFile(fileName: "[0]Nasal-\(recordID)", fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: imgData!)!)
                    }
                })
                
            }
            
            if let dic_plano_cirurgico = object.objectForKey("dic_plano_cirurgico") as? PFFile{
                
                dic_plano_cirurgico.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        let dados = NSKeyedUnarchiver.unarchiveObjectWithData(data!)! as! [String:AnyObject]
                        let preSugicalPlaningForm = Helpers.convertAnyObjectToAny(dados)
                        let preSugicalPlaning = RealmParse.surgicalPlanning(false, id: recordID, surgicalPlanning: preSugicalPlaningForm)
                        try! realm.write {
                            realm.create(Record.self, value: ["id": recordID, "surgicalPlanning": [preSugicalPlaning]], update: true)
                        }
                    }
                    
                })
            }
            
            let compareImage = CompareImage()
            compareImage.reference = 0.toString()
            compareImage.recordID = patientID
            let image = imagesArray.sort({ $0.create_at < $1.create_at }).first
            compareImage.date = image!.create_at
            for image in imagesArray {
                compareImage.image.append(image)
            }
            
            let record = Record(value: ["id": recordID, "surgeryDescription" : "", "patient": patient,"compareImage": [compareImage], "surgeryRealized": false, "note" : note, "create_at": create_at, "update_at": update_at, "cloudState": "Ok" ])
            
            realm.create(Record.self, value: record, update: true)
            
            realm.create(Patient.self, value: ["id": patientID, "records": [record]], update: true)
            try! realm.commitWrite()
        }
        view.presentViewController(UIAlertController.alertControllerWithTitle("Atenção", message: "Os seus dados contidos no servidor estão salvos, mas as imagens das cirurgias e dados dos planos cirurgicos irão aparecer assim que o download for concluído.\r Obs: alguns dados dos planos cirurgicos de alguns pacientes podem não aparecer devido a mudanças na infraestrutura da aplicação."), animated: true, completion: nil)
        

    }
}
