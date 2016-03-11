//
//  ViewController.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 15/12/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//
import UIKit
import Parse
import ParseUI
import SwiftyDrop
import ParseFacebookUtilsV4
import ParseTwitterUtils

class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    let attributedString = NSAttributedString(string: "LabInC", attributes: [
        NSFontAttributeName : UIFont(name: "Pacifico", size: 40)!,
        NSForegroundColorAttributeName : UIColor.grayColor()
        ])
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil) {
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .SignUpButton, .Facebook]
            loginViewController.emailAsUsername = false
            loginViewController.signUpController?.emailAsUsername = false
            loginViewController.signUpController?.delegate = self
            self.presentViewController(loginViewController, animated: false, completion: nil)
        } else {
            presentLoggedInAlert()
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if (!username.isEmpty || !password.isEmpty) {
            return true
        }else {
            return false
        }
    }
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            if PFFacebookUtils.isLinkedWithUser(user) {
                FBSDKGraphRequest.init(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
                    if error == nil {
                        if PFUser.currentUser()!.username != result["name"]! as? String {
                            PFUser.currentUser()!.username = result["name"]! as? String
                            PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if error == nil {
                                    self.presentLoggedInAlert()
                                }
                            })
                        }else{
                            self.presentLoggedInAlert()
                        }
                    }
                })
            }else if PFTwitterUtils.isLinkedWithUser(user) {
                let twitterUsername = PFTwitterUtils.twitter()!.screenName
                
                if PFUser.currentUser()!.username != twitterUsername {
                    PFUser.currentUser()!.username = twitterUsername
                    PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil {
                            self.presentLoggedInAlert()
                        }
                    })
                }else{
                    self.presentLoggedInAlert()
                }
            }else{
                self.presentLoggedInAlert()
            }
        }


        
    }
    

    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {

        let alertController = UIAlertController(title: "", message: "Erro ao logar, verifique os dados inseridos ou se voce possui um conexão com internet ativa.", preferredStyle: .Alert)
        alertController.setValue(attributedString, forKey: "attributedTitle")
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(OKAction)
        logInController.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
            let alertController = UIAlertController(title: "", message: "Erro ao criar conta, verifique os dados inseridos ou se voce possui um conexão com internet ativa.", preferredStyle: .Alert)
            alertController.setValue(attributedString, forKey: "attributedTitle")
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(OKAction)
            signUpController.presentViewController(alertController, animated: true, completion: nil)
        
    }
    

    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.presentLoggedInAlert()
        })
        
    }
    
    func presentLoggedInAlert() {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("SegueApp", sender: nil)
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            
//        })
    }

}

