//
//  RealmCloud.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 18/06/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import SwiftyDropbox
import RealmSwift

class RealmCloud: RealmParse {
    
    private enum RealmCloudErrors:ErrorType {
        case JsonNotSerialized
        case FileNotSaved
        case ImageNotConvertedToData
        case FileNotRead
        case FileNotFound
        case FileNotDeleted
    }

    static func sync(viewController: UIViewController?=nil) {
        if Dropbox.authorizedClient != nil {
            DropboxHelper.DropboxSync(viewController)
        }
    }
    
    static func isLogIn() -> CloudTypes {
        if Dropbox.authorizedClient != nil {
            return CloudTypes.Dropbox
        }
        return CloudTypes.LogOut
    }
    
    static func generateJson(record:Record) throws -> NSData {
        
        // ---- Patient
        let paciente: NSMutableDictionary = NSMutableDictionary()
        
        paciente.setValue(record.patient!.id, forKey: "id")
        paciente.setValue(record.patient!.name, forKey: "name")
        print(record.patient!.name)
        paciente.setValue(record.patient!.sex, forKey: "sex")
        paciente.setValue(record.patient!.ethnic, forKey: "ethnic")
        paciente.setValue(String(record.patient!.date_of_birth), forKey: "date_of_birth")
        paciente.setValue(String(record.patient!.create_at), forKey: "create_at")
        paciente.setValue(String(record.patient!.update_at), forKey: "update_at")
        
        if record.patient!.mail != nil {
            paciente.setValue(record.patient!.mail!, forKey: "mail")
        }
        if record.patient!.phone != nil {
            paciente.setValue(record.patient!.phone!, forKey: "phone")
        }
        
        // ---- Compare Image
        
        let compareImage: NSMutableArray = NSMutableArray()
        
        for compareImg in record.compareImage {
            let imgArry: NSMutableArray = NSMutableArray()
            
            for imgObject in compareImg.image {
                
                let image:NSMutableDictionary = NSMutableDictionary()
                
                image.setValue(imgObject.id, forKey: "id")
                image.setValue(imgObject.recordID, forKey: "recordID")
                image.setValue(imgObject.compareImageID, forKey: "compareImageID")
                image.setValue(imgObject.imageRef, forKey: "imageRef")
                image.setValue(imgObject.imageType, forKey: "imageType")
                image.setValue(imgObject.name, forKey: "name")
                image.setValue(String(imgObject.create_at), forKey: "create_at")
                image.setValue(String(imgObject.update_at), forKey: "update_at")
                
                var points: NSMutableDictionary = NSMutableDictionary()
                if imgObject.points != nil {
                    points = nsValuetoString(NSKeyedUnarchiver.unarchiveObjectWithData(imgObject.points!) as! [String : NSValue])
                    image.setValue(points, forKey: "points")
                }
                imgArry.addObject(image)
            }
            
            let comp:NSMutableDictionary = NSMutableDictionary()
            
            comp.setValue(compareImg.id, forKey: "id")
            comp.setValue(compareImg.recordID, forKey: "recordID")
            comp.setValue(compareImg.reference, forKey: "reference")
            comp.setValue(String(compareImg.date), forKey: "date")
            comp.setValue(imgArry, forKey: "image")
            comp.setValue(String(compareImg.create_at), forKey: "create_at")
            comp.setValue(String(compareImg.update_at), forKey: "update_at")
            compareImage.addObject(comp)
        }
        
        // ---- Surgical Planning
        let surgicalPlanning: NSMutableArray = NSMutableArray()
        for sp in record.surgicalPlanning {
            let surgPlanning:NSMutableDictionary = NSMutableDictionary()
            surgPlanning.setValue(sp.id, forKey: "id")
            surgPlanning.setValue(sp.type, forKey: "type")
            surgPlanning.setValue(convertAnyToAnyObject(convertRealmSurgicalPlanningForm(sp)), forKey: "surgicalPlanningForm")
            
            surgicalPlanning.addObject(surgPlanning)
        }
        
        //------ Making the dictionary with all values
        
        let dictionary:NSMutableDictionary = NSMutableDictionary()
        
        dictionary.setValue(String(record.id), forKey: "id")
        dictionary.setValue(record.surgeryDescription, forKey: "surgeryDescription")
        dictionary.setValue(paciente, forKey: "patient")
        if compareImage.count > 0 {
            dictionary.setValue(compareImage, forKey: "compareImage")
        }
        dictionary.setValue(record.surgeryRealized, forKey: "surgeryRealized")
        dictionary.setValue(surgicalPlanning, forKey: "surgicalPlanning")
        
        if record.date_of_surgery != nil {
            dictionary.setValue(String(record.date_of_surgery!), forKey: "date_of_surgery")
        }
        
        if record.note != nil {
            dictionary.setValue(record.note!, forKey: "note")
        }
        
        dictionary.setValue(String(record.create_at), forKey: "create_at")
        dictionary.setValue(String(record.update_at), forKey: "update_at")
        
        
        do {
            let newData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
            return newData
        }
        catch {
            print("Error writing data: \(error)")
        }
        
        throw RealmCloudErrors.JsonNotSerialized
    }
    
