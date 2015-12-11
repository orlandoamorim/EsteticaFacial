//
//  PacientesTableVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 22/10/15.
//  Copyright © 2015 UFPI. All rights reserved.
//

// Segue Name : UpdateSegue -> Atualiza os dados.
//              AddSegue    -> Add dados.

import UIKit
import Parse
import SwiftyDrop

class PacientesTableVC: UITableViewController,VSReachability, UISplitViewControllerDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var pacientesPopBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
//    var recordsParse:NSMutableArray = NSMutableArray()
    var recordsSearch: [AnyObject] = [AnyObject]()
    var recordsDicAtoZ:[String : [AnyObject]] = [String : [AnyObject]]()
    
    
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "add:")
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if recordsDicAtoZ.count > 0 {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.tableView.backgroundView?.hidden = true
            return recordsDicAtoZ.keys.count
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if recordsDicAtoZ.count > 0 {
            let key = Array(recordsDicAtoZ.keys.sort())[section]
            return key.uppercaseString as String
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recordsDicAtoZ.count > 0 {
            let key = Array(recordsDicAtoZ.keys.sort())[section]
            let objects = recordsDicAtoZ[key]!
            
            return objects.count
        }
        return 0
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return Array(recordsDicAtoZ.keys.sort())
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PacienteCell", forIndexPath: indexPath)
        
        cell.imageView!.clipsToBounds = true
        cell.imageView!.layer.borderWidth = 1.0
        cell.imageView!.layer.borderColor = UIColor.darkGrayColor().CGColor
        cell.imageView!.layer.cornerRadius = 10.0
        
        let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
        let object = recordsDicAtoZ[key]!
        
        let cellDataParse:PFObject = object[indexPath.row] as! PFObject
        
        let nome = cellDataParse.objectForKey("nome") as! String
        
        let data_nascimento = Helpers.dataFormatter(dateFormat:"dd/MM/yyyy" , dateStyle: NSDateFormatterStyle.ShortStyle).dateFromString(cellDataParse.objectForKey("data_nascimento") as! String)
        
        cell.textLabel!.text = nome
        cell.detailTextLabel!.text = Helpers.dataFormatter(dateFormat:"dd/MM/yyyy" , dateStyle: NSDateFormatterStyle.ShortStyle).stringFromDate(data_nascimento!)
        
        if let thumb_frontal = cellDataParse.objectForKey("thumb_frontal") as? PFFile{
            
            thumb_frontal.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil {
                    cell.imageView!.image  = UIImage(data: data!)!
                }
                
                }) { (progress) -> Void in
                    print(Float(progress))
            }
            
        }else{
            cell.imageView!.image = UIImage(named: "modelo_frontal")
        }
        
        
        return cell
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
    
    // MARK: - DetailDisclosureButton
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let meuAlertSheet: UIAlertController = UIAlertController(title: "DocReminder", message: "Escolha umas das opções abaixo.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let btnRealizada: UIAlertAction = UIAlertAction(title: "Cirurgia Realizada", style: UIAlertActionStyle.Default) { (action) -> Void in
            let key = Array(self.recordsDicAtoZ.keys.sort())[indexPath.section]
            let object = self.recordsDicAtoZ[key]!
            
            let parseObject:PFObject = object[indexPath.row] as! PFObject
            parseObject["cirurgia_realizada"] = true
            
            parseObject.saveInBackgroundWithBlock({ (seccess, error) -> Void in
                if error == nil {
                    Drop.down("Atualizada com sucesso", state: .Success)
                    self.update()
                }else{
                    Drop.down("Erro atualizar a ficha.", state: .Error)
                }
            })
        }
        
        
        let btnCompartilhar: UIAlertAction = UIAlertAction(title: "Compartilhar 🔃", style: UIAlertActionStyle.Default) { (action) -> Void in
            if self.recordsDicAtoZ.keys.count > 0 {
                let key = Array(self.recordsDicAtoZ.keys.sort())[indexPath.section]
                let object = self.recordsDicAtoZ[key]!
                
                let parseObject:PFObject = object[indexPath.row] as! PFObject
                Helpers.compartilharFicha(parseObject, VC: self)
            }
        }
        
        
        let btnCancelar: UIAlertAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
        
        meuAlertSheet.addAction(btnRealizada)
        meuAlertSheet.addAction(btnCompartilhar)
        meuAlertSheet.addAction(btnCancelar)
        
        self.presentViewController(meuAlertSheet, animated: true, completion: nil)
    }
    
    
    // MARK: - prepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "UpdateSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! AUFichaVC
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                controller.contentToDisplay = .Atualizar
                let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
                let object = recordsDicAtoZ[key]!
                
                let dataParse:PFObject = object[indexPath.row] as! PFObject
                controller.parseObject = dataParse
                
            }
        }else if segue.identifier == "AddSegue" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! AUFichaVC
            controller.contentToDisplay = .Adicionar
        }
