//
//  SurgeriesTableViewController.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 11/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift
import DeviceKit

class SurgeriesTableVC: UITableViewController, UISearchBarDelegate, VSReachability {
    
//    @IBOutlet weak var searchBar: UISearchBar!
    var resultSearchController: UISearchController!
    
    var recordsSearch: [AnyObject] = [AnyObject]()
    var recordsDicAtoZ:[String : [Record]] = [String : [Record]]()
    
    var surgeryShow:SurgeryShow = .Surgery
    var patient:Patient?
    var touchedCell: (cell: UITableViewCell, indexPath: NSIndexPath)?
    
    var token: NotificationToken?
    
    deinit {
        if let token = token {
            token.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("Migration-0.2.3") == nil {
            RealmParse.migrateImageToCompareImage()
        }
        
        let realm = try! Realm()
        token = realm.addNotificationBlock { [weak self] notification, realm in
            self?.update()
        }
        self.update()
        
        if patient == nil {
            self.splitViewController!.delegate = self
            self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        }
    
        self.resultSearchController = ({
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            return searchController
        })()
        
        switch surgeryShow {
        case .Surgery: self.tableView.tableHeaderView = self.resultSearchController.searchBar
        case .Patient: self.tableView.tableHeaderView = nil
        }
        
        
        // UIRefreshControl
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Puxe para Atualizar...")
        self.refreshControl = refreshControl
        
        // BarButtonItem Right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(add))
        
        //Registrando o 3D Touch
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: self.tableView)
            }
        } else {
            // Fallback on earlier versions
        }
        
        if RealmParse.cloud.isLogIn() != .LogOut {
            RealmParse.cloud.sync()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // BarButtonItem Left
        if surgeryShow == .Surgery {
            let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings-22"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(settings))
            let cloudBarButtonItem = UIBarButtonItem(image: UIImage(named: RealmParse.cloud.isLogIn().rawValue), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(verifyCloud))
                        
            if RealmParse.cloud.isLogIn() != .LogOut {
                self.navigationItem.leftBarButtonItems?.removeAll()
                self.navigationItem.leftBarButtonItems = [settingsBarButtonItem, cloudBarButtonItem]
            }else {
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.leftBarButtonItem = settingsBarButtonItem
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController(){
            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
            //ENVIANDO os dados por Object
            centroDeNotificacao.postNotificationName("noData", object: nil)
        }
    }
    
    func settings(button: UIBarButtonItem){
        self.performSegueWithIdentifier("SettingsSegue", sender: nil)
    }
    
    // MARK: - Add Call
    func add(){
        self.performSegueWithIdentifier("AddSegue", sender: nil)
    }
    
    // MARK: - prepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "UpdateSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! SurgeryDetailsVC
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                controller.contentToDisplay = .Atualizar
                
                let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
                let record = recordsDicAtoZ[key]!
                controller.record = record[indexPath.row]
                controller.patient = patient
                
            }
        }else if segue.identifier == "AddSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! SurgeryDetailsVC
            controller.contentToDisplay = .Adicionar
            controller.patient = patient
        }
    }
    
    // MARK: - RealmParse Update
    
    func update(){
        self.navigationItem.titleView = Helpers.setTitle("Cirurgias", subtitle: "Atualizando...")
        
        self.recordsDicAtoZ.removeAll()
        switch surgeryShow { //
        case .Surgery:
            let predicate = NSPredicate(format: "cloudState != '\(CloudState.Delete.rawValue)'")
            self.recordsDicAtoZ = RealmParse.querySurgeries(predicate)
        case .Patient: self.recordsDicAtoZ = RealmParse.queryPatientSurgeries(patient!)
        }
        
        
        self.navigationItem.titleView = nil
        self.title = "Cirurgias"
        if patient != nil {
            self.navigationItem.titleView = Helpers.setTitle("Cirurgias", subtitle: "\(patient!.name)")
        }
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    func verifyCloud() {
        RealmParse.cloud.sync(self)
    }
}

// MARK: - UISplitViewControllerDelegate

extension SurgeriesTableVC: UISplitViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.CurrentContext
    }
}

// MARK: - UITableViewDataSource

extension SurgeriesTableVC {
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return recordsDicAtoZ.keys.sort() ?? nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(recordsDicAtoZ.keys.sort())[section].uppercaseString  as String ?? ""
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let messageLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        messageLabel.text = "\t   Nenhum cirurgia disponivel. \r\r Siga as instruções: \r\r • Clique em + para adicionar uma  nova cirurgia \r • Delize com dedo para baixo para atualizar"
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 10
        messageLabel.textAlignment = NSTextAlignment.Justified
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        messageLabel.sizeToFit()
        
        self.tableView.backgroundView = messageLabel
        self.tableView.backgroundView?.hidden =  (recordsDicAtoZ.count == 0 ? false : true )
        self.tableView.separatorStyle = (recordsDicAtoZ.count == 0 ? .None : .SingleLine )
        
        
        return recordsDicAtoZ.keys.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsDicAtoZ[Array(recordsDicAtoZ.keys.sort())[section]]!.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SurgeryCell", forIndexPath: indexPath)
        
