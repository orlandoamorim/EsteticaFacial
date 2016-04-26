//
//  CompareImagesVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 23/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift

protocol ShowDetailDelegate {
    func showDetail(displayText:String)
}

class CompareImagesVC: UIViewController {
    
    var compareImages:[CompareImage] = [CompareImage]()
    var imagesDic: [Int : [Image]] = [Int : [Image]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let testPage = segue.destinationViewController as? TestPage,
//            let displayString = sender as? String {
//            testPage.displayString = displayString
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(add))
        transformImages()
        tableView.reloadData()
    }
    
    func transformImages(){
        for compareImage in compareImages {
            var images:[Image] = [Image]()
            for image in compareImage.image {
                images.append(image)
            }
            imagesDic.updateValue(images, forKey: compareImage.reference.toInt())
        }
    }
    
    func add(){
        let imageAdd:[Image] = [Image]()
        imagesDic.updateValue(imageAdd, forKey: Array(imagesDic.keys.sort()).last! + 1)
        self.tableView.reloadData()
    }
    
    func getHeader(key: Int) -> String{
        let images = imagesDic[key]
        let image = images?.sort({ $0.create_at < $1.create_at }).first
        return image?.create_at != nil ? Helpers.dataFormatter(dateFormat: "dd/MM/yyyy", dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate(image!.create_at) : "Clique aqui adiconar uma data."
    }
}

extension CompareImagesVC : UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("header") as! HeaderCell
        let _ = Array(imagesDic.keys.sort())[section]
        cell.name = getHeader(Array(imagesDic.keys.sort())[section])
        let tapHeader = UITapGestureRecognizer(target: self, action: #selector(tappedOnHeader(_:)))
        tapHeader.delegate = self
        tapHeader.numberOfTapsRequired = 1
        tapHeader.numberOfTouchesRequired = 1
        cell.contentView.addGestureRecognizer(tapHeader)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tappedOnHeader(gesture:UIGestureRecognizer){
        if let cellContentView = gesture.view {
            let tappedPoint = cellContentView.convertPoint(cellContentView.bounds.origin, toView: tableView)
            for i in 0..<tableView.numberOfSections {
                let sectionHeaderArea = tableView.rectForHeaderInSection(i)
                if CGRectContainsPoint(sectionHeaderArea, tappedPoint) {
                    print("tapped on category:: \(Array(imagesDic.keys.sort())[i])")
                }
            }
        }
    }
    
}

extension CompareImagesVC : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return imagesDic.keys.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! ImageRow
        let key = imagesDic.keys.sort()[indexPath.section]
        print(imagesDic[key]!)
        cell.images = imagesDic[key]!
        cell.showDetailDelegate = self
        cell.collectionView.backgroundColor = tableView.backgroundColor
        
        return cell
    }
    
}

// Had to add this, even though it doesn't do anything.
extension CompareImagesVC : UIGestureRecognizerDelegate { }

extension CompareImagesVC : ShowDetailDelegate {
    func showDetail(displayText:String){
        print(displayText)
    }
}