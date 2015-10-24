//
//  SignUpViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/30/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signUpAction(sender: AnyObject) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Validate the text fields
        if username!.characters.count < 5 {
            SCLAlertView().showInfo("Verificação de Dados", subTitle: "Nome de usuario deve possuir mais  que 5 caracteres", closeButtonTitle: "OK")
            
        } else if password!.characters.count < 8 {
            SCLAlertView().showInfo("Verificação de Dados", subTitle: "Senha deve possuir mais  que 8 caracteres", closeButtonTitle: "OK")
            
        } else if email!.characters.count < 8 {
            SCLAlertView().showInfo("Verificação de Dados", subTitle: "Insira um email valido.", closeButtonTitle: "OK")
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                    SCLAlertView().showError("Erro", subTitle: "\(error)", closeButtonTitle: "OK")
                    
                } else {
                    SCLAlertView().showSuccess("Sucesso", subTitle: "Cadastro realizado.", closeButtonTitle: "OK", duration: 3.0)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PacientesTableVC") 
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