//        else if segue.identifier == "PopOverSegue" {
//            let popoverViewController = segue.destinationViewController as! MostrarCirurgiasVC
//            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
//            popoverViewController.popoverPresentationController!.delegate = self
//            popoverViewController.popoverPresentationController!.sourceRect = pacientesPopBtn!.bounds
//            popoverViewController.popoverPresentationController!.sourceView = pacientesPopBtn
//        }
    }
    
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if recordsDicAtoZ.keys.count == 0 {
            return UITableViewCellEditingStyle.None
        }
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //Criando um objeto do tipo NSNOtitcationCenter
            
            let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
            //ENVIANDO os dados por Object
            centroDeNotificacao.postNotificationName("noData", object: nil)
            
            let key = Array(recordsDicAtoZ.keys.sort())[indexPath.section]
            let object = recordsDicAtoZ[key]!
            
            let dataParse:PFObject = object[indexPath.row] as! PFObject
            let nome = dataParse.objectForKey("nome") as! String
            
            Drop.down("Deletando ficha do paciente \(nome)", state: .Info)
            
            if recordsDicAtoZ.keys.count == 1 && object.count == 1 {
                self.recordsDicAtoZ.removeAll(keepCapacity: false)
                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            }else if object.count == 1{
                self.recordsDicAtoZ.removeValueForKey(key)
                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
                
            }else {
                self.recordsDicAtoZ[key]!.removeAtIndex(indexPath.row)
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
    
    
    // MARK: - UISearch
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.searchBar = searchBar
        self.recordsDicAtoZ.removeAll(keepCapacity: false)
        self.update()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text)
        self.recordsDicAtoZ.removeAll(keepCapacity: false)
        
        let nome = PFQuery(className:"Paciente")
        nome.whereKey("nome", containsString: searchText)
        
        let data_nascimento = PFQuery(className:"Paciente")
        data_nascimento.whereKey("data_nascimento", containsString: searchText)
        
        let notas = PFQuery(className:"Paciente")
        notas.whereKey("notas", containsString: searchText)
        
        let query = PFQuery.orQueryWithSubqueries([nome, data_nascimento,notas])
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.recordsDicAtoZ = Helpers.dicAtoZ(objects)
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
    }
    
    
    
    // MARK: - Add Call
    
    func add(button: UIBarButtonItem){
        self.performSegueWithIdentifier("AddSegue", sender: nil)
    }
    
    
    // MARK: - UISplitViewControllerDelegate
    //Adição para funcionar melhor no iPad
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    @IBAction func switchTipo(sender: UIButton) {
        
        var todas = "Todas as Fichas"
        var realizadas = "Realizadas"
        var nao_realizadas = "Não Realizadas"
        
        switch Helpers.verificaSwitch() {
        case "realizadas":
            realizadas = "Realizadas ⚡️"
            print("realizadas")
        case "nao_realizadas":
            nao_realizadas = "Não Realizadas ⚡️"
            print("nao_realizadas")
            
        default:
            todas = "Todas as Fichas ⚡️"

        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        let alertController = UIAlertController(title: "Analise Facial", message: "Qual tipo de conteudo deseja carregar?", preferredStyle: UIAlertControllerStyle.ActionSheet)

        
        alertController.addAction(UIAlertAction(title: todas, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            userDefaults.setValue("todas", forKey: "switchCT")
            userDefaults.synchronize()
            self.update()
        }))
        
        alertController.addAction(UIAlertAction(title: realizadas, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            userDefaults.setValue("realizadas", forKey: "switchCT")
            userDefaults.synchronize()
            self.update()
        }))
        
        alertController.addAction(UIAlertAction(title: nao_realizadas, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            userDefaults.setValue("nao_realizadas", forKey: "switchCT")
            userDefaults.synchronize()
            self.update()
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = sender.bounds
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Parse Connection
    
    func update(){
        
        if self.isConnectedToNetwork(){
            updateParse()
            
        }else{
            Drop.down("Sem conexão com a Internet", state: DropState.Warning)
            self.refreshControl?.endRefreshing()
        }
    }
    

    func updateParse() {
        self.recordsDicAtoZ.removeAll(keepCapacity: false)
        
        ParseConnection.getAllFromParse { (objects, error) -> Void in
            if error == nil {
                if let objects = objects {
                    self.recordsDicAtoZ = Helpers.dicAtoZ(objects)
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
                    PFQuery.clearAllCachedResults()
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
    


}
