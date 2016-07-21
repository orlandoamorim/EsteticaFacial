//
//  CategoryCell.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 07/07/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import DeviceKit
import RealmSwift

class CategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let cellId = "AppCellId"
    private var lastIndexPath:NSIndexPath?
    var record:Record!

    let cameraController = UIStoryboard(name: "Camera", bundle: nil).instantiateViewControllerWithIdentifier(Device().isPad ? "iPadCamera" : "iPhoneCamera") as! CameraVC
    
    var compareImage: CompareImage = CompareImage() {
        didSet {
            nameLabel.text = Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: .ShortStyle).stringFromDate(compareImage.create_at)
//            getImages()
        }
    }
    
    typealias ImageInfos = (name: String, date: NSDate?, image: UIImage?, points: [String : NSValue]?)
    
    var images: [String: ImageInfos] = [String: ImageInfos]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        cameraController.delegate = self

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imagesCollectionView: UICollectionView = {
        let layout =  UICollectionViewFlowLayout()
        layout.scrollDirection =  .Horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let deviderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Date - Comapre Image"
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = NSTextAlignment.Center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
        
    }()
    
    func setupViews() {
        backgroundColor = UIColor.clearColor()
        
        addSubview(imagesCollectionView)
        addSubview(deviderLineView)
        addSubview(nameLabel)
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        
        // Register cell classes
        imagesCollectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: cellId)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-14-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-14-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": deviderLineView]))
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imagesCollectionView]))
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[nameLabel(30)][v0][v1(0.5)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imagesCollectionView, "v1": deviderLineView, "nameLabel":nameLabel]))
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ImageCell
        
        cell.indexPath = indexPath.row
        for image in compareImage.image {
            if indexPath.row == 0 && Int(image.imageType)! == 0 {
                cell.image = image
                cell.indexPath = nil
                return cell
            }else if indexPath.row == 1 && Int(image.imageType)! == 1 {
                cell.image = image
                cell.indexPath = nil
                return cell
            }else if indexPath.row == 2 && Int(image.imageType)! == 2 {
                cell.image = image
                cell.indexPath = nil
                return cell
            }else if indexPath.row == 3 && Int(image.imageType)! == 3 {
                cell.image = image
                cell.indexPath = nil
                return cell
            }else if indexPath.row == 4 && Int(image.imageType)! == 5 {
                cell.image = image
                cell.indexPath = nil
                return cell
            }else if indexPath.row == 5 && Int(image.imageType)! == 4 {
                cell.image = image
                cell.indexPath = nil
                return cell
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, frame.height - 32)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCell {
            if cell.image != nil && cell.indexPath == nil {
                print("Process image")
                showOptions(cell.image!, imageCell: cell)
            }else {
                print("Get Image")
                lastIndexPath = indexPath
                cameraController.imageType = ImageTypes(rawValue: indexPath.row)!
                if indexPath.row == 4 {
                    cameraController.imageType = .ProfileLeft
                }else if indexPath.row == 5 {
                    cameraController.imageType = .ObliqueRight
                }
                print(cameraController.imageType)
                
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(cameraController, animated: true, completion: nil)
            }
        }
    }
    
    func showOptions(images: Image, imageCell: ImageCell) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            // now that we know the number of actions aren't empty
            let sourceActionSheet = UIAlertController(title: nil, message: "UFPI", preferredStyle: .ActionSheet)
            if let popView = sourceActionSheet.popoverPresentationController {
                sourceActionSheet.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                popView.sourceView = imageCell
                popView.sourceRect = imageCell.bounds
                
            }
            
            let cameraOption = UIAlertAction(title: NSLocalizedString("Tirar Foto", comment: ""), style: .Default, handler: { (_) in
                self.cameraController.imageType = ImageTypes(rawValue: images.imageType.toInt())!
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(self.cameraController, animated: true, completion: nil)
            })
            sourceActionSheet.addAction(cameraOption)
            
            
            
            let showPhotoOption = UIAlertAction(title: NSLocalizedString("Processar Imagem", comment: ""), style: .Default, handler: { (_) in
//                self.performSegueWithIdentifier("ShowImageSegue", sender: nil)
            })
            sourceActionSheet.addAction(showPhotoOption)


            let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Apagar Imagem", comment: ""), style: .Destructive, handler: { (_) in
                self.compareImage.image.removeAtIndex(self.compareImage.image.indexOf(images)!)

                let realm = try! Realm()
                if self.record != nil{
                    for compImg in self.record.compareImage {
                        if compImg.reference == self.compareImage.reference {
                            for image in compImg.image {
                                if image.imageType.toInt() == images.imageType.toInt() {
                                    if RealmParse.cloud.isLogIn() != CloudTypes.LogOut {
                                        
                                        try! realm.write {
                                            //CompareImage
                                            compImg.image.removeAtIndex(compImg.image.indexOf(image)!)
                                            //Image
                                            image.cloudState = CloudState.Delete.rawValue
                                            
                                            realm.add(compImg, update: true)
                                            realm.add(image, update: true)
                                        }
                                        
                                    }else {
                                        RealmParse.deleteImage(image)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                self.imagesCollectionView.reloadData()
                
                
            })
            sourceActionSheet.addAction(clearPhotoOption)
            
            sourceActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .Cancel, handler:nil))
            
            
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(sourceActionSheet, animated: true, completion: nil)
                sourceActionSheet.view.layoutIfNeeded()
            })
        }
    }
    
}

