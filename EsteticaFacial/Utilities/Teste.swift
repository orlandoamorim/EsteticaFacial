//
//  Teste.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 26/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

//import Foundation

//@NSManaged var data_adicao: NSDate?
//@NSManaged var etnia: String?
//@NSManaged var img_frontal: NSData?
//@NSManaged var img_nasal: NSData?
//@NSManaged var img_perfil: NSData?
//@NSManaged var nascimento: NSDate?
//@NSManaged var nome: String?
//@NSManaged var notas: String?
//@NSManaged var pontos_frontal: NSData?
//@NSManaged var pontos_nasal: NSData?
//@NSManaged var pontos_perfil: NSData?
//@NSManaged var relatorio: String?
//@NSManaged var sexo: String?
//@NSManaged var thumb_frontal: NSData?
//@NSManaged var thumb_nasal: NSData?
//@NSManaged var thumb_perfil: NSData?



//// MARK: - UISearchBar
//
//func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//    
//    //Se o texto retornado for vazio faz a fetch request promissa(pega tudo) e retorna  da funcao
//    if searchText.isEmpty{
//        update()
//        return
//    }
//    
//    let query = PFQuery(className:"Paciente")
//    query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//    query.orderByAscending("nome")
//    
//    
//    switch searchBar.selectedScopeButtonIndex {
//    case 0:
//        let nomeQuery = PFQuery(className:"Paciente")
//        nomeQuery.whereKey("nome", containsString: searchBar.text)
//        
//        let sexoQuery = PFQuery(className:"Paciente")
//        sexoQuery.whereKey("sexo", containsString: searchBar.text)
//        
//        let etniaQuery = PFQuery(className:"Paciente")
//        etniaQuery.whereKey("etnia", containsString: searchBar.text)
//        
//        let dataNascimentoQuery = PFQuery(className:"Paciente")
//        dataNascimentoQuery.whereKey("data_ascimento", containsString: searchBar.text)
//        
//        let emailQuery = PFQuery(className:"Paciente")
//        emailQuery.whereKey("email", containsString: searchBar.text)
//        
//        
//        self.recordsParse.removeAllObjects()
//        
//        let query = PFQuery.orQueryWithSubqueries([nomeQuery,sexoQuery,etniaQuery,dataNascimentoQuery,emailQuery])
//        query.orderByAscending("nome")
//        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//        
//        query.findObjectsInBackgroundWithBlock {
//            (objects:[PFObject]?, error:NSError?) -> Void in
//            if error == nil {
//                if let objects = objects {
//                    for object in objects {
//                        self.recordsParse.addObject(object)
//                    }
//                    
//                }
//                Drop.down("Dados baixados com sucesso!", state: DropState.Success)
//                
//                self.tableView.reloadData()
//                self.refreshControl?.endRefreshing()
//            } else {
//                self.refreshControl?.endRefreshing()
//                Drop.down("Erro ao baixar dados. Verifique sua conexao e tente novamente mais tarde.", state: .Error)
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
//        
//        
//    default: break
//        
//    }
//}
//
//
//func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//    //        navigationController?.setNavigationBarHidden(false, animated: true)
//    searchBar.text = ""
//    searchBar.resignFirstResponder()
//    update()
//}
//
//func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//    //        navigationController?.setNavigationBarHidden(true, animated: true)
//}
//
//}



//            self.refreshControl?.beginRefreshing()
//            self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y - (self.refreshControl?.frame.size.height)!), animated: true)


//==============================================================================================


//
//        if let nome = self.form.rowByTag("nome")?.baseValue as? String {
//            if type == "Adicionando" {
//                parseObject["nome"] = nome
//            }else if type == "Atualizando" {
//
//            }
//        }else{
//            alertView?.close()
//            alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio nome nao foi preenchido", closeButtonTitle: "OK")
//            return
//        }
//
//        if let sexo = self.form.rowByTag("sexo")?.baseValue as? String {
//            print(sexo)
//        }else{
//            alertView?.close()
//            alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio sexo nao foi preenchido", closeButtonTitle: "OK")
//            return
//        }
//
//        if let etnia = self.form.rowByTag("etnia")?.baseValue as? String {
//            print(etnia)
//        }else{
//            alertView?.close()
//            alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio etnia nao foi preenchido", closeButtonTitle: "OK")
//            return
//        }
//
//        if let data_nascimento = self.form.rowByTag("data_nascimento")?.baseValue as? NSDate {
//            print(data_nascimento)
//        }else{
//            alertView?.close()
//            alertView? = SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio data nascimento nao foi preenchido", closeButtonTitle: "OK")
//            return
//        }
//
//        if let email = self.form.rowByTag("email")?.baseValue as? String {
//            print(email)
//        }
//
//        if let telefone = self.form.rowByTag("telefone")?.baseValue as? String {
//            print(telefone)
//        }
//
//        if let cirurgia_realizada = self.form.rowByTag("cirurgia_realizada")?.baseValue as? Bool {
//            print(cirurgia_realizada)
//        }

//
//<<< ButtonRow("userName") { (row: ButtonRow) in
//    row.title = "@\(PFUser.currentUser()!.username!.lowercaseString)"
//    row.cellStyle = UITableViewCellStyle.Default
//    row.presentationMode = .SegueName(segueName: "UserSegue", completionCallback: nil)
//    }.cellSetup { cell, row in
//        cell.imageView?.image = UIImage(named: "userFavi-32")
//    }.cellUpdate {
//        $0.cell.textLabel?.textAlignment = .Right
//}

//
//internal func rotate() {
//    let rotation = currentRotation()
//    let rads = CGFloat(radians(rotation))
//    
//    UIView.animateWithDuration(0.3) {
//        //            self.cameraBtn.transform = CGAffineTransformMakeRotation(rads)
//        //            self.libraryImages.transform = CGAffineTransformMakeRotation(rads)
//        //            self.cancelBtn.transform = CGAffineTransformMakeRotation(rads)
//        self.cameraView.subviews.forEach ({
//            if $0 is UIImageView {
//                $0.transform = CGAffineTransformMakeRotation(rads)
//            }
//        })
//        
//    }
//}
//
//internal func radians(degrees: Double) -> Double {
//    return degrees / 180 * M_PI
//}
//
//internal func currentRotation() -> Double {
//    var rotation: Double = 0
//    
//    if UIDevice.currentDevice().orientation == .LandscapeLeft {
//        rotation = 90
//    } else if UIDevice.currentDevice().orientation == .LandscapeRight {
//        rotation = 270
//    } else if UIDevice.currentDevice().orientation == .PortraitUpsideDown {
//        rotation = 180
//    }
//    
//    return rotation
//}
//
//
//if SyncType as! String == "LabInCloud" {
//}else if SyncType as! String == "iCloud" {
//}else if SyncType as! String == "Dropbox" {
//}else if SyncType as! String == "GoogleDrive" {
//}else if SyncType as! String == "OneDrive" {
//}


//                if let pontos_nasal = object.objectForKey("pontos_nasal") as? PFFile{
//
//                    pontos_nasal.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                        if error == nil {
//                            print("nasal")
//                            print(NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [String : NSValue])
//                            try! realm.write {
//                                realm.create(Image.self, value: ["id": nasalID, "points": data!], update: true)
//                            }
//                        }
//                    })
//                }