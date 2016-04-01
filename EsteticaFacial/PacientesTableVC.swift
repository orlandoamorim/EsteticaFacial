//
//  PacientesTableVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 22/10/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

// Segue Name : UpdateSegue -> Atualiza os dados.
//              AddSegue    -> Add dados.

import UIKit
import Parse
import SwiftyDrop
import RealmSwift
import DeviceKit

class PacientesTableVC: UITableViewController,VSReachability, UISplitViewControllerDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
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

    
    // MARK: - Add Call
    func add(button: UIBarButtonItem){
        self.performSegueWithIdentifier("AddSegue", sender: nil)
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
        
        // BarButtun Right
        
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
            if image.path != "" {
                cell.imageView!.image = RealmParse.loadImageFromPath(image.path)
            }
        }
        
        return cell
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
                    RealmParse.removeImage(image.path)
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
    
    
    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            //Criando um objeto do tipo NSNOtitcationCenter
//            
//            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
//            //ENVIANDO os dados por Object
//            centroDeNotificacao.postNotificationName("noData", object: nil)
//            
//            let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
//            let object = recordsDicAtoZ[key]!
//
//            let dataParse:PFObject = object[indexPath.row] as! PFObject
//            let nome = dataParse.objectForKey("nome") as! String
//            
//            Drop.down("Deletando ficha do paciente \(nome)", state: .Info)
//            
//            if recordsDicAtoZ.keys.count == 1 && object.count == 1 {
//                self.recordsDicAtoZ.removeAll(keepCapacity: false)
//                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
//            }else if object.count == 1{
//                self.recordsDicAtoZ.removeValueForKey(key)
//                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
//                
//            }else {
//                self.recordsDicAtoZ[key]!.removeAtIndex(indexPath.row)
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//            }
//            
//            
//            
//            dataParse.deleteInBackgroundWithBlock({ (success, error) -> Void in
//                if error == nil {
//                    Drop.down("Ficha deletada com Sucesso.", state: .Success)
//                }else{
//                    Drop.down("Erro ao deletar. Tente novamente mais tarde.", state: .Error)
//                }
//            })
//        }
    

//    }

    

//    
//    @IBAction func switchTipo(sender: UIButton) {
//        
//        var todas = "Todas as Fichas"
//        var realizadas = "Realizadas"
//        var nao_realizadas = "Não Realizadas"
//        
//        switch Helpers.verificaSwitch() {
//        case "realizadas":
//            realizadas = "Realizadas ⚡️"
//        case "nao_realizadas":
//            nao_realizadas = "Não Realizadas ⚡️"
//        default:
//            todas = "Todas as Fichas ⚡️"
//
//        }
//        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//
//        let alertController = UIAlertController(title: "Analise Facial", message: "Qual tipo de conteudo deseja carregar?", preferredStyle: UIAlertControllerStyle.ActionSheet)
//
//        
//        alertController.addAction(UIAlertAction(title: todas, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            userDefaults.setValue("todas", forKey: "switchCT")
//            userDefaults.synchronize()
//            self.update()
//        }))
//        
//        alertController.addAction(UIAlertAction(title: realizadas, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            userDefaults.setValue("realizadas", forKey: "switchCT")
//            userDefaults.synchronize()
//            self.update()
//        }))
//        
//        alertController.addAction(UIAlertAction(title: nao_realizadas, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            userDefaults.setValue("nao_realizadas", forKey: "switchCT")
//            userDefaults.synchronize()
//            self.update()
//        }))
//        
//        
//        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
//            sender.setTitle("Pacientes v", forState: UIControlState.Normal)
//        }))
//        
//        alertController.popoverPresentationController?.sourceView = sender
//        alertController.popoverPresentationController?.sourceRect = sender.bounds
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
    
    // MARK: - Parse Connection
    
    func update(){
        self.navigationItem.titleView = Helpers.setTitle("Pacientes", subtitle: "Atualizando...")

//         self.records.removeAll(keepCapacity: false)
//        if self.isConnectedToNetwork(){
//            updateParse()
//            
//        }else{
//            Drop.down("Sem conexão com a Internet", state: DropState.Warning)
//            self.refreshControl?.endRefreshing()
//        }
        self.recordsDicAtoZ.removeAll()
        self.recordsDicAtoZ = RealmParse.query()
        self.navigationItem.titleView = nil
        self.title = "Paciente"
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
}

// MARK: - UISplitViewControllerDelegate
extension PacientesTableVC {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.CurrentContext
    }
}

extension PacientesTableVC {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
//        if recordsDicAtoZ!.count > 0 {
//            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
//            self.tableView.backgroundView?.hidden = true
//            return recordsDicAtoZ!.keys.count
//        }
        
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
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return recordsDicAtoZ.keys.sort() ?? nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if recordsDicAtoZ.count > 0 {
//            let key = Array(recordsDicAtoZ.keys.sort())[section]
//            return key.uppercaseString as String
//        }
        return Array(recordsDicAtoZ.keys.sort())[section].uppercaseString  as String ?? ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsDicAtoZ[Array(recordsDicAtoZ.keys.sort())[section]]!.count ?? 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if recordsDicAtoZ.keys.count > 0 {
            self.performSegueWithIdentifier("UpdateSegue", sender: indexPath)
        }
        
    }

}
