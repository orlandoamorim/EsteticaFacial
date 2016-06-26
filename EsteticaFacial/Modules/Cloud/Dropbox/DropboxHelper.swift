//
//  File.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 08/06/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import SwiftyDropbox
import RealmSwift

class DropboxHelper: RealmCloud {
    
    static var modificationsCount: Int = -1 {
        willSet {
            // Print current value.
            print("willSet")
            print(modificationsCount)
        }
        didSet {
            // Print both oldValue and present value.
            print("didSet")
            print(oldValue)
            print(modificationsCount)
            if modificationsCount == 0 {
                Helpers.backgroundThread(10, completion: { 
                    syncCloudRecords()
                })
            }
        }
    }
    
    //FUNCIONA
    static func folders(path: String = "", recursive: Bool = false, includeMediaInfo: Bool = false, includeDeleted: Bool = false, completionHandler: (cursor: String, names: [String]?, error:NSError?) -> Void)  {
        if let client = Dropbox.authorizedClient {
            // List folder
            client.files.listFolder(path: path, recursive: recursive, includeMediaInfo: includeMediaInfo, includeDeleted: includeDeleted).response { response, error in
                print("*** List folder ***")
                if let result = response {
                    print("Folder contents:")
                    var names = [String]()
                    for entry in result.entries {
                        if entry.name != "Entries" {
                            names.append(entry.name)
                        }
                    }
                    completionHandler(cursor: result.cursor, names: names, error: nil)
                } else {
                    completionHandler(cursor: "", names: nil, error: NSError(domain: "Tag not found", code: 100, userInfo: nil))
                }
            }
        }
    }

    static func revisions(path: String,limit: UInt64 = 10, completionHandler: (CloudRevisions: CloudRevisions?, error: NSError?) -> Void) {
        if let client = Dropbox.authorizedClient {
            client.files.listRevisions(path: path, limit: limit).response { response, error  in
                if let result = response {
                    completionHandler(CloudRevisions: CloudRevisions(isDeleted: result.isDeleted , entries: result.entries), error: nil)
                }else {
                    completionHandler(CloudRevisions: nil, error: NSError(domain: "Error \(error!)", code: 100, userInfo: nil ))
                }
            }
        }
    }
    

    //FUNCIONA
    static func deleteFile(path: String, completionHandler: (error: NSError?) -> Void) {
        if let client = Dropbox.authorizedClient {            
            client.files.delete(path: path).response { response, error in
                if let metadata = response {
                    completionHandler(error: nil)
                    print("*** Delete file ****")
                    print("Delete file name: \(metadata.name)")
                }else {
                    completionHandler(error: NSError(domain: "\(error!)", code: 100, userInfo: nil))
                }
            }
            
        }
    }
    //FUNCiONA
    static func uploadFile(path: String, data:NSData, completionHandler: (error: NSError?) -> Void) {
        if let client = Dropbox.authorizedClient {
            client.files.upload(path: path, mode: Files.WriteMode.Overwrite , body: data).response { response, error in
                if let metadata = response {
                    completionHandler(error: nil)
                    print("*** Upload file ****")
                    print("Uploaded file name: \(metadata.name)")
                    print("Uploaded file revision: \(metadata.rev)")
                }else {
                    completionHandler(error: NSError(domain: "\(error!)", code: 100, userInfo: nil))
                }
            }
        }
    }
    
