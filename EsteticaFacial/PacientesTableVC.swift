//
//  PacientesTableVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 22/10/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift
import DeviceKit

class PacientesTableVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var recordsSearch: [AnyObject] = [AnyObject]()
    var recordsDicAtoZ:[String : [Record]] = [String : [Record]]()
    
    var token: NotificationToken?
    
    deinit {
        let realm = try! Realm()
        if let token = token {
            realm.removeNotification(token)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        token = realm.addNotificationBlock { [weak self] notification, realm in
            self?.update()
        }
        self.update()
        
        //Adição para funcionar melhor no iPad
        self.splitViewController!.delegate = self
        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        
        // UIRefreshControl
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PacientesTableVC.update), forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Puxe para Atualizar...")
        self.refreshControl = refreshControl
        
        // BarButtonItem Right
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(PacientesTableVC.add(_:)))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.refreshControl?.beginRefreshing()
//        self.navigationItem.titleView = Helpers.setTitle("Pacientes", subtitle: "Atualizando...")
//
//        tableView.setContentOffset(CGPoint(x: 0, y: -150), animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Add Call
    func add(button: UIBarButtonItem){
        self.performSegueWithIdentifier("AddSegue", sender: nil)
    }
    
    // MARK: - prepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "UpdateSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! AUFichaVC
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                controller.contentToDisplay = .Atualizar
                
                let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
                let record = recordsDicAtoZ[key]!
                controller.record = record[indexPath.row]
                
            }
        }else if segue.identifier == "AddSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! AUFichaVC
            controller.contentToDisplay = .Adicionar
        }
    }
    
    // MARK: - RealmParse Update
    
    func update(){
        self.navigationItem.titleView = Helpers.setTitle("Pacientes", subtitle: "Atualizando...")

        self.recordsDicAtoZ.removeAll()
        self.recordsDicAtoZ = RealmParse.query()
        self.navigationItem.titleView = nil
        self.title = "Paciente"
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
}

// MARK: - UISplitViewControllerDelegate

extension PacientesTableVC: UISplitViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.CurrentContext
    }
}

// MARK: - UITableViewDataSource

extension PacientesTableVC {
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return recordsDicAtoZ.keys.sort() ?? nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(recordsDicAtoZ.keys.sort())[section].uppercaseString  as String ?? ""
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let messageLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        messageLabel.text = "Nenhum dado de paciente disponivel. Por favor, delize com dedo para baixo para atualizar. "
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 5
        messageLabel.textAlignment = NSTextAlignment.Center
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PacienteCell", forIndexPath: indexPath)
        
        cell.imageView!.clipsToBounds = true
        cell.imageView!.layer.borderWidth = 1.0
        cell.imageView!.layer.borderColor = UIColor.darkGrayColor().CGColor
        cell.imageView!.layer.cornerRadius = 10.0
        
        let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
        let record = recordsDicAtoZ[key]!
        
        cell.textLabel!.text = record[indexPath.row].patient?.name
        cell.detailTextLabel!.text = Helpers.dataFormatter(dateFormat:"dd/MM/yyyy" , dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate((record[indexPath.row].patient?.date_of_birth)!)
        
        cell.imageView!.image = UIImage(named: "modelo_frontal")
        for image in record[indexPath.row].image {
            if image.name != "" {
                cell.imageView!.image = RealmParse.getFile(fileName: image.name, fileExtension: .JPG) as? UIImage
            }
        }
        
        return cell
    }

}
// MARK: - UITableViewDelegate
extension PacientesTableVC {
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
            print("more button tapped")
            
            //Criando um objeto do tipo NSNOtitcationCenter
            
            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
            //ENVIANDO os dados por Object
            centroDeNotificacao.postNotificationName("noData", object: nil)
            
            let key = Array(self.recordsDicAtoZ.keys.sort())[indexPath.section]
            let record = self.recordsDicAtoZ[key]!
            
            let alert:UIAlertController = UIAlertController(title: "Atenção!", message: "Realmente deseja apagar a ficha de \(record[indexPath.row].patient!.name)?", preferredStyle: Device().isPad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Apagar", style: UIAlertActionStyle.Destructive, handler: { (delete) -> Void in
                for image in record[indexPath.row].image {
                    RealmParse.deleteFile(fileName: image.name, fileExtension: .JPG)
                }
                
                RealmParse.deleteRecord(record: record[indexPath.row])
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        delete.backgroundColor = UIColor.redColor()
        
        //        let apply = UITableViewRowAction(style: .Default, title: "\u{2606}\n Like") { action, index in
        //            print("favorite button tapped")
        //        }
        //        apply.backgroundColor = UIColor.orangeColor()
        //
        //        let take = UITableViewRowAction(style: .Normal, title: "\u{2605}\n Rate") { action, index in
        //            print("share button tapped")
        //        }
        //        take.backgroundColor = UIColor.purpleColor()
        
        return [delete]
    }
    
    
}



