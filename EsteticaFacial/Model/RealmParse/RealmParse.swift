//
//  File.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift

class RealmParse: NSObject{
    
    /**
     Add an object Record.
     
     - Parameter formValues:[String : Any?]
     - Parameter preSugicalPlaningForm:[String : Any?]
     - Parameter postSugicalPlaningForm:[String : Any?]
     - Parameter imagemPerfil:UIImage?=nil
     - Parameter imagemFrontal:UIImage?=nil
     - Parameter imagemNasal:UIImage?=nil
     - Parameter pontosFrontalAtual:[String:NSValue]?=nil
     - Parameter pontosPerfilAtual:[String:NSValue]?=nil
     - Parameter pontosNasalAtual:[String:NSValue]?=nil
     */
    
    static func add(formValues formValues:[String : Any?],
        preSugicalPlaningForm:[String : Any?] ,postSugicalPlaningForm:[String : Any?],
        images:[ImageTypes:(UIImage,[String:NSValue]?)]?=nil ){
        
        let id = NSUUID().UUIDString
        let formValues = RealmParse.convertAnyToAnyObject(formValues)
        
        print("************* Patient Data **************")
        let patient = Patient()
        patient.name = formValues["name"] as! String
        patient.sex = formValues["sex"] as! String
        patient.ethnic = formValues["ethnic"] as! String
        patient.date_of_birth = formValues["date_of_birth"] as! NSDate
        patient.mail = formValues["mail"] as? String
        patient.phone = formValues["phone"] as? String
        print("*****************************************")

        
        print("********* Pre Surgical Planning *********")
        
        let preSugicalPlaning  = SurgicalPlanning()
        preSugicalPlaning.id = id
        preSugicalPlaning.type = false
        let spKeysPre = RealmParse.getSurgicalPlanningKeys(id: id, values: preSugicalPlaningForm)
        for spKeyPre in spKeysPre {
            preSugicalPlaning.surgicalPlanningForm.append(spKeyPre)
        }
        print("*****************************************")

        print("********* Post Surgical Planning ********")
        
        let postSugicalPlaning  = SurgicalPlanning()
        postSugicalPlaning.id = id
        postSugicalPlaning.type = true
        let spKeysPost = RealmParse.getSurgicalPlanningKeys(id: id, values: postSugicalPlaningForm)
        for spKeyPost in spKeysPost {
            postSugicalPlaning.surgicalPlanningForm.append(spKeyPost)
        }
        print("*****************************************")
        
        print("**************** Images *****************")
        
        var imagesArray:[Image] = [Image]()
        
        for (imageType,(image, points)) in images! {
            let newImage = Image()
            
            switch imageType {
            case .Front:        newImage.patientId = id
                                newImage.imageType = "\(imageType.hashValue)"
                                let imagePath = RealmParse.fileInDocumentsDirectory("Front-\(id).png")
                                newImage.path = imagePath
                                saveImage(image, path: imagePath)
                                newImage.create_at = NSDate()
                                newImage.update_at = NSDate()
                                points != nil ? newImage.points = NSKeyedArchiver.archivedDataWithRootObject(points!) : print("Não")
                
                                imagesArray.append(newImage)
                
            case .ProfileRight: newImage.patientId = id
                                newImage.imageType = "\(imageType.hashValue)"
                                let imagePath = RealmParse.fileInDocumentsDirectory("ProfileRight-\(id).png")
                                newImage.path = imagePath
                                saveImage(image, path: imagePath)
                                newImage.create_at = NSDate()
                                newImage.update_at = NSDate()
                                points != nil ? newImage.points = NSKeyedArchiver.archivedDataWithRootObject(points!) : print("Não")
                
                                imagesArray.append(newImage)

                
            case .Nasal:        newImage.patientId = id
                                newImage.imageType = "\(imageType.hashValue)"
                                let imagePath = RealmParse.fileInDocumentsDirectory("Nasal-\(id).png")
                                newImage.path = imagePath
                                saveImage(image, path: imagePath)
                                newImage.create_at = NSDate()
                                newImage.update_at = NSDate()
                                points != nil ? newImage.points = NSKeyedArchiver.archivedDataWithRootObject(points!) : print("Não")
                
                                imagesArray.append(newImage)

                
            case .ObliqueLeft:  newImage.patientId = id
                                newImage.imageType = "\(imageType.hashValue)"
                                let imagePath = RealmParse.fileInDocumentsDirectory("ObliqueLeft-\(id).png")
                                newImage.path = imagePath
                                saveImage(image, path: imagePath)
            
                                newImage.create_at = NSDate()
                                newImage.update_at = NSDate()

                                imagesArray.append(newImage)
                
                
            case .ProfileLeft:  newImage.patientId = id
                                newImage.imageType = "\(imageType.hashValue)"
                                let imagePath = RealmParse.fileInDocumentsDirectory("ProfileLeft-\(id).png")
                                newImage.path = imagePath
                                saveImage(image, path: imagePath)
            
                                newImage.create_at = NSDate()
                                newImage.update_at = NSDate()
            
                                imagesArray.append(newImage)
                
                
            case .ObliqueRight: newImage.patientId = id
                                newImage.imageType = "\(imageType.hashValue)"
                                let imagePath = RealmParse.fileInDocumentsDirectory("ObliqueRight-\(id).png")
                                newImage.path = imagePath
                                saveImage(image, path: imagePath)
            
                                newImage.create_at = NSDate()
                                newImage.update_at = NSDate()
            
                                imagesArray.append(newImage)
                
                
            }
        }

        print("*****************************************")
        
        
        
        print("***************** Record ****************")
        let record = Record()
        record.id = id
        record.patient = patient
        for image in imagesArray {
            record.image.append(image)
        }
        print(formValues["surgeryRealized"] as! Bool)
        record.surgeryRealized = formValues["surgeryRealized"] as! Bool
        record.surgicalPlanning.append(preSugicalPlaning)
        record.surgicalPlanning.append(postSugicalPlaning)
        record.date_of_surgery = formValues["date_of_surgery"] as? NSDate
        record.note = formValues["note"] as? String

        print("*****************************************")
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(record)
        }
    }
    
    /**
     Update an object Record based on id.
     
     - Parameter record: Record
     - Parameter formValues:[String : Any?]
     - Parameter preSugicalPlaningForm:[String : Any?]
     - Parameter postSugicalPlaningForm:[String : Any?]
     - Parameter imagemPerfil:UIImage?=nil
     - Parameter imagemFrontal:UIImage?=nil
     - Parameter imagemNasal:UIImage?=nil
     - Parameter pontosFrontalAtual:[String:NSValue]?=nil
     - Parameter pontosPerfilAtual:[String:NSValue]?=nil
     - Parameter pontosNasalAtual:[String:NSValue]?=nil
     */
    
    static func update(record record: Record,formValues:[String : Any?],
        preSugicalPlaningForm:[String : Any?] ,postSugicalPlaningForm:[String : Any?],
        images:[ImageTypes:(UIImage?,[String:NSValue]?)]?=nil ){
            
            
            let formValues = RealmParse.convertAnyToAnyObject(formValues)
            
            print("************** Patient Data **************")
            let patient = Patient()
            patient.id = record.patient!.id
            patient.name = formValues["name"] as! String
            patient.sex = formValues["sex"] as! String
            patient.ethnic = formValues["ethnic"] as! String
            patient.date_of_birth = formValues["date_of_birth"] as! NSDate
            patient.mail = formValues["mail"] as? String
            patient.phone = formValues["phone"] as? String
            print("*****************************************")
            
            
            
            print("********* Pre Surgical Planning *********")
            
            let preSugicalPlaning  = SurgicalPlanning()
            preSugicalPlaning.id = record.id
            preSugicalPlaning.type = false
            let spKeysPre = RealmParse.getSurgicalPlanningKeys(id: record.id, values: preSugicalPlaningForm)
            for spKeyPre in spKeysPre {
                preSugicalPlaning.surgicalPlanningForm.append(spKeyPre)
            }
            print("*****************************************")
            
            print("********* Post Surgical Planning ********")
            
            let postSugicalPlaning  = SurgicalPlanning()
            postSugicalPlaning.id = record.id
            postSugicalPlaning.type = true
            let spKeysPost = RealmParse.getSurgicalPlanningKeys(id: record.id, values: postSugicalPlaningForm)
            for spKeyPost in spKeysPost {
                postSugicalPlaning.surgicalPlanningForm.append(spKeyPost)
            }
            print("*****************************************")
        
            print("**************** Images *****************")
            
            var imagesArray:[Image] = [Image]()
            
            for (imageType,(image, points)) in images! {
                let newImage = Image()
                
                switch imageType {
                case .Front:
                    newImage.patientId = record.id
                    newImage.imageType = "\(imageType.hashValue)"
                    if image != nil {
                        let imagePath = RealmParse.fileInDocumentsDirectory("Front-\(record.id).png")
                        newImage.path = imagePath
                        saveImage(image!, path: imagePath)
                        newImage.update_at = NSDate()
                    }
                    points != nil ? newImage.points = NSKeyedArchiver.archivedDataWithRootObject(points!) : print("Não")
                    
                    imagesArray.append(newImage)
                    
                case .ProfileRight:
                    newImage.patientId = record.id
                    newImage.imageType = "\(imageType.hashValue)"
                    if image != nil {
                        let imagePath = RealmParse.fileInDocumentsDirectory("ProfileRight-\(record.id).png")
                        newImage.path = imagePath
                        saveImage(image!, path: imagePath)
                        newImage.update_at = NSDate()
                    }
                    points != nil ? newImage.points = NSKeyedArchiver.archivedDataWithRootObject(points!) : print("Não")
                    
                    imagesArray.append(newImage)
                    
                    
                case .Nasal:
                    
                    newImage.patientId = record.id
                    newImage.imageType = "\(imageType.hashValue)"
                    if image != nil {
                        let imagePath = RealmParse.fileInDocumentsDirectory("Nasal-\(record.id).png")
                        newImage.path = imagePath
                        saveImage(image!, path: imagePath)
                        newImage.update_at = NSDate()
                    }
                    points != nil ? newImage.points = NSKeyedArchiver.archivedDataWithRootObject(points!) : print("Não")
                    
                    imagesArray.append(newImage)
                    
                case .ObliqueLeft:
                    newImage.patientId = record.id
                    newImage.imageType = "\(imageType.hashValue)"
                    if image != nil {
                        let imagePath = RealmParse.fileInDocumentsDirectory("ObliqueLeft-\(record.id).png")
                        newImage.path = imagePath
                        saveImage(image!, path: imagePath)
                        newImage.update_at = NSDate()
                    }
                    
                    imagesArray.append(newImage)
    
                    
                case .ProfileLeft:
                    newImage.patientId = record.id
                    newImage.imageType = "\(imageType.hashValue)"
                    if image != nil {
                        let imagePath = RealmParse.fileInDocumentsDirectory("ProfileLeft-\(record.id).png")
                        newImage.path = imagePath
                        saveImage(image!, path: imagePath)
                        newImage.update_at = NSDate()
                    }
                    
                    imagesArray.append(newImage)
                    
                    
                case .ObliqueRight:
                    newImage.patientId = record.id
                    newImage.imageType = "\(imageType.hashValue)"
                    if image != nil {
                        let imagePath = RealmParse.fileInDocumentsDirectory("ObliqueRight-\(record.id).png")
                        newImage.path = imagePath
                        saveImage(image!, path: imagePath)
                        newImage.update_at = NSDate()
                    }
                    imagesArray.append(newImage)
                    
                    
                }
            }
            
            print("*****************************************")
        
        
            let recordId = record.id
            print("***************** Record ****************")
            let record = Record()
            record.id = recordId
            record.patient = patient
            print(formValues["surgeryRealized"] as! Bool)
            record.surgeryRealized = formValues["surgeryRealized"] as! Bool
            record.surgicalPlanning.append(preSugicalPlaning)
            record.surgicalPlanning.append(postSugicalPlaning)
            for image in imagesArray {
                record.image.append(image)
            }
        
            record.date_of_surgery = formValues["date_of_surgery"] as? NSDate
            record.note = formValues["note"] as? String
        
            print("*****************************************")
        
            let realm = try! Realm()
        
            try! realm.write {
                realm.add(record, update: true)
            }
            print("************ Record Results *************")
            let recordsTeste = realm.objects(Record)
            print(recordsTeste[0].note)
            print(recordsTeste[0].date_of_surgery)
            print("*****************************************")
            
    }
    
    /**
     Return all objects in Record.
     */
    
    static func query() -> [String : [Record]]{
        var recordsHeader: [String] = [String]()
        var recordsDicAtoZ:[String : [Record]] = [String : [Record]]()
        
        let realm = try! Realm()
        
        for record in realm.objects(Record) {
            let name = record.patient?.name
            
            
            let char = name!.lowercaseString[name!.lowercaseString.startIndex]
            
            if recordsDicAtoZ[String(char)] != nil {
                if !recordsHeader.contains(String(char)) {
                    recordsHeader.append(String(char))
                }
                
                var fichas = recordsDicAtoZ[String(char)]!
                fichas.append(record)
                
                recordsDicAtoZ.updateValue(fichas, forKey: String(char))
            }else {
                if !recordsHeader.contains(String(char)) {
                    recordsHeader.append(String(char))
                }
                
                var records:[Record] = [Record]()
                records.append(record)
                recordsDicAtoZ.updateValue(records, forKey: String(char))
            }
        }
        return recordsDicAtoZ

    }
    
    /**
     Delete an object Record with a transaction.
     
     - Parameter record: Record
     
     */
    
    static func deleteRecord(record record: Record){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(record)
        }
    }
    
    /**
    Delete all objects from the realm.
    */
    
    static func deleteAllRecords(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    
    /**
     Convert an Set<>  to NSArray.
     
     - Parameter set:NSSet
     
     - Returns:  **NSArray**
     
     */
    
    static func getArrayFromSet(set:NSSet)-> NSArray {
        return set.map ({ String($0) })
    }
    
    /**
     Convert an dictionary [String:Any?]  to [String:AnyObject].

     - Parameter anyDict: [String: Any?]
     
     - Returns:  **[String: AnyObject]**
     
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
     Return an array of  SurgicalPlanningKey(like an SurgicalPlanningKey contructor).
     
     - Parameter id:String
     - Parameter values:[String : Any?]
     
     - Returns:  **[SurgicalPlanningKey]**
     
     */
    
    static func getSurgicalPlanningKeys(id id:String, values:[String : Any?]) -> [SurgicalPlanningKey] {
        var SurgicalPlanningKeyArray: [SurgicalPlanningKey] = [SurgicalPlanningKey]()
        
        for key in values.keys {
            let surgicalPlanningKey = SurgicalPlanningKey()
            surgicalPlanningKey.id = id
            surgicalPlanningKey.key = key
            if let string = values[key]! as? String {
                let surgicalPlanningValue = SurgicalPlanningValue()
                surgicalPlanningValue.valueString = string
                surgicalPlanningKey.value.append(surgicalPlanningValue)
            }else if let bool = values[key]! as? Bool {
                let surgicalPlanningValue = SurgicalPlanningValue()
                surgicalPlanningValue.valueBool.value = bool
                surgicalPlanningKey.value.append(surgicalPlanningValue)
            }else if let date = values[key]! as? NSDate {
                let surgicalPlanningValue = SurgicalPlanningValue()
                surgicalPlanningValue.valueDate = date
                surgicalPlanningKey.value.append(surgicalPlanningValue)
            }else if let arrayStrings = values[key]! as? Set<String> {
                let values = getArrayFromSet(arrayStrings)
                for value in values {
                    let surgicalPlanningValue = SurgicalPlanningValue()
                    surgicalPlanningValue.valueString = value as? String
                    surgicalPlanningKey.value.append(surgicalPlanningValue)
                }
            }
            SurgicalPlanningKeyArray.append(surgicalPlanningKey)
        }
        return SurgicalPlanningKeyArray
    }
    
    /**
     Return an array of  [String : Any?] to be used in Surgical Planning Forms.
     
     - Parameter surgicalPlanning: SurgicalPlanning

     - Returns:  **[String : Any?]**
     
     */
    
    static func convertRealmSurgicalPlanningForm(surgicalPlanning: SurgicalPlanning) -> [String : Any?] {
        var formArray: [String : Any?] = [String : Any?]()
        
        for surgicalPlanningKey in surgicalPlanning.surgicalPlanningForm {
            var valuesArray:[AnyObject] = [AnyObject]()
            var type:String = String()
            for value in surgicalPlanningKey.value {
                if value.valueBool.value != nil {
                    type = "Bool"
                    valuesArray.append(value.valueBool.value!)
                }else if value.valueString != nil {
                    type = "String"
                    valuesArray.append(value.valueString!)
                }else if value.valueDate != nil {
                    type = "Date"
                    valuesArray.append(value.valueDate!)
                }
            }
            
            if type == "String" {
                if surgicalPlanningKey.key == "outros_ossos" ||
                    surgicalPlanningKey.key == "outros_enxertos_de_ponta" ||
                    surgicalPlanningKey.key == "outras_suturas" ||
                    surgicalPlanningKey.key == "abordagem_opcoes"{
                        
                        formArray.updateValue(valuesArray[0] as! String, forKey: surgicalPlanningKey.key)
                        
                }else{
                    
                    var arrayString:[String] = [String]()
                    arrayString = valuesArray as! [String]
                    let set: NSSet = NSSet(array: arrayString)
                    formArray.updateValue(set as! Set<String>, forKey: surgicalPlanningKey.key )
                }
                
            }else if type == "Bool"{
                formArray.updateValue(valuesArray[0] as Any?, forKey: surgicalPlanningKey.key)
            }else if type == "Date"{
                formArray.updateValue(valuesArray[0] as Any?, forKey: surgicalPlanningKey.key)
            }
            
        }
        return formArray
    }
    
    /**
     Convert an  Patient in array [String : Any?].
     
     - Parameter patient: Patient
     
     - Returns:  **[String : Any?]**
     
     */
    
    static func convertRealmPatientForm(patient: Patient) -> [String : Any?] {
        var formArray: [String : Any?] = [String : Any?]()
        
        formArray.updateValue(patient.name, forKey: "name")
        formArray.updateValue(patient.sex, forKey: "sex")
        formArray.updateValue(patient.ethnic, forKey: "ethnic")
        formArray.updateValue(patient.date_of_birth, forKey: "date_of_birth")
        formArray.updateValue(patient.mail, forKey: "mail")
        formArray.updateValue(patient.phone, forKey: "phone")
        
        return formArray
    }
    
    /**
     Convert an  Record in array [String : Any?].
     
     - Parameter record: Record
     
     - Returns:  **[String : Any?]**.
     
     */
    
    static func convertRealmRecordForm(record: Record) -> [String : Any?] {
        var formArray: [String : Any?] = [String : Any?]()

        formArray = convertRealmPatientForm(record.patient!)
        formArray.updateValue(record.surgeryRealized, forKey: "surgeryRealized")
        formArray.updateValue(record.note, forKey: "note")
        if record.date_of_surgery != nil {
            formArray.updateValue(record.date_of_surgery, forKey: "date_of_surgery")
        }
        
        return formArray
    }
    
    /**
     Return an String that contains the diretory so save file.
     
     - Parameter filename: String
     
     - Returns:  Return **String** loaded from path.
     
     */
    
    static func fileInDocumentsDirectory(filename: String) -> String {
        
        let documentDirectoryURL =  try! NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let newDir = documentDirectoryURL.URLByAppendingPathComponent("LabInC")
        
        if !NSFileManager().fileExistsAtPath(newDir.path!){
            try! NSFileManager.defaultManager().createDirectoryAtURL(newDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileURL = documentDirectoryURL.URLByAppendingPathComponent(filename)
        
        return fileURL.path!
        
    }
    
    
    /**
     Save image in the path.
     
     - Parameter image: UIImage
     - Parameter path: String
     
     - Returns:  Return **Bool** to indicate if image was saved or not.
     
     */
    
    static func saveImage (image: UIImage, path: String ) -> Bool{
        
        let pngImageData = UIImagePNGRepresentation(image)
        let result = pngImageData!.writeToFile(path, atomically: true)
        
        return result
        
    }
    
    /**
     Remove image in the path. Addictionaly, if pass record, remove image from Recod file.
     
     - Parameter path: String
     - Parameter record: Record? Default nil
     
     - Returns:  Return **Bool** to indicate if image was removed or not.
     
     */
    
    
    static func removeImage (path: String, record: Record?=nil) -> Bool {
        let gerenciador = NSFileManager()
        
        if gerenciador.fileExistsAtPath(path){
            do {
                try gerenciador.removeItemAtPath(path)

                if record != nil {
                    let realm = try! Realm()
                    for image in record!.image{
                        if image.path == path {
                            try! realm.write {
                                realm.delete(image)
                            }
                        }
                    }
                }
            
                return true
            } catch _ {
                return false
            }

        }
        
        
        
        return false
    }
    
    /**
     Verify if exist image(can be any file) in the path.
     
     - Parameter path: String
     
     - Returns:  Return **Bool** to indicate if exist image in path or not.
     
     */
    
    static func existImageFromPath(path:String) -> Bool{
        let gerenciador = NSFileManager()
        if gerenciador.fileExistsAtPath(path){
            return true
        }
        
        return false
    }
    
    /**
    Load image from path send.
     
     - Parameter path: String
     
     - Returns:  Return **UIImage?** loaded from path. If not exist image in path send, return nil.
     
     */
    
    
    static func loadImageFromPath(path: String) -> UIImage? {
        let gerenciador = NSFileManager()
        var imageFounded:UIImage = UIImage()
        if gerenciador.fileExistsAtPath(path){
            
            if let image = UIImage(contentsOfFile: path) {
                imageFounded = image
            }else{
                print("missing image at: \(path)")
            }
        }else{
            return nil
        }
        
        return imageFounded
    }
}