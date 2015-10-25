//
//  ResetPasswordViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/31/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse
import SwiftyDrop


class ResetPasswordViewController: UIViewController, VSReachability{
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func passwordReset(sender: AnyObject) {
        if self.isConnectedToNetwork(){
            reset()
            
        }else{
            Drop.down("Sem conexão com a Internet.", state: DropState.Warning)
        }
    }
    
    func reset () {
        let email = self.emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if email.characters.count >= 8 {

            PFUser.requestPasswordResetForEmailInBackground(email)
        
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                SCLAlertView().showInfo("Atenção", subTitle: "Um email contendo infomação de como atualizar a senha foi enviada para \(email) .", closeButtonTitle: "OK")
            })
        }else {
            Drop.down("Insira um email valido.", state: DropState.Info)
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
        animateViewMoving(true, moveValue: 300)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 300)
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
