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

class LabInCloudVC:NSObject{
    
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
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
        
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
            realm.beginWrite()

            let id = NSUUID().UUIDString
            
            let patient = Patient()
            
            patient.name = object.objectForKey("nome") as! String
            patient.sex = object.objectForKey("sexo") as! String
            patient.ethnic = object.objectForKey("etnia") as! String
            patient.date_of_birth = Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).dateFromString(object.objectForKey("data_nascimento") as! String)!
            patient.phone = object.objectForKey("telefone") as? String
            
            var note:String = String()
            if object.objectForKey("notas") as? String != nil {
                note = object.objectForKey("notas") as! String
            }
            
            let create_at = object.createdAt!
            let update_at = object.updatedAt!
            
            var imagesArray:[Image] = [Image]()
            
            if let img_frontal = object.objectForKey("img_frontal") as? PFFile{
                let front = Image()
                front.patientId = id
                front.imageType = "\(ImageTypes.Front.hashValue)"
                front.name = "Front-\(id)"
                imagesArray.append(front)
                
                img_frontal.getDataInBackgroundWithBlock({ (imgData, error) in
                    
                    if error == nil {
                        RealmParse.saveFile(fileName: "Front-\(id)", fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: imgData!)!)
                    }
                })
            }
            
            if let img_perfil = object.objectForKey("img_perfil") as? PFFile{
                let profileRight = Image()
                profileRight.patientId = id
                profileRight.imageType = "\(ImageTypes.ProfileRight.hashValue)"
                profileRight.name = "ProfileRight-\(id)"
                imagesArray.append(profileRight)

                img_perfil.getDataInBackgroundWithBlock({ (imgData, error) in
                    
                    if error == nil {
                        RealmParse.saveFile(fileName: "ProfileRight-\(id)", fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: imgData!)!)
                    }
                })
            }
            
            if let img_nasal = object.objectForKey("img_nasal") as? PFFile{
                let nasal = Image()
                nasal.patientId = id
                nasal.imageType = "\(ImageTypes.Nasal.hashValue)"
                nasal.name = "Nasal-\(id)"
                imagesArray.append(nasal)

                img_nasal.getDataInBackgroundWithBlock({ (imgData, error) in
                    
                    if error == nil {
                        RealmParse.saveFile(fileName: "Nasal-\(id)", fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: imgData!)!)
                    }
                })
            }
            
            realm.create(Record.self, value: ["id": id, "surgeryDescription" : "", "patient": patient,"image": imagesArray, "surgeryRealized": false, "note" : note, "create_at": create_at, "update_at": update_at ], update: true)

            try! realm.commitWrite()
        }
        view.presentViewController(UIAlertController.alertControllerWithTitle("Atenção", message: "Os seus dados contidos no servidor estão salvos, *mas as imagens das cirurgias irão aparecer assim que o download for concluído*."), animated: true, completion: nil)
        

    }
}
