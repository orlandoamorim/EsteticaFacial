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

class PatientsTableVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var recordsSearch: [AnyObject] = [AnyObject]()
    var recordsDicAtoZ:[String : [Patient]] = [String : [Patient]]()
    
    var patientShow:PatientShow = .Patient
    var patient:Patient?
    var delegate: RecoverPatient! = nil

    var token: NotificationToken?
    
    deinit {
        if let token = token {
            token.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        token = realm.addNotificationBlock { [weak self] notification, realm in
            self?.update()
        }
        self.update()
            
//        if patientShow == .Patient {
//            //Adição para funcionar melhor no iPad
//            self.splitViewController!.delegate = self
//            self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
//        }

        // UIRefreshControl
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Puxe para Atualizar...")
        self.refreshControl = refreshControl
        
        // BarButtonItem Right
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(add))
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController(){
            if patientShow == .CheckPatient {
                delegate.recoverPatient(patient)
            }else{
                let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
                //ENVIANDO os dados por Object
                centroDeNotificacao.postNotificationName("noData", object: nil)
            }
        }
    }
    
    
    // MARK: - Add Call
    func add(){
        self.performSegueWithIdentifier("AddSegue", sender: nil)
    }
    
    // MARK: - prepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "UpdateSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! PatientDetailsVC
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                controller.contentToDisplay = .Atualizar
                
                let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
                let record = recordsDicAtoZ[key]!
                controller.patient = record[indexPath.row]
                
            }
        }else if segue.identifier == "AddSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! PatientDetailsVC
            controller.contentToDisplay = .Adicionar
        }else if segue.identifier == "SurgerySegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! SurgeriesTableVC
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                controller.surgeryShow = .Patient
                
                let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
                let record = recordsDicAtoZ[key]!
                controller.patient = record[indexPath.row]
                
            }

        }
    }
    
    // MARK: - RealmParse Update
    
    func update(){
        self.navigationItem.titleView = Helpers.setTitle("Pacientes", subtitle: "Atualizando...")

        self.recordsDicAtoZ.removeAll()
        self.recordsDicAtoZ = RealmParse.queryPatients()
        self.navigationItem.titleView = nil
        self.title = "Pacientes"
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource

extension PatientsTableVC {
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return recordsDicAtoZ.keys.sort() ?? nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(recordsDicAtoZ.keys.sort())[section].uppercaseString  as String ?? ""
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let messageLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        messageLabel.text = "\t   Nenhum dado de paciente disponivel. \r\r Siga as instruções: \r\r • Clique em + para adicionar um  novo paciente \r • Delize com dedo para baixo para atualizar"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PatientCell", forIndexPath: indexPath)
        
        let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
        let patient = recordsDicAtoZ[key]!
        
        cell.textLabel!.text = patient[indexPath.row].name
        cell.detailTextLabel!.text = dateTimeAgo(patient[indexPath.row].update_at)
        cell.imageView!.image = nil
        for record in patient[indexPath.row].records {
            for compareImage in record.compareImage{
                for image in compareImage.image {
                    if image.name != "" && image.imageType == "\(ImageTypes.Front.hashValue)" {
                        RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                            if error != nil {
                                print(error!.description)
                            }else {
                                cell.imageView!.image = object as? UIImage
                            }
                        })
                        break
                    }
                }
            }
        }
        cell.accessoryType = .None
        if patientShow == .Patient {
            cell.accessoryType = patient[indexPath.row].records.count > 0 ? .DetailDisclosureButton : .DisclosureIndicator
        }else if patientShow == .CheckPatient {
            if patient[indexPath.row].id == self.patient?.id {
                cell.accessoryType = .Checkmark
            }

        }

        
        return cell
    }

}
// MARK: - UITableViewDelegate
extension PatientsTableVC {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if recordsDicAtoZ.keys.count > 0 {
            if patientShow == .Patient {
                self.performSegueWithIdentifier("UpdateSegue", sender: indexPath)
            }else if patientShow == .CheckPatient {
                let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
                let record = recordsDicAtoZ[key]!
                patient = record[indexPath.row]
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SurgeriesTableVC") as! SurgeriesTableVC
        controller.surgeryShow = .Patient
        
        let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
        let record = recordsDicAtoZ[key]!
        controller.patient = record[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let delete = UITableViewRowAction(style: .Destructive, title: "\u{1F5D1}\n Deletar") { action, index in
            
            //Criando um objeto do tipo NSNOtitcationCenter
            
            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
            //ENVIANDO os dados por Object
            if self.patientShow != .CheckPatient{
                centroDeNotificacao.postNotificationName("noData", object: nil)
            }

            let key = Array(self.recordsDicAtoZ.keys.sort())[indexPath.section]
            let patient = self.recordsDicAtoZ[key]!
            
            let alert:UIAlertController = UIAlertController(title: "Atenção!", message: "Realmente deseja apagar o paciente \(patient[indexPath.row].name)? Ao fazer isto, você tambem remove todas as cirurgias referentes a este paciente.", preferredStyle: Device().isPad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Apagar", style: UIAlertActionStyle.Destructive, handler: { (delete) -> Void in
                if patient[indexPath.row].id == self.patient?.id {
                    self.patient = nil
                }
                RealmParse.deletePatient(patient: patient[indexPath.row])
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        delete.backgroundColor = UIColor.redColor()
        
        
        
        let info = UITableViewRowAction(style: .Default, title: "\u{1F6C8}\n Info") { action, index in
            let controller = UIStoryboard(name: "Patient", bundle: nil).instantiateViewControllerWithIdentifier("PatientDetailsVC") as! PatientDetailsVC
            controller.contentToDisplay = .Atualizar
            let key = Array(self.recordsDicAtoZ.keys.sort())[indexPath.section]
            let record = self.recordsDicAtoZ[key]!
            controller.patient = record[indexPath.row]
            controller.typeInfo = true
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        info.backgroundColor = UIColor.blueColor()
        

        return patientShow == .Patient ? [delete] : [delete, info]
    }
}



