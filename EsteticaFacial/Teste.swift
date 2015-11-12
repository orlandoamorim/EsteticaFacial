//
//  Teste.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 26/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import Foundation



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
        