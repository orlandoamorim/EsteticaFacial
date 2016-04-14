//
//  File.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift

class RealmParseHelper{
    
    static func au(record: Record?=nil, patient: Patient?=nil, formValues:[String : Any?],
                   preSugicalPlaningForm:[String : Any?] ,postSugicalPlaningForm:[String : Any?],
                   images:[ ImageTypes :(UIImage,[String:NSValue]?)]?=nil){
        
        let realm = try! Realm()
        var id = NSUUID().UUIDString
        
        if record != nil {
            id = record!.id
        }
        let formValues = RealmParseHelper.convertAnyToAnyObject(formValues)
        print("************* Patient Data **************")
        let patient = RealmParseHelper.patient(formValues, uPatient: record?.patient == nil ? patient : record?.patient)
        print("********* Pre Surgical Planning *********")
        let preSugicalPlaning = RealmParseHelper.surgicalPlanning(false, id: id, surgicalPlanning: preSugicalPlaningForm)
        print("********* Post Surgical Planning ********")
        let postSugicalPlaning = RealmParseHelper.surgicalPlanning(true, id: id, surgicalPlanning: postSugicalPlaningForm)
        print("**************** Images *****************")
        
        var imagesArray:[Image] = [Image]()
        
        for (imageType,(image, points)) in images! {
            
            switch imageType {
            case .Front:
                imagesArray.append(RealmParseHelper.image(id, imageType: imageType.hashValue, fileName: "Front-\(id)", image: image, points: points, uImage: imageObject(record?.image, imageTypeHashValue: imageType.hashValue)))
            case .ProfileRight:
                imagesArray.append(RealmParseHelper.image(id, imageType: imageType.hashValue, fileName: "ProfileRight-\(id)", image: image, points: points, uImage: imageObject(record?.image, imageTypeHashValue: imageType.hashValue)))
            case .Nasal:
                imagesArray.append(RealmParseHelper.image(id, imageType: imageType.hashValue, fileName: "Nasal-\(id)", image: image, points: points, uImage: imageObject(record?.image, imageTypeHashValue: imageType.hashValue)))
            case .ObliqueLeft:
                imagesArray.append(RealmParseHelper.image(id, imageType: imageType.hashValue, fileName: "ObliqueLeft-\(id)", image: image, points: points, uImage: imageObject(record?.image, imageTypeHashValue: imageType.hashValue)))
            case .ProfileLeft:
                imagesArray.append(RealmParseHelper.image(id, imageType: imageType.hashValue, fileName: "ProfileLeft-\(id)", image: image, points: points, uImage: imageObject(record?.image, imageTypeHashValue: imageType.hashValue)))
            case .ObliqueRight:
                imagesArray.append(RealmParseHelper.image(id, imageType: imageType.hashValue, fileName: "ObliqueRight-\(id)", image: image, points: points, uImage: imageObject(record?.image, imageTypeHashValue: imageType.hashValue)))
            }
        }
        
        
        print("***************** Record ****************")
        let recordAU = Record()
        recordAU.id = id
        recordAU.patient = patient
        for image in imagesArray {
            recordAU.image.append(image)
        }
        recordAU.surgeryRealized = formValues["surgeryRealized"] as! Bool
        recordAU.surgicalPlanning.append(preSugicalPlaning)
        recordAU.surgicalPlanning.append(postSugicalPlaning)
        recordAU.date_of_surgery = formValues["date_of_surgery"] as? NSDate
        recordAU.note = formValues["note"] as? String
        
        print("*****************************************")
        patient.records.append(recordAU)
        print("*****************************************")

        try! realm.write {
            realm.add(recordAU, update: true)
        }

    }

    
    
    static func patient(patient: [String:AnyObject], uPatient:Patient?=nil) -> Patient {
        let patientA = Patient()
        if uPatient != nil {
            patientA.id = uPatient!.id
            patientA.create_at = uPatient!.create_at
            patientA.update_at = NSDate()
        }
        
        patientA.name = patient["name"] as! String
        patientA.sex = patient["sex"] as! String
        patientA.ethnic = patient["ethnic"] as! String
        patientA.date_of_birth = patient["date_of_birth"] as! NSDate
        patientA.mail = patient["mail"] as? String
        patientA.phone = patient["phone"] as? String
        print(patientA)
        
        return patientA
    }
    
    static func surgicalPlanning(type:Bool,id:String,surgicalPlanning:[String : Any?]) -> SurgicalPlanning {
        let sugicalPlaning  = SurgicalPlanning()
        sugicalPlaning.id = id
        sugicalPlaning.type = type
        let spKeysPre = RealmParse.getSurgicalPlanningKeys(id: id, values: surgicalPlanning)
        for spKeyPre in spKeysPre {
            sugicalPlaning.surgicalPlanningForm.append(spKeyPre)
        }
        
        return sugicalPlaning
    }
    
    private static func imageObject(images: List<Image>?, imageTypeHashValue: Int) -> Image?{
        if images != nil {
            for image in images! {
                if image.imageType == "\(imageTypeHashValue)"{
                    return image
                }
            }
        }
        return nil
    }
    
