//
//  MainNavigation.swift
//  EsteticaFacial
//
//  Created by Ricardo Freitas on 17/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import CoreData

class MainNavigation: UINavigationController,UITableViewDataSource {
    
    var pacientes = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Paciente")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            pacientes = results as! [NSManagedObject]
            var tabela = self.viewControllers[0] as? UITableViewController
            tabela?.tableView.dataSource = self
            tabela?.tableView.reloadData()
        } catch let error as NSError {
            print("Nao foi possivel carregar \(error), \(error.userInfo)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pacientes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("celula_paciente")
        
        let pessoa = pacientes[indexPath.row]
        
        var foto = cell?.viewWithTag(1) as? UIImageView
        var nome = cell?.viewWithTag(2) as? UILabel
        var sobrenome = cell?.viewWithTag(3) as? UILabel
        var etnia = cell?.viewWithTag(4) as? UILabel
        
        var data_foto = (pessoa.valueForKey("thumb_frontal") as? NSData)
        print("DATA \(data_foto)");
        if data_foto != nil{
            foto?.image = UIImage(data: data_foto!)!
           // print("FOTO \(foto)");
        }
        
        nome?.text = pessoa.valueForKey("nome") as? String
        sobrenome?.text = pessoa.valueForKey("sobrenome") as? String
        etnia?.text = pessoa.valueForKey("etnia") as? String
        
        return cell!
    }
}