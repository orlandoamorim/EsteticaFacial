//
//  PacientesTableVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 22/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

// Segue Name : UpdateSegue -> Atualiza os dados.
//              AddSegue    -> Add dados.

import UIKit
import Parse
import SwiftyDrop

class PacientesTableVC: UITableViewController,VSReachability, UISplitViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var recordsParse:NSMutableArray = NSMutableArray()
    var recordsSearch: [AnyObject] = [AnyObject]()
    
    var maxCount: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adição para funcionar melhor no iPad
        self.splitViewController!.delegate = self
        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        
        // UIRefreshControl
        let refreshControl:UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Puxe para Atualizar...")
        //refreshControl.t = "Atualizar"
        self.refreshControl = refreshControl

        // BarButtun Right
        
        let addBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "add:")
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        
        self.navigationItem.rightBarButtonItems = [addBtn, refreshBtn]
        
        let userAcount = UIBarButtonItem(image: UIImage(named: "user-22"), style: UIBarButtonItemStyle.Plain, target: self, action: "userScreen:")
        
        let settings = UIBarButtonItem(image: UIImage(named: "Settings-22"), style: UIBarButtonItemStyle.Plain, target: self, action: "settings:")
        
        self.navigationItem.leftBarButtonItems = [userAcount, settings]

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }else{
            //[yourScrollView(or tableView) setContentOffset:CGPointMake(0.0f, -60.0f)animated:YES];
            tableView.setContentOffset(CGPoint(x: 0, y: -150), animated: true)
            //150
            
            self.refreshControl?.beginRefreshing()
            update()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Parse
    
    func update(){
        
        if self.isConnectedToNetwork(){
            updateParse()
            
        }else{
            Drop.down("Sem conexão com a Internet", state: DropState.Warning)
            self.refreshControl?.endRefreshing()
        }
    }
    
    func updateParse() {
        maxCount = 0
        let query = PFQuery(className:"Paciente")
        print(PFUser.currentUser()!.username!)
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error == nil {
                self.maxCount = Int(count)
                
                if self.maxCount > self.recordsParse.count {
                    self.recordsParse.removeAllObjects()
                    
                    query.orderByAscending("nome")
                    query.findObjectsInBackgroundWithBlock {
                        (objects:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            if let objects = objects {
                                for object in objects {
                                    self.recordsParse.addObject(object)
                                }
                                
                            }
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        } else {
                            self.refreshControl?.endRefreshing()
                            
                            let errorCode = error!.code
                            
                            switch errorCode {
                            case 100:
                                Drop.down("Erro ao baixar dados. Verifique sua conexao e tente novamente mais tarde.", state: .Error)
                                break
                            case 101:
                                Drop.down("Erro ao baixar dados. Objetos nao encontrados.", state: .Error)
                                break
                            case 209:
                                // Send a request to log out a user
                                PFUser.logOut()
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                                    
                                    self.presentViewController(viewController, animated: true, completion: nil)
                                })
                                break
                            default:
                                break
                            }


                        }
                    }
                }else {
                    self.refreshControl?.endRefreshing()
                }
            }else{
                self.refreshControl?.endRefreshing()

                let errorCode = error!.code
                
                switch errorCode {
                case 100:
                    Drop.down("Erro ao baixar dados. Verifique sua conexao e tente novamente mais tarde.", state: .Error)
                    break
                case 101:
                    Drop.down("Erro ao baixar dados. Objetos nao encontrados.", state: .Error)
                    break
                case 209:
                    // Send a request to log out a user
                    PFUser.logOut()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                        
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                    break
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Add Call
    
    func refresh(button: UIBarButtonItem){
        
        if self.isConnectedToNetwork(){
            
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
                        self.maxCount = objects.count
                    }
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                } else {
                    self.refreshControl?.endRefreshing()
                    
                    let errorCode = error!.code
                    
                    switch errorCode {
                    case 100:
                        Drop.down("Erro ao baixar dados. Verifique sua conexao e tente novamente mais tarde.", state: .Error)
                        break
                    case 101:
                        Drop.down("Erro ao baixar dados. Objetos nao encontrados.", state: .Error)
                        break
                    case 209:
                        // Send a request to log out a user
                        PFUser.logOut()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                            
                            self.presentViewController(viewController, animated: true, completion: nil)
                        })
                        break
                    default:
                        break
                    }
                }
            }

            
        }else{
            Drop.down("Sem conexão com a Internet", state: DropState.Warning)
        }
        
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if recordsParse.count > 0 {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.tableView.backgroundView?.hidden = true
            return 1
        }
        
        let messageLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        messageLabel.text = "Nenhum dado de paciente disponivel. Por favor, puxe para baixo para atualizar. "
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 5
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        messageLabel.sizeToFit()
        
        self.tableView.backgroundView = messageLabel
        self.tableView.backgroundView?.hidden = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if recordsParse.count > 0 {
            return recordsParse.count
        }
        return 0
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
            self.performSegueWithIdentifier("UpdateSegue", sender: indexPath)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "UpdateSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! AUPacienteVC
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                controller.type = "Update"
                
                let dataParse:PFObject = self.recordsParse.objectAtIndex(indexPath.row) as! PFObject
                controller.parseObject = dataParse
                
            }
        }else if segue.identifier == "AddSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! AUPacienteVC
            controller.type = "Add"
        }else if segue.identifier == "UserSegue" || segue.identifier == "SettingsSegue" {
            let popoverViewController = segue.destinationViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
    }
    
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if recordsParse.count == 0 {
            return UITableViewCellEditingStyle.None
        }
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //Criando um objeto do tipo NSNOtitcationCenter
            
            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
            //ENVIANDO os dados por Object
            centroDeNotificacao.postNotificationName("mostrarAviso", object: nil)
            
            let dataParse:PFObject = self.recordsParse.objectAtIndex(indexPath.row) as! PFObject
            let nome = dataParse.objectForKey("nome") as! String
            
            Drop.down("Deletando ficha do paciente \(nome)", state: .Info)
            
            if recordsParse.count == 1 {
                self.recordsParse.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            }else {
                self.recordsParse.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            
            
            dataParse.deleteInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    Drop.down("Ficha deletada com Sucesso.", state: .Success)
                }else{
                    Drop.down("Erro ao deletar. Tente novamente mais tarde.", state: .Error)
                }
            })
        }
    }
    
    // MARK: - Add Call
    
    func add(button: UIBarButtonItem){
        self.performSegueWithIdentifier("AddSegue", sender: nil)
    }
    
    // MARK: - Mostra a tela com os dados do usuario (opcao de deslogar)
    
    func userScreen(button: UIBarButtonItem){
        self.performSegueWithIdentifier("UserSegue", sender: nil)
    }
    
    // MARK: - Mostra a tela de configuração
    
    func settings(button: UIBarButtonItem){
        self.performSegueWithIdentifier("SettingsSegue", sender: nil)
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
    
    // MARK: - UISplitViewControllerDelegate
    //Adição para funcionar melhor no iPad
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        
        return true
        
    }
}
