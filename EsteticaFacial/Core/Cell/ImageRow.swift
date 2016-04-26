//
//  ImageRow.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import UIKit

class ImageRow : UITableViewCell {
    
    var images:[Image]? = nil {
        didSet {
            setDic()
            collectionView.reloadData()
        }
    }
    
    var showDetailDelegate:ShowDetailDelegate? = nil
    let imageTypes: [Int: ImageTypes] = [0  : .Front, 1 : .ProfileRight, 2 : .Nasal, 3 : .ObliqueLeft, 4: .ProfileLeft, 5 : .ObliqueRight]
    var imageDic: [Int: UIImage] = [Int: UIImage]()
    func setDic () {
        imageDic.removeAll(keepCapacity: false)
        for image in images! {
            imageDic.updateValue(RealmParse.getFile(fileName: image.name, fileExtension: .JPG) as! UIImage, forKey: image.imageType.toInt())
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
}

extension ImageRow : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        
        let imageType = imageTypes[indexPath.row]

        if imageDic.keys.contains(imageType!.hashValue) {
            cell.cellImage = imageDic[imageType!.hashValue]
            cell.cellInfo = ""
            cell.imageRef = "\(imageType!)"
            return cell
        }
        
//        for image in images! {
//            if image.imageType.toInt() == imageType!.hashValue {
//                cell.cellImage = RealmParse.getFile(fileName: image.name, fileExtension: .JPG) as? UIImage
//                cell.cellInfo = ""
//                cell.imageRef = "\(imageType!)"
//                return cell
//            }
//        }
        
        switch imageType! {
            
        case .Front:
            cell.cellImage = UIImage(named: "modelo_frontal")
            cell.cellInfo = ""
            cell.imageRef = "\(imageType!)"
        case .ProfileRight:
            cell.cellImage = UIImage(named: "modelo_perfil")
            cell.cellInfo = ""
            cell.imageRef = "\(imageType!)"
        case .Nasal:
            cell.cellImage = UIImage(named: "modelo_nasal")
            cell.cellInfo = ""
            cell.imageRef = "\(imageType!)"
        case .ObliqueLeft:
            cell.cellImage = nil
            cell.cellInfo = "OL"
            cell.imageRef = "\(imageType!)"
        case .ProfileLeft:
            cell.cellImage = nil
            cell.cellInfo = "PL"
            cell.imageRef = "\(imageType!)"
        case .ObliqueRight:
            cell.cellImage = nil
            cell.cellInfo = "OR"
            cell.imageRef = "\(imageType!)"
        }
        return cell
    }
    
}

extension ImageRow : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemsPerRow:CGFloat = 4
        let hardCodedPadding:CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

extension ImageRow : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCell {
            let displayText = "selected cell number: \(indexPath.row + 1) from category: \(selectedCell.imageRef!)"
            showDetailDelegate?.showDetail(displayText)
        }
    }
    
}