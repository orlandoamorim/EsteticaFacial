//
//  PacientesTableVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 22/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

// Segue Name : AUSegue -> A mesma segue sera usada tanto para adicao como edicao de dados do usuario.

import UIKit
import CoreData

class PacientesTableVC: UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moContext: NSManagedObjectContext?
    var entity: NSEntityDescription?
    var predicate:NSPredicate = NSPredicate()

    var records:[AnyObject] = [AnyObject]()
    var recordsSearch: [AnyObject] = [AnyObject]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        moContext = appDelegate.managedObjectContext
        entity = NSEntityDescription.entityForName("Paciente", inManagedObjectContext: moContext!)
        
        // UIRefreshControl
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Puxe para Atualizar...")
        //refreshControl.t = "Atualizar"
        self.refreshControl = refreshControl
        
        // BarButtun Right
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "add:")
        
        update()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CoreData
    
    
    func update() {
        records.removeAll(keepCapacity: false)
        //predicate = NSPredicate(format: "NOT (self IN %@)", argumentArray: ["etnia","img_frontal","img_perfil"])
        //NSPredicate(format: "nome AND thumb_frontal AND sobrenome AND nascimento")
        
        let fetchRequest = NSFetchRequest(entityName: "Paciente")
        //fetchRequest.predicate = self.predicate
        
        do {
            records = try moContext!.executeFetchRequest(fetchRequest)
            // success ...
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if records.count > 0 {
            return records.count
        }
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PacientesCell", forIndexPath: indexPath)

        
        if records.count == 0 {
            cell.textLabel?.text = "Nome do Paciente"
            cell.detailTextLabel?.text = "Idade do Paciente"
            cell.imageView?.image = UIImage(named: "modelo_frontal")
            
            return cell
        }
        
        let paciente = records[indexPath.row] as! Paciente
        // Configure the cell...
        
        if let imageData = paciente.thumb_frontal{
            cell.imageView?.image = UIImage(data: imageData)
        }else {
            cell.imageView?.image = UIImage(named: "modelo_frontal")
        }
        
        cell.textLabel?.text = paciente.nome!
        cell.detailTextLabel?.text = dataFormatter().stringFromDate(paciente.nascimento!)

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("AUSegue", sender: indexPath)

    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let ficha = records[indexPath.row] as! Paciente
        
        let btnDeletar = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Apagar" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in

            self.moContext!.deleteObject(ficha as NSManagedObject)
            
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                do {
                    try self.moContext!.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            })
            
            self.update()
            
        })
        
        return [btnDeletar]
        
    }

    

    // MARK: - Add Call
    
    func add(button: UIBarButtonItem){
        self.performSegueWithIdentifier("AUSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let nav = segue.destinationViewController as! UINavigationController
        let controller = nav.topViewController as! AUPacienteVC
        if let indexPath:NSIndexPath = sender as? NSIndexPath {
            controller.type = "Update"
            print(indexPath.row)
            controller.ficha = records[indexPath.row] as? Paciente
            controller.moContext = moContext
        }else{
            controller.type = "Add"
        }
    }
    
    // MARK: - Formatador
    
    func dataFormatter() -> NSDateFormatter {
        let formatador: NSDateFormatter = NSDateFormatter()
        let localizacao = NSLocale(localeIdentifier: "pt_BR")
        formatador.locale = localizacao
        formatador.dateStyle =  NSDateFormatterStyle.ShortStyle
        formatador.dateFormat = "dd/MM/yyyy"
        
        return formatador
    }
    
}
