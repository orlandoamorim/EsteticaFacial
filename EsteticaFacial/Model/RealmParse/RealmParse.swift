//
//  File.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyDropbox

/// It offers a set necessary functions to manage the model
class RealmParse {

    // ----------------------------------- Saving and Updating Surgery and Patient
    // MARK: - Saving and Updating Surgery and Patient
    
    static let cloud = RealmCloud.self
    
    ///Used to add and update SurgeryRecord
    static func auSurgery(id id: String?=NSUUID().UUIDString,record: Record?=nil, patient: Patient?=nil, formValues:[String : Any?],preSugicalPlaningForm:[String : Any?] ,postSugicalPlaningForm:[String : Any?],compareImages: [CompareImage], cloudGet: Bool = false){
        
        let realm = try! Realm()
        let formValues = RealmParse.convertAnyToAnyObject(formValues)
        print("************* Patient Data **************")
        let patient = RealmParse.patient(formValues, uPatient: record?.patient == nil ? patient : record?.patient)
        print("********* Pre Surgical Planning *********")
        let preSugicalPlaning = RealmParse.surgicalPlanning(false, id: id!, surgicalPlanning: preSugicalPlaningForm)
        print("********* Post Surgical Planning ********")
        let postSugicalPlaning = RealmParse.surgicalPlanning(true, id: id!, surgicalPlanning: postSugicalPlaningForm)
        print("***************** Record ****************")
        let recordAU = Record()
        recordAU.id = id!
        recordAU.patient = patient
        
        if record != nil {
            recordAU.create_at = record!.create_at
            if cloudGet {
                recordAU.note = record!.note
                recordAU.date_of_surgery = record!.date_of_surgery
                recordAU.surgeryDescription = record!.surgeryDescription
                recordAU.surgeryRealized =  record!.surgeryRealized
                recordAU.update_at = record!.update_at
                recordAU.cloudState = CloudState.Ok.rawValue
            }else {
                recordAU.note = formValues["note"] as? String
                recordAU.date_of_surgery = formValues["date_of_surgery"] as? NSDate
                recordAU.surgeryDescription = formValues["surgeryDescription"] as! String
                recordAU.surgeryRealized =  formValues["surgeryRealized"] as! Bool
                recordAU.cloudState = CloudState.Update.rawValue
            }
        }else {
            recordAU.note = formValues["note"] as? String
            recordAU.date_of_surgery = formValues["date_of_surgery"] as? NSDate
            recordAU.surgeryDescription = formValues["surgeryDescription"] as! String
            recordAU.surgeryRealized = formValues["surgeryRealized"] as! Bool
            recordAU.cloudState = CloudState.Add.rawValue
        }

        try! realm.write {
            for compareImage in compareImages {
                recordAU.compareImage.append(compareImage)
            }
            recordAU.surgicalPlanning.append(preSugicalPlaning)
            recordAU.surgicalPlanning.append(postSugicalPlaning)
            if patient.records.count > 0 {
                var boo:Bool = false
                for record in patient.records{
                    if record.id == recordAU.id {
                        boo = true
                    }
                }
                if boo == false {
                    patient.records.append(recordAU)
                }
            }else{
                patient.records.append(recordAU)
            }

            realm.add(recordAU, update: true)
        }

        
    }
    
    ///Used to add and update Patient
    static func auPatient(patient: Patient?=nil, formValues:[String : Any?]){
        let formValues = RealmParse.convertAnyToAnyObject(formValues)
        let patient = RealmParse.patient(formValues, uPatient: patient != nil ? patient : nil)
        
        let realm = try! Realm()

        try! realm.write {
            if RealmParse.cloud.isLogIn() != .LogOut {
                for record in patient.records {
                    record.cloudState = CloudState.Update.rawValue
                }
            }
            
            realm.add(patient, update: true)
            
        }
    }
    
    // ----------------------------------- Mounting an Object
    // MARK: - Mounting an Object
    