        cell.imageView!.clipsToBounds = true
        cell.imageView!.layer.borderWidth = 1.0
        cell.imageView!.layer.borderColor = UIColor.darkGrayColor().CGColor
        cell.imageView!.layer.cornerRadius = 10.0
        
        let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
        let record = recordsDicAtoZ[key]!
        
        cell.textLabel!.text = record[indexPath.row].surgeryDescription != "" ? record[indexPath.row].surgeryDescription : record[indexPath.row].patient?.name
        cell.detailTextLabel!.text = Helpers.dataFormatter(dateFormat:"dd/MM/yyyy" , dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate((record[indexPath.row].patient?.date_of_birth)!)
        
        
        
        cell.imageView!.image = UIImage(named: "modelo_frontal")
        for compareImage in record[indexPath.row].compareImage {
            if compareImage.reference == 0.toString() {
                for image in compareImage.image {
                    if image.name != "" {
                        RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                            if error != nil {
                                print(error!.description)
                            }else {
                                cell.imageView!.image = object as? UIImage
                            }
                        })

                    }
                }
            }
        }
        
        return cell
    }
    
}
// MARK: - UITableViewDelegate
extension SurgeriesTableVC {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if recordsDicAtoZ.keys.count > 0 {
            self.performSegueWithIdentifier("UpdateSegue", sender: indexPath)
        }
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let delete = UITableViewRowAction(style: .Destructive, title: "\u{1F5D1}\n Deletar") { action, index in
    
            let key = Array(self.recordsDicAtoZ.keys.sort())[indexPath.section]
            let record = self.recordsDicAtoZ[key]!
            
            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
            centroDeNotificacao.postNotificationName("noData", object: nil)
            
            let alert:UIAlertController = UIAlertController(title: "Atenção!", message: "", preferredStyle: Device().isPad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet)

            alert.message = "Realmente deseja apagar a cirugia de \(record[indexPath.row].patient!.name)?"
            
            alert.addAction(UIAlertAction(title: "Apagar", style: UIAlertActionStyle.Destructive, handler: { (delete) -> Void in
                let realm = try! Realm()

                try! realm.write {
                    record[indexPath.row].cloudState = CloudState.Delete.rawValue
                    realm.add(record[indexPath.row], update: true)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))

        
            self.presentViewController(alert, animated: true, completion: nil)

            
        }
        delete.backgroundColor = UIColor.redColor()
        
        return [delete]
    }
}

extension SurgeriesTableVC: UIViewControllerPreviewingDelegate {
    
    
    // PEEK
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRowAtPoint(location),
            cell = tableView.cellForRowAtIndexPath(indexPath) else {return nil}
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SurgeryDetailsVC") as? SurgeryDetailsVC else {return nil}
        
        touchedCell = (cell,indexPath)
        let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
        let record = recordsDicAtoZ[key]!
        controller.record = record[indexPath.row]
        controller.patient = patient
        controller.contentToDisplay = .Atualizar
        
        controller.preferredContentSize = CGSize(width: 0, height: 0)
        
        previewingContext.sourceRect = cell.frame

        
        
        return controller
    }
    
    // POP
    @available(iOS 9.0, *)
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SurgeryDetailsVC") as? SurgeryDetailsVC {
            let key = Array(recordsDicAtoZ.keys.sort())[touchedCell!.indexPath.section]
            let record = recordsDicAtoZ[key]!
            controller.record = record[touchedCell!.indexPath.row]
            controller.patient = patient
            controller.contentToDisplay = .Atualizar
            showViewController(controller, sender: self)
        }
    }
    
    @available(iOS 9.0, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        let regularAction = UIPreviewAction(title: "Regular", style: .Default) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            
        }
        
        let destructiveAction = UIPreviewAction(title: "Destructive", style: .Destructive) { (action: UIPreviewAction, vc: UIViewController) -> Void in
            
        }
        
        let actionGroup = UIPreviewActionGroup(title: "Group...", style: .Default, actions: [regularAction, destructiveAction])
        
        return [regularAction, destructiveAction, actionGroup]
    }
}

extension SurgeriesTableVC : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.recordsDicAtoZ.removeAll()
        
        let predicate = NSPredicate(format: "patient.name CONTAINS[c] %@ OR patient.sex CONTAINS[c] %@ OR patient.mail CONTAINS[c] %@ OR patient.phone CONTAINS[c] %@ OR patient.ethnic CONTAINS[c] %@ OR note CONTAINS[c] %@ OR surgeryDescription CONTAINS[c] %@", searchController.searchBar.text!, searchController.searchBar.text!, searchController.searchBar.text!, searchController.searchBar.text!, searchController.searchBar.text!, searchController.searchBar.text!, searchController.searchBar.text!)
        
        switch surgeryShow {
        case .Surgery: self.recordsDicAtoZ = RealmParse.querySurgeries(predicate)
        case .Patient: self.recordsDicAtoZ = RealmParse.queryPatientSurgeries(patient!, with: predicate)
        }
        
        self.tableView.reloadData()
        
    }
}
