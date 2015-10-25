//
//  PacientesTableVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 22/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

// Segue Name : AUSegue -> A mesma segue sera usada tanto para adicao como edicao de dados do usuario.

import UIKit
import Parse
import SwiftyDrop

class PacientesTableVC: UITableViewController,VSReachability {
    
    var predicate:NSPredicate = NSPredicate()
    
    var recordsParse:NSMutableArray = NSMutableArray()
    var recordsSearch: [AnyObject] = [AnyObject]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIRefreshControl
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Puxe para Atualizar...")
        //refreshControl.t = "Atualizar"
        self.refreshControl = refreshControl
        
        // BarButtun Right
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "add:")
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }else{
            let userName = PFUser.currentUser()?["username"] as? String

            // BarButtun Left
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "@\(userName!)", style: UIBarButtonItemStyle.Plain, target: self, action: "userScreen:")
            update()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Parse
    
    func update(){

        if self.isConnectedToNetwork(){
            if recordsParse.count == 0 {
                Drop.down("Baixando Dados", state: .Info)
                
                updateParse()
            }
        }else{
            Drop.down("Sem conexão com a Internet", state: DropState.Warning)
            self.refreshControl?.endRefreshing()
        }
        
        
    }
    
    func updateParse() {
        self.recordsParse.removeAllObjects()

        let query = PFQuery(className:"Paciente")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.orderByAscending("nome")
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.recordsParse.addObject(object)
                    }
                    
                }
                Drop.down("Dados baixados com sucesso!", state: DropState.Success)

                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            } else {
                self.refreshControl?.endRefreshing()
                Drop.down("Erro ao baixar dados. Verifique sua conexao e tente novamente mais tarde.", state: .Error)
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if recordsParse.count > 0 {
            return recordsParse.count
        }
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PacientesCell", forIndexPath: indexPath) as! PacientesTVCell
        
        if recordsParse.count == 0 {
            cell.nomeLabel.text = "Nome do Paciente"
            cell.dataNascimentoLabel.text = "Idade do Paciente"
            cell.thumbImageView.image = UIImage(named: "modelo_frontal")
            
            return cell
        }
        
        let cellDataParse:PFObject = self.recordsParse.objectAtIndex(indexPath.row) as! PFObject
        
        let nome = cellDataParse.objectForKey("nome") as! String
        let data_nascimento = dataFormatter().dateFromString(cellDataParse.objectForKey("data_nascimento") as! String)
        
        
        cell.nomeLabel.text = nome
        cell.dataNascimentoLabel.text = dataFormatter().stringFromDate(data_nascimento!)
        
        if let thumb_frontal = cellDataParse.objectForKey("thumb_frontal") as? PFFile{
            
            thumb_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil {
                    cell.activityIndicator.stopAnimating()
                    cell.thumbImageView.image  = UIImage(data: data!)!
                }
                
                }) { (progress) -> Void in
                    print(Float(progress))
            }
            
        }else{
            cell.activityIndicator.stopAnimating()
            cell.thumbImageView.image = UIImage(named: "modelo_frontal")
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if recordsParse.count > 0 {
            self.performSegueWithIdentifier("AUSegue", sender: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if recordsParse.count == 0 {
            return UITableViewCellEditingStyle.None
        }
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let dataParse:PFObject = self.recordsParse.objectAtIndex(indexPath.row) as! PFObject

        let btnDeletar = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Apagar" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            dataParse.deleteInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    Drop.down("Deletado com Sucesso", state: .Success)
                    self.recordsParse.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }else{
                    Drop.down("Erro ao deletar. Tente novamente mais tarde.", state: .Error)
                }
            })
            
        })
        
        return [btnDeletar]
        
    }
    
    
    
    // MARK: - Add Call
    
    func add(button: UIBarButtonItem){
        self.performSegueWithIdentifier("AUSegue", sender: nil)
    }
    
    func userScreen(button: UIBarButtonItem){
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let nav = segue.destinationViewController as! UINavigationController
        let controller = nav.topViewController as! AUPacienteVC
        if let indexPath:NSIndexPath = sender as? NSIndexPath {
            controller.type = "Update"
            
            let dataParse:PFObject = self.recordsParse.objectAtIndex(indexPath.row) as! PFObject
            controller.parseObject = dataParse
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