    /// Returns an Patient Object
    private static func patient(patient: [String:AnyObject], uPatient:Patient?=nil) -> Patient {
        let patientA = Patient()
        if !patient.keys.contains("name") && !patient.keys.contains("sex") {
            return uPatient!
        }else if uPatient != nil {
            patientA.id = uPatient!.id
            patientA.create_at = uPatient!.create_at
            patientA.update_at = !pacientEqual(patient, isEqual: uPatient!) ? NSDate() : uPatient!.update_at
            for record in uPatient!.records {
                patientA.records.append(record)
            }
        }
        patientA.name = patient["name"] as! String
        patientA.sex = patient["sex"] as! String
        patientA.ethnic = patient["ethnic"] as! String
        patientA.date_of_birth = patient["date_of_birth"] as! NSDate
        patientA.mail = patient["mail"] as? String
        patientA.phone = patient["phone"] as? String

        
        return patientA
    }
    
    ///Verify if to Patient Objectes are equals
    private static func pacientEqual(patient: [String:AnyObject], isEqual uPatient:Patient) -> Bool {
        
        if uPatient.name == patient["name"] as! String && uPatient.sex == patient["sex"] as! String && uPatient.ethnic == patient["ethnic"] as! String && uPatient.date_of_birth == patient["date_of_birth"] as! NSDate && uPatient.mail == patient["mail"] as? String && uPatient.phone == patient["phone"] as? String {
            return true
        }
        
        return false
    }
    
    /// Used to create an SurgicalPlanning Object
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
    
