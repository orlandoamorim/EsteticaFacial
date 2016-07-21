//
//  CompareImagesController.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 06/07/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CompareImagesController: UICollectionViewController {
    
    
    var record:Record!
    var compareImages:[CompareImage] = [CompareImage]()
    var lastReference:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(CategoryCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Setting the layout
        self.collectionView!.collectionViewLayout = UICollectionViewFlowLayout()
        
        // Setting the background color
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
        
        compareImages.sortInPlace({ $0.reference < $1.reference })
        lastReference = compareImages.last!.reference.toInt()
        
        //Setting new BarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(newCompareImage))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return compareImages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CategoryCell
        cell.compareImage = compareImages[indexPath.row]
        cell.record = record
        return cell
    }
    
    

    func newCompareImage(){
        guard compareImages.last?.image.count > 0 else {
            let alert = UIAlertController.alertControllerWithTitle("Ops...", message: "Você deve adicionar fotos da ultima visita do paciente para poder acompanha-lo.")
            presentViewController(alert, animated: true, completion: nil)
            return
        
        
        }
        
        let ci = CompareImage()
        ci.recordID = record.id
        lastReference = lastReference + 1
        ci.reference = lastReference.toString()
        compareImages.append(ci)
        compareImages.sortInPlace({ $0.reference < $1.reference })
        collectionView?.insertItemsAtIndexPaths([NSIndexPath(forRow: lastReference, inSection: 0)])
    }
}

extension CompareImagesController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width, 200)
    }
}