    /**
     Return an Image Object. If pass image or poinsts nil the func recgnize this and don't save the value.
     
     - Parameter        id: String The pacient ID
     - Parameter imageType: Int
     - Parameter  fileName: String
     - Parameter     image: UIImage?
     - Parameter    points: [String : NSValue]?
     
     - Returns: **Image**
     
     */
    
    static func image(id:String, imageType: Int, fileName: String, image: UIImage?, points: [String : NSValue]?, uImage:Image?=nil) -> Image{
        
        let img = Image()
        img.patientId = id
        img.imageType = "\(imageType)"
        img.name = fileName
        //If already exists an Image() object.
        if uImage != nil {
            img.id = uImage!.id
            img.create_at = uImage!.create_at
            img.update_at = NSDate()
        }
        //If image is not nil(image is change), add image im directory.
        if image != nil {
            RealmParse.saveFile(fileName: fileName, fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: image!)
        }
        img.points = points != nil ? NSKeyedArchiver.archivedDataWithRootObject(points!) : nil
        
        print(img)
        
        return img
    }
    
    /**
     Return all Surgery objects in Record.
     */
    static func querySurgeries() -> [String : [Record]]{
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
     Return all Surgery objects in Record.
     */
    static func queryPatients() -> [String : [Patient]]{
        var recordsHeader: [String] = [String]()
        var recordsDicAtoZ:[String : [Patient]] = [String : [Patient]]()
        
        let realm = try! Realm()
        
        for record in realm.objects(Patient) {
            let name = record.name
            
            
            let char = name.lowercaseString[name.lowercaseString.startIndex]
            
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
                
                var records:[Patient] = [Patient]()
                records.append(record)
                recordsDicAtoZ.updateValue(records, forKey: String(char))
            }
        }
        return recordsDicAtoZ
        
    }

    
    /**
     Return all Surgery objects in an patient object passed.
     */
    static func queryPatientSurgeries(patient: Patient) -> [String : [Record]]{
        var recordsHeader: [String] = [String]()
        var recordsDicAtoZ:[String : [Record]] = [String : [Record]]()
        
        for record in patient.records {
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
        self.deleteRecordImages(record)
        self.deleteSurgicalPlanning(record)
        let realm = try! Realm()
        try! realm.write {
            realm.delete(record.image)
            realm.delete(record.surgicalPlanning)

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
     Delete an object Image with a transaction.
     
     - Parameter record: Image
     
     */
    
    static func deleteImage(image image: Image){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(image)
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
    
    
    
    static func saveFile(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages",
                                  directory: NSSearchPathDirectory? = .DocumentDirectory, file:AnyObject){
        
        let fileSave = FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!)
        
        do {
            switch fileExtension {
            case .TXT: try fileSave.saveFile(string: file as! String)
            case .JPG: try fileSave.saveFile(image: file as! UIImage)
            case .JSON: try fileSave.saveFile(dataForJson: file)
            }
            
            
        }
        catch {
            print("There was an error saving the file: \(error)")
        }
    }
    
    
    static func getFile(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages",
                                 directory: NSSearchPathDirectory? = .DocumentDirectory) -> AnyObject? {
        
        let file = FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!)
        
        do {
            switch fileExtension {
            case .TXT: return try file.getContentsOfFile()
            case .JPG: return try file.getImage()
            case .JSON:return try file.getJSONData()
            }
        }
        catch {
            print("There was an error getting the file: \(error)")
        }
        
        return nil
    }
    
    static func deleteFile(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages",
                                    directory: NSSearchPathDirectory? = .DocumentDirectory) {
        
        let file = FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!)
        print(file)
        do {
            try file.deleteFile()
        }
        catch {
            print("There was an error deleting the file: \(error)")
        }
    }
    
    static func fileExists(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages",
                                    directory: NSSearchPathDirectory? = .DocumentDirectory) -> Bool {
        
        return FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!).fileExists
    }
    
    private static func deleteRecordImages(record: Record){
        for image in record.image {
            RealmParseHelper.deleteFile(fileName: image.name, fileExtension: .JPG)
        }
    }
    
    private static func deleteSurgicalPlanning(record: Record){
        
        var keys:[SurgicalPlanningKey] = [SurgicalPlanningKey]()
        var values:[SurgicalPlanningValue] = [SurgicalPlanningValue]()
        
        for surgicalPlanning in record.surgicalPlanning {
            if surgicalPlanning.type ==  false {
                for surgicalPlanningKey in surgicalPlanning.surgicalPlanningForm {
                    keys.append(surgicalPlanningKey)
                    for value in surgicalPlanningKey.value {
                        values.append(value)
                    }
                }
            }else if surgicalPlanning.type ==  true {
                for surgicalPlanningKey in surgicalPlanning.surgicalPlanningForm {
                    keys.append(surgicalPlanningKey)
                    for value in surgicalPlanningKey.value {
                        values.append(value)
                    }
                }
            }
        }
        
        let realm = try! Realm()
        try! realm.write {
            for key in keys {
                realm.delete(key)
            }
            for value in values {
                realm.delete(value)
            }
        }

    }
}