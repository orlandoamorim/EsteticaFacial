//
//  AjustesVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 17/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import Eureka
import Parse
import SwiftyDrop

class AjustesVC: FormViewController,VSReachability {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ajustes"
        initializeForm()
                // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    private func initializeForm() {
        
        form +++
            
            Section() {
                var header = HeaderFooterView<UserImage>(HeaderFooterProvider.NibFile(name: "UserImage", bundle: nil))
                header.onSetupView = { (view, section, form) -> () in
                    view.activityIndicator.startAnimating()
                    view.btnUserImage.alpha = 0;
                    UIView.animateWithDuration(2.0, animations: { [weak view] in
                        view?.btnUserImage.alpha = 1
                        })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animateWithDuration(1.0, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                        })

                    ParseConnection.getUserImage({ (data, error) -> Void in
                        if error == nil {
                            if data == nil {
                                view.activityIndicator.stopAnimating()
                                view.btnUserImage.setBackgroundImage(UIImage(named: "LabInC"), forState: UIControlState.Normal)

                            }else{
                                view.btnUserImage.setImage(UIImage(data: data!), forState: UIControlState.Normal)
                            }
                        }else{
                            Drop.down("Erro ao baixar imagem do usuario.", state: DropState.Warning)
                            view.activityIndicator.stopAnimating()
                        }
                        }, progressBlock: { (progress) -> Void in
                            if progress == 100 {
                                view.activityIndicator.stopAnimating()
                            }
                            
                    })

                }
                $0.header = header
                
            }
            
            <<< ButtonRow("userName") { (row: ButtonRow) in
                row.title = "@\(PFUser.currentUser()!.username!.lowercaseString)"
                row.cellStyle = UITableViewCellStyle.Default
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "userFavi-32")
                }.cellUpdate {
                    $0.cell.textLabel?.textAlignment = .Right
                }.onCellSelection({ (cell, row) -> () in
                    let alertController = UIAlertController(title: "Analise Facial", message: "Deseja sair do sistema?", preferredStyle: UIAlertControllerStyle.ActionSheet)
                    
                    alertController.addAction(UIAlertAction(title: "Sair", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                        if self.isConnectedToNetwork(){
                            Drop.down("Saindo", state: DropState.Info)
                            
                            // Send a request to log out a user
                            PFUser.logOut()
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                                
                                self.presentViewController(viewController, animated: true, completion: nil)
                            })
                            
                        }else{
                            Drop.down("Sem conexão com a Internet.", state: DropState.Warning)
                            row.baseValue = "@\(PFUser.currentUser()!.username!.lowercaseString)"
                        }
                    }))
                    
                    
                    alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = cell.frame
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            
    }
    
    
}

class UserImage: UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnUserImage: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    @IBAction func userImage(sender: UIButton) {
        print("seleconada")

    }
}



