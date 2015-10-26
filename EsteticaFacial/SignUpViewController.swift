//
//  SignUpViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/30/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse
import SwiftyDrop

class SignUpViewController: UIViewController, VSReachability {
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
        if self.isConnectedToNetwork(){
            signUp()
            
        }else{
            Drop.down("Sem conexão com a Internet.", state: DropState.Warning)
        }
    }
    
    func signUp(){
        
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
                if ((error) != nil) {
                    Drop.down("Verifique os dados inseridos.", state: DropState.Error)
                    
                } else {
                    spinner.stopAnimating()

                    SCLAlertView().showSuccess("Sucesso", subTitle: "Cadastro realizado.", closeButtonTitle: "OK", duration: 3.0)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PacientesTableVC")
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    // MARK: - Dismiss no teclado
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.becomeFirstResponder()
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }

}