    private static func nsValuetoString(points: [String : NSValue]) -> NSMutableDictionary {
        let pointsString:NSMutableDictionary = NSMutableDictionary()
        for (key,value) in points {
            pointsString.setValue(key, forKey: String(value))
        }
        
        return pointsString
        
    }
    
    static func generateRecord(jsonData: NSData) -> (record:Record, pre:[String:Any?], post: [String: Any?], compareImage: [CompareImage]) {
        var decoded: NSMutableDictionary = NSMutableDictionary()
        do {
            decoded = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! NSMutableDictionary
        } catch let error as NSError {
            print(error)
        }
        let realm = try! Realm()

        let record = Record()
        let patient = Patient()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        //-------------------------------------------------------------------------
        print(decoded["patient"] as? NSMutableDictionary)
        let jsonPatient = decoded["patient"] as! NSMutableDictionary
        patient.id = jsonPatient["id"] as! String
        patient.name = jsonPatient["name"] as! String
        patient.sex = jsonPatient["sex"] as! String
        patient.ethnic = jsonPatient["ethnic"] as! String
        patient.date_of_birth = dateFormatter.dateFromString(jsonPatient["date_of_birth"] as! String)!
        patient.create_at = dateFormatter.dateFromString( jsonPatient["create_at"] as! String )!
        patient.update_at = dateFormatter.dateFromString( jsonPatient["update_at"] as! String )!
        
        if let mail = jsonPatient["mail"] as? String {
            patient.mail = mail
        }
        
        if let phone = jsonPatient["phone"] as? String {
            patient.phone = phone
        }
        //-------------------------------------------------------------------------
        for compareImageJson in decoded["compareImage"] as! NSMutableArray {
            if let ci = compareImageJson as? NSMutableDictionary {
                let compareImage = CompareImage()
                compareImage.id = ci["id"] as! String
                print(ci["recordID"])
                compareImage.recordID = ci["recordID"] as! String
                compareImage.reference = ci["reference"] as! String
                compareImage.date = dateFormatter.dateFromString(ci["date"] as! String)!
                if let imageArray = ci["image"] as? NSMutableArray {
                    for imgArry in imageArray {
                        if let img = imgArry as? NSMutableDictionary {
                            let image = Image()
                            image.id = img["id"] as! String
                            image.recordID = img["recordID"] as! String
                            image.compareImageID = img["compareImageID"] as! String
                            image.imageRef = img["imageRef"] as! String
                            image.imageType = img["imageType"] as! String
                            image.name = img["name"] as! String
                            image.create_at = dateFormatter.dateFromString(img["create_at"] as! String)!
                            image.update_at = dateFormatter.dateFromString(img["update_at"] as! String)!
                            if let points = img["points"] as? [String : NSValue] {
                                image.points = NSKeyedArchiver.archivedDataWithRootObject(points)
                            }
                            
                            let images = realm.objects(Image.self).filter("id == '\(img["id"] as! String)'")
                            
                            if images.count > 0 {
                                if images[0].update_at == image.update_at {
                                    print("Imagem OK")
                                }else {
                                    print("Imagem Atualizada")
                                    DropboxHelper.getImage("/Entries/\(image.recordID)/\(compareImage.id)/\(image.name)", name: image.name)
                                }
                            }else {
                                // MARK: - TO DO - Atualizar pra suportar todos os Clouds
                                DropboxHelper.getImage("/Entries/\(image.recordID)/\(compareImage.id)/\(image.name)", name: image.name)
                            }
                            
                            compareImage.image.append(image)
                        }
                    }
                }
                compareImage.create_at = dateFormatter.dateFromString(ci["create_at"] as! String)!
                compareImage.update_at = dateFormatter.dateFromString(ci["update_at"] as! String)!
                
                record.compareImage.append(compareImage)
            }
        }
        //-------------------------------------------------------------------------

        
        let surgicalPlanningDelete = realm.objects(Record.self).filter("id == '\(decoded["id"] as! String)'")
        for surgicalPlanning in  decoded["surgicalPlanning"] as! NSArray {
            if let sp = surgicalPlanning as? NSMutableDictionary {
                if surgicalPlanningDelete.count > 0 {
                    deleteSurgicalPlanning(surgicalPlanningDelete[0])
                }
                
                record.surgicalPlanning.append(RealmParse.surgicalPlanning(sp["type"] as! Bool, id: sp["id"] as! String, surgicalPlanning: Helpers.convertAnyObjectToAny(sp["surgicalPlanningForm"] as! [String : AnyObject])))
            }
        }
        
        record.id = decoded["id"] as! String
        record.surgeryDescription = decoded["surgeryDescription"] as! String
        record.patient = patient
        record.surgeryRealized = decoded["surgeryRealized"] as! Bool
        
        if let date_of_surgery = decoded["date_of_surgery"] as? String {
            record.date_of_surgery = dateFormatter.dateFromString(date_of_surgery)
        }
        
        if let note = decoded["note"] as? String {
            record.note = note
        }
        
        record.create_at = dateFormatter.dateFromString(decoded["create_at"] as! String)!
        record.update_at = dateFormatter.dateFromString(decoded["update_at"] as! String)!
        
        
        var preSugicalPlaning = SurgicalPlanning()
        var postSugicalPlaning = SurgicalPlanning()
        for sp in record.surgicalPlanning {
            if sp.type == false {
                preSugicalPlaning = sp
            }else if sp.type == true {
                postSugicalPlaning = sp
            }
        }
        
        var comparaImg: [CompareImage] = [CompareImage]()
        
        for ci in record.compareImage {
            comparaImg.append(ci)
        }
        
        return (record, convertRealmSurgicalPlanningForm(preSugicalPlaning), convertRealmSurgicalPlanningForm(postSugicalPlaning), comparaImg)
    }
    
    
    