extension CategoryCell: RecordImageDelegate {
    
    func updateData(image image: UIImage, ImageType: ImageTypes) {
        switch ImageType {
        case .Front:
            print(ImageTypes.Front.hashValue)
            compareImage.image.append(RealmParse.image(record.id,compareImageID: compareImage.id , imageRef: compareImage.reference.toInt(), imageType: ImageTypes.Front.hashValue, fileName: "[\(compareImage.reference)]Front-\(record.id)", image: image, points: nil, uImage: RealmParse.imageObject(compareImage.reference.toInt(), compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.Front.hashValue)))
            
        case .ProfileRight:
            compareImage.image.append(RealmParse.image(record.id,compareImageID: compareImage.id , imageRef: compareImage.reference.toInt(), imageType: ImageTypes.ProfileRight.hashValue, fileName: "[\(compareImage.reference)]ProfileRight-\(record.id)", image: image, points: nil, uImage: RealmParse.imageObject(compareImage.reference.toInt(), compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ProfileRight.hashValue)))
        case .Nasal:
            compareImage.image.append(RealmParse.image(record.id,compareImageID: compareImage.id , imageRef: compareImage.reference.toInt(), imageType: ImageTypes.Nasal.hashValue, fileName: "[\(compareImage.reference)]Nasal-\(record.id)", image: image, points: nil, uImage: RealmParse.imageObject(compareImage.reference.toInt(), compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.Nasal.hashValue)))
        case .ObliqueLeft:
            compareImage.image.append(RealmParse.image(record.id,compareImageID: compareImage.id , imageRef: compareImage.reference.toInt(), imageType: ImageTypes.ObliqueLeft.hashValue, fileName: "[\(compareImage.reference)]ObliqueLeft-\(record.id)", image: image, points: nil, uImage: RealmParse.imageObject(compareImage.reference.toInt(), compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ObliqueLeft.hashValue)))
        case .ProfileLeft:
            compareImage.image.append(RealmParse.image(record.id,compareImageID: compareImage.id , imageRef: compareImage.reference.toInt(), imageType: ImageTypes.ProfileLeft.hashValue, fileName: "[\(compareImage.reference)]ProfileLeft-\(record.id)", image: image, points: nil, uImage: RealmParse.imageObject(compareImage.reference.toInt(), compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ProfileLeft.hashValue)))
        case .ObliqueRight:
            compareImage.image.append(RealmParse.image(record.id,compareImageID: compareImage.id , imageRef: compareImage.reference.toInt(), imageType: ImageTypes.ObliqueRight.hashValue, fileName: "[\(compareImage.reference)]ObliqueRight-\(record.id)", image: image, points: nil, uImage: RealmParse.imageObject(compareImage.reference.toInt(), compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ObliqueRight.hashValue)))
        }
        imagesCollectionView.reloadData()
    }
}



class ImageCell: UICollectionViewCell {
    
    typealias ImageInfos = (name: String, date: NSDate?, image: UIImage?, points: [String : NSValue]?)
    
