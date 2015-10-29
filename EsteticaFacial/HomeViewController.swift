//
//  HomeViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/31/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse
import SwiftyDrop

class HomeViewController: UIViewController,VSReachability{
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var btnSair: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Show the current visitor's username
        if let pUserName = PFUser.currentUser()?["username"] as? String {
            self.userNameLabel.text = "@" + pUserName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func logOutAction(sender: AnyObject){
        if self.isConnectedToNetwork(){
            // Send a request to log out a user
            PFUser.logOut()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                
                self.presentViewController(viewController, animated: true, completion: nil)
            })
            
        }else{
            Drop.down("Sem conexão com a Internet.", state: DropState.Warning)
        }  
    }
    
    @IBAction func dismis(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func carregarImagemUsuario(sender: UITapGestureRecognizer) {
        
        
    }
    
    
}
