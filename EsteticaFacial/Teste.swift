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