    static func updateRecordsLogIn(completionHandler: (error: NSError?) -> Void){
        do {
            let realm = try Realm()
            let records = realm.objects(Record.self)
            
            try! realm.write {

                for record in records {
                    record.cloudState = CloudState.Update.rawValue
                    realm.add(record, update: true)
                }
                completionHandler(error: nil)
            }
        } catch let error as NSError {
            completionHandler(error: error)
        }

    }
    
    
    static func cloudLogOut(dismissCloudUpdated:Bool = false, completionHandler: (cloudUpdated:Bool?, error: NSError?) -> Void){
        let realm = try! Realm()
        let records = realm.objects(Record.self).filter("cloudState = 'Update'")
        let images = realm.objects(Image.self).filter("cloudState = 'Update'")
        
        let recordsDelete = realm.objects(Record.self).filter("cloudState = 'Delete'")
        let imagesDelete = realm.objects(Image.self).filter("cloudState = 'Delete'")
        
        print(records.count)
        print(images.count)
        if dismissCloudUpdated == false {
            if records.count != 0 || images.count != 0 || recordsDelete.count != 0 || imagesDelete.count != 0 {
                completionHandler(cloudUpdated: false, error:  nil)
            }else{
                completionHandler(cloudUpdated: true, error:  nil)
            }
        }else {
            try! realm.write {
                
                for record in records {
                    record.cloudState = CloudState.Ok.rawValue
                    realm.add(record, update: true)
                }
                for image in images {
                    image.cloudState = CloudState.Ok.rawValue
                    realm.add(image, update: true)
                }
                
                for recordDelete in recordsDelete {
                    RealmParse.deleteRecord(record: recordDelete)
                }
                
                for imageDelete in imagesDelete {
                    RealmParse.deleteImage(imageDelete)
                }
                
                completionHandler(cloudUpdated: true, error:  nil)
            }
        
        }
    }
    
}