    /// Returns an Image Object from an List<CompareImage> using reference and imageTypeHashValue to compare
    static func imageObject(reference: Int, compareImages: List<CompareImage>?, imageTypeHashValue: Int) -> Image?{
        if compareImages != nil {
            for compareImage in compareImages! {
                for image in compareImage.image {
                    print(image.imageType)
                    print("\(imageTypeHashValue)")
                    print(image.name)
                    if image.imageType == "\(imageTypeHashValue)"{
                        return image
                    }
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
     - Parameter    uImage: Image?=nil
     
     - Returns: **Image**
     
     */
    
    static func image(recordID:String,compareImageID: String, imageRef: Int, imageType: Int, fileName: String, image: UIImage?, points: [String : NSValue]?, uImage:Image?=nil) -> Image{
        
        let img = Image()
        img.recordID = recordID
        img.imageRef = "\(imageRef)"
        img.imageType = "\(imageType)"
        img.name = fileName
        img.compareImageID = compareImageID
        //If already exists an Image() object.
        if uImage != nil {
            img.id = uImage!.id
            img.create_at = uImage!.create_at
            img.cloudState = uImage!.cloudState
            img.update_at = NSDate()
        }
        //If image is not nil(image is change), add image im directory.
        if image != nil {
            if uImage != nil {
                getFile(fileName: uImage!.name, fileExtension: .JPG, completionHandler: { (object, error) in
                    if error != nil {
                        print(error!)
                    }else {
                        if image!.isEqualToImage(object as! UIImage) {
                            img.cloudState = CloudState.Ok.rawValue
                            if uImage != nil {
                                img.update_at = uImage!.update_at
                            }

                        }else {
                            RealmParse.saveFile(fileName: fileName, fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: image!)
                            img.update_at = NSDate()
                            img.cloudState = CloudState.Update.rawValue
                        }
                    }
                })
            }else {
                RealmParse.saveFile(fileName: fileName, fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: image!)
                img.cloudState = CloudState.Add.rawValue
            }
        }
        img.points = points != nil ? NSKeyedArchiver.archivedDataWithRootObject(points!) : nil
        
        return img
    }
    
    // ----------------------------------- Queries
    // MARK: - Queries
    
    /**
     Return all Surgery objects in Record.
     */
    static func querySurgeries(predicate: NSPredicate?=nil) -> [String : [Record]]{
        var recordsHeader: [String] = [String]()
        var recordsDicAtoZ:[String : [Record]] = [String : [Record]]()
        
        let realm = try! Realm()
        
        let records = predicate != nil ? realm.objects(Record.self).filter(predicate!) : realm.objects(Record.self).sorted("surgeryDescription")
        
        for record in records {
            let name = record.surgeryDescription != "" ? record.surgeryDescription : record.patient?.name
            if name == nil {
                break
            }
            let char = name!.uppercaseString[name!.uppercaseString.startIndex]
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
    static func queryPatients(predicate: NSPredicate?=nil) -> [String : [Patient]]{
        var recordsHeader: [String] = [String]()
        var recordsDicAtoZ:[String : [Patient]] = [String : [Patient]]()
        
        let realm = try! Realm()
        
        let records = predicate != nil ? realm.objects(Patient.self).filter(predicate!) : realm.objects(Patient.self)
        
        for record in records {
            
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
    static func queryPatientSurgeries(patient: Patient,with predicate: NSPredicate?=nil) -> [String : [Record]]{
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
    
    // ----------------------------------- Trash
    // MARK: - Deleting Objects

    /**
     Delete an object Record with a transaction.
     
     - Parameter record: Record
     
     */
    
    static func deleteRecord(record record: Record){
        self.deleteRecordCompareImages(record)
        self.deleteSurgicalPlanning(record)
        let realm = try! Realm()
        try! realm.write {
            realm.delete(record)
            
        }
    }
    
    /**
     Delete an object Patient with a transaction.
     - Parameter patient: Patient
     
     */
    
    static func deletePatient(patient patient: Patient){
        
        if RealmParse.cloud.isLogIn() != .LogOut {
            let realm = try! Realm()
            try! realm.write {
                for record in patient.records {
                    record.cloudState = CloudState.Delete.rawValue
                }
                realm.delete(patient)
            }
        }else {
            for record in patient.records {
                deleteRecord(record: record)
            }
            let realm = try! Realm()
            try! realm.write {
                realm.delete(patient)
            }
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
    
    ///Delete CompareImage Object inside Record Object
    private static func deleteRecordCompareImages(record: Record) {
        for compareImage in record.compareImage {
            for image in compareImage.image {
                deleteImage(image)
            }
            RealmParse.deleteCompareImageObject(compareImage)
        }
    }
    
    /**
     Delete an object Image with a transaction.
     
     - Parameter record: Image
     
     */
    
    static func deleteCompareImageObject(compareImage: CompareImage){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(compareImage)
        }
    }
    
    /**
     Delete an object Image and image file with a transaction.
     
     - Parameter record: Image
     
     */
    static func deleteImage(image: Image){
        deleteImageFile(image)
        let realm = try! Realm()
        try! realm.write {
            realm.delete(image)
        }
    }
    
    ///Delete an Image Object
    private static func deleteImageFile(image: Image){
        RealmParse.deleteFile(fileName: image.name, fileExtension: .JPG)
        
    }
    
    ///Delete an SurgicalPlanning from an Record Object
    static func deleteSurgicalPlanning(record: Record){
        let realm = try! Realm()

        realm.beginWrite()
        for surgicalPlanning in record.surgicalPlanning {
            for surgicalPlanningKey in surgicalPlanning.surgicalPlanningForm {
                realm.delete(surgicalPlanningKey.value)
            }
            realm.delete(surgicalPlanning.surgicalPlanningForm)
        }
        realm.delete(record.surgicalPlanning)
        try! realm.commitWrite()
    }
    
    // ----------------------------------- Conversions
    // MARK: - Conversions
    
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
     Convert an dictionary [String:Any?]  to NSMutableDictionary.
     
     - Parameter anyDict: [String: Any?]
     
     - Returns:  **[String: String]**
     
     */
    
    static func convertAnytoNSMutableDictionary(anyDict:[String: Any?]) -> NSMutableDictionary {
        
        let stringDict:NSMutableDictionary = NSMutableDictionary()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                stringDict.setValue(string, forKey: key)
            }else if let bool = anyDict[key]! as? Bool {
                stringDict.setValue(bool, forKey: key)
            }else if let data = anyDict[key]! as? NSDate {
                stringDict.setValue(String(data), forKey: key)
            }else if let stringArray = anyDict[key]! as? [String]{
                stringDict.setValue(stringArray, forKey: key)
            }else if let arrayStrings = anyDict[key]! as? Set<String> {
                stringDict.setValue(getArrayFromSet(arrayStrings), forKey: key)

//                stringDict[key] = String(getArrayFromSet(arrayStrings))
            }
        }
        return stringDict
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
                print(surgicalPlanningKey.key)
                if surgicalPlanningKey.key == "outros_ossos" ||
                    surgicalPlanningKey.key == "outros_enxertos_de_ponta" ||
                    surgicalPlanningKey.key == "outras_suturas" ||
                    surgicalPlanningKey.key == "abordagem_opcoes" ||
                    surgicalPlanningKey.key == "miscelanea_outros" ||
                    surgicalPlanningKey.key == "outros_enxertos_autologos"{
                    
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
        formArray.updateValue(record.surgeryDescription, forKey: "surgeryDescription")
        formArray.updateValue(record.surgeryRealized, forKey: "surgeryRealized")
        formArray.updateValue(record.note, forKey: "note")
        if record.date_of_surgery != nil {
            formArray.updateValue(record.date_of_surgery, forKey: "date_of_surgery")
        }
        
        return formArray
    }
    
    // ----------------------------------- File Helpers
    
    ///Used to save file in NSSearchPathDirectory
    static func saveFile(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages", directory: NSSearchPathDirectory? = .DocumentDirectory, file:AnyObject){
        
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
    
    /// Returns an file saved in NSSearchPathDirectory
    static func getFile(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages", directory: NSSearchPathDirectory? = .DocumentDirectory, completionHandler: (object: AnyObject?, error: NSError?) -> Void) {
        
        let file = FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!)
        
        do {
            switch fileExtension {
            case .TXT: completionHandler(object:try file.getContentsOfFile(), error: nil)
            case .JPG: return completionHandler(object:try file.getImage(), error: nil)
            case .JSON:return completionHandler(object:try file.getJSONData(), error: nil)
            }
        } catch {
            completionHandler(object: nil, error: NSError(domain: "There was an error getting the file: \(error)", code: 100, userInfo: nil))
        }        
    }
    
    ///Delete an file saved in NSSearchPathDirectory
    static func deleteFile(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages", directory: NSSearchPathDirectory? = .DocumentDirectory) {
        
        let file = FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!)
        do {
            try file.deleteFile()
        }
        catch {
            print("There was an error deleting the file: \(error)")
        }
    }
    
    /// Verify if an file exists in NSSearchPathDirectory
    private static func fileExists(fileName fileName: String,fileExtension: FileSaveHelper.FileExtension , subDirectory: String?="FacialImages",
                                    directory: NSSearchPathDirectory? = .DocumentDirectory) -> Bool {
        return FileSaveHelper(fileName: fileName, fileExtension: fileExtension, subDirectory: subDirectory!, directory: directory!).fileExists
    }
    
    // ----------------------------------- Migrations
    // MARK: - Migrations
    
    static func migrateImageToCompareImage(){
        let realm = try! Realm()
        let records = realm.objects(Record)
        var images: [Image] = [Image]()
        for record in records {
            images.removeAll(keepCapacity: false)
            for image in record.image {
                images.append(image)
            }
            if !images.isEmpty {
                realm.beginWrite()
                let compareImage = CompareImage()
                compareImage.reference = 0.toString()
                compareImage.recordID = record.id
                let image = images.sort({ $0.create_at < $1.create_at }).first
                compareImage.date = image!.create_at
                for image in images {
                    image.recordID = record.id
                    compareImage.image.append(image)
                }
                
                
                realm.create(Record.self, value: ["id": record.id, "compareImage": [compareImage]], update: true)
                try! realm.commitWrite()
                
            }
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("Migration-0.2.3", forKey: "Migration-0.2.3")
        userDefaults.synchronize()
    }
}