    var images: ImageInfos? {
        didSet {
            createAtLabel.text = images?.date != nil ? Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: .ShortStyle).stringFromDate(images!.date!) : ""
            nameLabel.text = images!.name
            imageView.image = images?.image == nil ? nil : images!.image!
        }
    
    }
    
    var image: Image? = nil {
        didSet{
            if image != nil {
                setValues(image!)
            }
        }
    }
    
    var indexPath: Int? = nil {
        didSet{
            if indexPath != nil {
                switch indexPath! {
                case ImageTypes.Front.hashValue :
                    nameLabel.text = "Frontal"
                    lettersLabel.hidden = true
                    imageView.hidden = false
                    imageView.image = UIImage(named: "modelo_frontal")
                case ImageTypes.ProfileRight.hashValue :
                    nameLabel.text = "Perfil Direito"
                    lettersLabel.hidden = true
                    imageView.hidden = false
                    imageView.image = UIImage(named: "modelo_perfil")
                case ImageTypes.Nasal.hashValue :
                    nameLabel.text = "Nasal"
                    lettersLabel.hidden = true
                    imageView.hidden = false
                    imageView.image = UIImage(named: "modelo_nasal")
                case ImageTypes.ObliqueLeft.hashValue :
                    lettersLabel.hidden = false
                    imageView.hidden = true
                    lettersLabel.text = "OE"
                    nameLabel.text = "OE"
                case 4 :
                    lettersLabel.hidden = false
                    imageView.hidden = true
                    lettersLabel.text = "PE"
                    nameLabel.text = "PE"
                case 5 :
                    lettersLabel.hidden = false
                    imageView.hidden = true
                    lettersLabel.text = "OD"
                    nameLabel.text = "OD"

                default: print("ERRO setImageView(_):")
                }
                
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = nil
        iv.contentMode = .ScaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.borderColor = UIColor.blackColor().CGColor
        iv.layer.borderWidth = 2
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    let lettersLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = UIFont.systemFontOfSize(25)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 1
        
        label.layer.cornerRadius = 16
        label.layer.borderColor = UIColor.blackColor().CGColor
        label.layer.borderWidth = 2
        label.layer.masksToBounds = true
        
        return label
        
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 2
        return label
        
    }()
    
    let createAtLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.font = UIFont.systemFontOfSize(13)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 2
        return label
        
    }()
    
    
    func setupViews() {
        addSubview(lettersLabel)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(createAtLabel)
        
        lettersLabel.frame = CGRectMake(0, 0, frame.width, frame.width)
        imageView.frame = CGRectMake(0, 0, frame.width, frame.width)
        nameLabel.frame = CGRectMake(0, frame.width + 2, frame.width, 40)
        createAtLabel.frame = CGRectMake(0, frame.width + 38, frame.width, 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValues(image: Image) {
        self.imageView.hidden = false
        switch Int(image.imageType)! {
        case ImageTypes.Front.hashValue :
            nameLabel.text = "Frontal"
            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                if error != nil {
                    print(error!.description)
                    if RealmParse.cloud.isLogIn() == .Dropbox {
                        self.imageView.image = UIImage(named: "DropboxError")
                    }else if RealmParse.cloud.isLogIn() == .LogOut {
                        self.imageView.image = UIImage(named: "modelo_frontal")
                    }
                }else {
                    self.imageView.image = object as? UIImage
                }
            })
            
        case ImageTypes.ProfileRight.hashValue :
            nameLabel.text = "Perfil Direito"
            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                if error != nil {
                    print(error!.description)
                    if RealmParse.cloud.isLogIn() == .Dropbox {
                        self.imageView.image = UIImage(named: "DropboxError")
                    }else if RealmParse.cloud.isLogIn() == .LogOut {
                        self.imageView.image = UIImage(named: "modelo_perfil")
                    }
                }else {
                    self.imageView.image = object as? UIImage
                }
            })
            
            
        case ImageTypes.Nasal.hashValue :
            nameLabel.text = "Nasal"
            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                if error != nil {
                    print(error!.description)
                    if RealmParse.cloud.isLogIn() == .Dropbox {
                        self.imageView.image = UIImage(named: "DropboxError")
                    }else if RealmParse.cloud.isLogIn() == .LogOut {
                        self.imageView.image = UIImage(named: "modelo_nasal")
                    }
                }else {
                    self.imageView.image = object as? UIImage
                }
            })
            
        case ImageTypes.ObliqueLeft.hashValue :
            nameLabel.text = "OE"
            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                if error != nil {
                    print(error!.description)
                    if RealmParse.cloud.isLogIn() == .Dropbox {
                        self.imageView.image = UIImage(named: "DropboxError")
                    }else if RealmParse.cloud.isLogIn() == .LogOut {
                        self.imageView.hidden = true
                        self.lettersLabel.text = "OE"
                    }
                }else {
                    self.imageView.image = object as? UIImage
                }
            })
            
            
        case ImageTypes.ProfileLeft.hashValue :
            nameLabel.text = "PE"
            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                if error != nil {
                    print(error!.description)
                    if RealmParse.cloud.isLogIn() == .Dropbox {
                        self.imageView.image = UIImage(named: "DropboxError")
                    }else if RealmParse.cloud.isLogIn() == .LogOut {
                        self.imageView.hidden = true
                        self.lettersLabel.text = "PE"
                    }
                }else {
                    self.imageView.image = object as? UIImage
                }
            })
            
            
        case ImageTypes.ObliqueRight.hashValue :
            nameLabel.text = "OD"
            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                if error != nil {
                    print(error!.description)
                    if RealmParse.cloud.isLogIn() == .Dropbox {
                        self.imageView.image = UIImage(named: "DropboxError")
                    }else if RealmParse.cloud.isLogIn() == .LogOut {
                        self.imageView.hidden = true
                        self.lettersLabel.text = "OD"
                    }
                }else {
                    self.imageView.image = object as? UIImage
                }
            })
        default: print("ERRO setImageView(_):")
        }

    }
}