    static func getFiles(path: String, completionHandler: (data:NSData?, error: NSError?) -> Void) {
        if let client = Dropbox.authorizedClient {
            let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                let fileManager = NSFileManager.defaultManager()
                let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                // generate a unique name for this file in case we've seen it before
                let UUID = NSUUID().UUIDString
                let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                return directoryURL.URLByAppendingPathComponent(pathComponent)
            }
            
            client.files.download(path: path, destination: destination).response { response, error in
                if let (metadata, url) = response {
                    print("*** Download file ***")
                    let data = NSData(contentsOfURL: url)
                    print("Downloaded file name: \(metadata.name)")
                    print("Downloaded file url: \(url)")
                    print("Downloaded file data: \(data)")
                    completionHandler(data: data, error: nil)
                    do {
                        // Delete the file
                        try NSFileManager.defaultManager().removeItemAtURL(url)
                    } catch _ as NSError {
                        // Do nothing with the error
                    }

                } else {
                    completionHandler(data: nil, error: NSError(domain: "Error Downloading", code: 100, userInfo: nil))
                }
            }
        }
    }
    
    static func getImage(path: String, name: String) {
        if let client = Dropbox.authorizedClient {
            let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                let fileManager = NSFileManager.defaultManager()
                let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                // generate a unique name for this file in case we've seen it before
                let UUID = NSUUID().UUIDString
                let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                return directoryURL.URLByAppendingPathComponent(pathComponent)
            }
            
            client.files.download(path: path, destination: destination).response { response, error in
                if let (metadata, url) = response {
                    print("*** Download file ***")
                    let data = NSData(contentsOfURL: url)
                    print("Downloaded file name: \(metadata.name)")
                    print("Downloaded file url: \(url)")
                    print("Downloaded file data: \(data)")
                    
                    RealmParse.saveFile(fileName: name, fileExtension: .JPG, subDirectory: "FacialImages", directory: .DocumentDirectory, file: UIImage(data: data!)!)
                    
                    do {
                        // Delete the file
                        try NSFileManager.defaultManager().removeItemAtURL(url)
                    } catch _ as NSError {
                        // Do nothing with the error
                    }
                    
                } else {
                    print(error!)
                }
            }
        }
    }
    
    static func DropboxSync(view: UIViewController?=nil){
        let realm = try! Realm()
        
        let recordAdd = realm.objects(Record.self).filter("cloudState = '\(CloudState.Add.rawValue)'")
        let recordUpdate = realm.objects(Record.self).filter("cloudState = '\(CloudState.Update.rawValue)'")
        let recordDelete = realm.objects(Record.self).filter("cloudState = '\(CloudState.Delete.rawValue)'")
        
        let compareImageDelete = realm.objects(CompareImage.self)
        
        print(recordAdd.count)
        print(recordUpdate.count)
        print(recordDelete.count)
        modificationsCount = recordAdd.count + recordUpdate.count + recordDelete.count

        for rAdd in recordAdd {
            
            do {
                let json = try generateJson(rAdd)
                
                uploadFile("/Entries/\(rAdd.id)/\(rAdd.id)", data: json, completionHandler: { (error) in
                    if error != nil {
                        print(error!)
                    }else {
                        try! realm.write {
                            rAdd.cloudState = CloudState.Ok.rawValue
                            let updateAt = rAdd.update_at
                            rAdd.update_at = updateAt
                            
                            realm.add(rAdd, update: true)
                            uploadImage(rAdd.compareImage)
                            modificationsCount = modificationsCount - 1
                        }
                    }
                })
            }catch {
                break
            }
        }

        for rUpdate in recordUpdate {
            do {
                let json = try generateJson(rUpdate)
                
                uploadFile("/Entries/\(rUpdate.id)/\(rUpdate.id)", data: json, completionHandler: { (error) in
                    if error != nil {
                        print(error!)
                        
                    }else {
                        try! realm.write {
                            rUpdate.cloudState = CloudState.Ok.rawValue
                            let updateAt = rUpdate.update_at
                            rUpdate.update_at = updateAt
                            
                            realm.add(rUpdate, update: true)
                            uploadImage(rUpdate.compareImage)
                            modificationsCount = modificationsCount - 1
                        }
                    }
                })
            }catch {
                break
            }
        }
        
        for rDelete in recordDelete {
            let path = "/Entries/\(rDelete.id)"
            deleteFile(path, completionHandler: { (error) in
                if error != nil {
                    print(error)
                    folders(path, completionHandler: { (cursor, names, error) in
                        if error != nil {
                            RealmParse.deleteRecord(record: rDelete)
                            modificationsCount = modificationsCount - 1
                        }
                    })
                }else {
                    RealmParse.deleteRecord(record: rDelete)
                    modificationsCount = modificationsCount - 1
                }
            })
        }
        
        for ci in compareImageDelete {
            for iDelete in ci.image.filter("cloudState = '\(CloudState.Delete.rawValue)'") {
                modificationsCount = modificationsCount + 1
                deleteFile("/Entries/\(iDelete.recordID)/\(ci.id)/\(iDelete.name)", completionHandler: { (error) in
                    if error != nil {
                        print(error!)
                    }else {
                        RealmParse.deleteImage(iDelete)
                        modificationsCount = modificationsCount - 1
                    }
                })
            }
        }
        
//        dispatch_async(dispatch_get_global_queue(0, 0)) { 
//            if modificationsCount > 0 && view != nil {
//                repeat{
//                    view?.navigationController?.navigationItem.titleView = Helpers.setTitle("Sync", subtitle: "Atualizando \(modificationsCount) registros")
//                    
//                }while modificationsCount > 0
//            }else if modificationsCount == 0 && view != nil  {
//                view?.navigationController?.navigationItem.titleView = nil
//            }
//        }
    }
    
    private static func uploadImage(compareImage: List<CompareImage>) {
        let realm = try! Realm()

        for compareImages in compareImage {
            for image in compareImages.image {
                //Upload Imges Add
                if image.cloudState == CloudState.Add.rawValue {
                    modificationsCount = modificationsCount + 1
                    RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            uploadFile("/Entries/\(image.recordID)/\(compareImages.id)/\(image.name)", data: UIImagePNGRepresentation(object as! UIImage)!, completionHandler: { (error) in
                                if error != nil {
                                    print(error!)
                                }else {
                                    try! realm.write {
                                        image.cloudState = CloudState.Ok.rawValue
                                        let updateAt = image.update_at
                                        image.update_at = updateAt
                                        
                                        realm.add(image, update: true)
                                        modificationsCount = modificationsCount - 1
                                    }
                                }
                            })
                        }
                    })
                //Upload Imges Update
                }else if image.cloudState == CloudState.Update.rawValue {
                    modificationsCount = modificationsCount + 1
                    RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            uploadFile("/Entries/\(image.recordID)/\(compareImages.id)/\(image.name)", data: UIImagePNGRepresentation(object as! UIImage)!, completionHandler: { (error) in
                                if error != nil {
                                    print(error!)
                                }else {
                                    try! realm.write {
                                        image.cloudState = CloudState.Ok.rawValue
                                        let updateAt = image.update_at
                                        image.update_at = updateAt
                                        
                                        realm.add(image, update: true)
                                        modificationsCount = modificationsCount - 1
                                    }
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    private static func syncCloudRecords(){
        let realm = try! Realm()
        
        let records = realm.objects(Record.self).filter("cloudState = '\(CloudState.Ok.rawValue)'")
        let recordsID:[String] = records.map { $0.id }
        print("Locais -> \(recordsID)")

        ///Get all Entries records names
        folders("/Entries", recursive: false, includeMediaInfo: true, includeDeleted: false) { (cursor, names, error) in
            if error != nil {
                print(error!)
            }else {
                print("All in Cloud -> \(names!)")

                let recordsDelete = records.filter { !names!.contains($0.id) }
                print("Delete -> \(names!)")

                for rTOd in recordsDelete {
                    RealmParse.deleteRecord(record: rTOd)
                }
                
                let filterAdd = names!.filter { !recordsID.contains($0) }
                print("Download from Cloud -> \(filterAdd)")
                
                for rTOa in filterAdd {
                    
                    getFiles("/Entries/\(rTOa)/\(rTOa)", completionHandler: { (data, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            let (record, preSugicalPlaning, postSugicalPlaning, compareImage) =  RealmParse.cloud.generateRecord(data!)
                            auSurgery(id: record.id, record: record, patient: record.patient!, formValues: ["":""], preSugicalPlaningForm: preSugicalPlaning, postSugicalPlaningForm: postSugicalPlaning, compareImages: compareImage, cloudGet: true)
                        }
                    })
                }
                
                let filterUpdate = names!.filter { recordsID.contains($0) }
                print("Update from Cloud -> \(filterUpdate)")
                
                for rTOu in filterUpdate {
                    
                    getFiles("/Entries/\(rTOu)/\(rTOu)", completionHandler: { (data, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            let (record, preSugicalPlaning, postSugicalPlaning, compareImage) =  RealmParse.cloud.generateRecord(data!)
                            print(record.patient!.name)
                            let records = realm.objects(Record.self).filter("id = '\(record.id)'")
                            if records.count > 0 {
                                print(records[0].update_at)
                                print(record.update_at)
                                print(records.count)
                                if records[0].update_at == record.update_at {
                                    print("OK")
                                }else {
                                    auSurgery(id: record.id, record: record, patient: nil, formValues: ["":""], preSugicalPlaningForm: preSugicalPlaning, postSugicalPlaningForm: postSugicalPlaning, compareImages: compareImage, cloudGet: true)
                                }
                            }
                            

                        }
                    })
                }
                
            }
        }
    }
    
    /// Return recods ids or Images id
    static func getID() -> (recordsIDs: [String], imageIDs: [String], records: [Record]) {
        var recordsIds:[String] = [String]()
        var imagesIds:[String] = [String]()

        let realm = try! Realm()
        let records = realm.objects(Record)
        var recordArray: [Record] = [Record]()
        for record in records {
            //Add record id
            recordsIds.append(record.id)
            
            //Add Images Ids
            for compareImage in record.compareImage {
                for image in compareImage.image {
                    imagesIds.append(image.name)
                }
            }
            
            //Add the record
            recordArray.append(record)
        }
        return (recordsIds, imagesIds, recordArray)
    }
    
}

public class CloudRevisions {
    /// If the file is deleted.
    public let isDeleted : Bool
    /// The revisions for the file. Only non-delete revisions will show up here.
    public let entries : Array<Files.FileMetadata>
    public init(isDeleted: Bool, entries: Array<Files.FileMetadata>) {
        self.isDeleted = isDeleted
        self.entries = entries
    }
}

public class CloudMetadata {
    /// The last component of the path (including extension). This never contains a slash.
    public let name : String
    /// The lowercased full path in the user's Dropbox. This always starts with a slash.
    public let pathLower : String
    /// Deprecated. Please use :field:'FileSharingInfo.parent_shared_folder_id' or
    /// :field:'FolderSharingInfo.parent_shared_folder_id' instead.
    public let parentSharedFolderId : String?
    public init(name: String, pathLower: String, parentSharedFolderId: String? = nil) {
        stringValidator()(value: name)
        self.name = name
        stringValidator()(value: pathLower)
        self.pathLower = pathLower
        nullableValidator(stringValidator(pattern: "[-_0-9a-zA-Z:]+"))(value: parentSharedFolderId)
        self.parentSharedFolderId = parentSharedFolderId
    }
}

