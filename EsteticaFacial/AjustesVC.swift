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
import ParseFacebookUtilsV4
import ParseTwitterUtils

class AjustesVC: FormViewController,VSReachability {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ajustes"
        initializeForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                    
                    if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                            let urlFoto = NSURL(string: "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/picture?type=large")!
                            let err: NSErrorPointer = nil
                            
                            let dataFoto: NSData?
                            do {
                                dataFoto = try NSData(contentsOfURL: urlFoto, options: NSDataReadingOptions())
                            } catch let error as NSError {
                                err.memory = error
                                dataFoto = nil
                                
                                view.activityIndicator.stopAnimating()
                                view.btnUserImage.setBackgroundImage(UIImage(named: "LabInC"), forState: UIControlState.Normal)
                            } catch {
                                fatalError()
                            }
                            let imagem: UIImage? = UIImage(data: dataFoto!)

                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                view.activityIndicator.stopAnimating()
                                view.btnUserImage.setImage(imagem, forState: UIControlState.Normal)
                            })
                        })
                        
                    }else if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()!) {
                        
                        let screenName = PFTwitterUtils.twitter()?.screenName!
                        let requestString = NSURL(string: "https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
                        let request = NSMutableURLRequest(URL: requestString!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
                        PFTwitterUtils.twitter()?.signRequest(request)
                        let session = NSURLSession.sharedSession()
                        
                        session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                            if error == nil {
                                var result: AnyObject?
                                do {
                                    result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                                } catch let error2 as NSError? {
                                    print("error 2 \(error2)")
                                }
                                
//                                print(result)
//                                let names: String! = result?.objectForKey("name") as! String
//                                let separatedNames: [String] = names.componentsSeparatedByString(" ")
//                                
                                //self.firstName = separatedNames.first!
                                //self.lastName = separatedNames.last!
                                
                                let urlString = result?.objectForKey("profile_image_url_https") as! String
                                let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                let twitterPhotoUrl = NSURL(string: hiResUrlString)
                                let imageData = NSData(contentsOfURL: twitterPhotoUrl!)
                                let twitterImage: UIImage! = UIImage(data:imageData!)
                                view.activityIndicator.stopAnimating()
                                view.btnUserImage.setImage(twitterImage, forState: UIControlState.Normal)
                            }else{
                                view.activityIndicator.stopAnimating()
                                view.btnUserImage.setBackgroundImage(UIImage(named: "LabInC"), forState: UIControlState.Normal)
                            }
                        }).resume()
                    }else{
                        ParseConnection.getUserImage({ (data, error) -> Void in
                            if error == nil {
                                if data == nil {
                                    view.activityIndicator.stopAnimating()
                                    view.btnUserImage.setBackgroundImage(UIImage(named: "LabInC"), forState: UIControlState.Normal)
                                    
                                }else{
                                    view.activityIndicator.stopAnimating()
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
                }
                $0.header = header
                
            }
            
            <<< ButtonRow("userName") { (row: ButtonRow) in
                row.title = "@\(PFUser.currentUser()!.username!.lowercaseString)"
                row.cellStyle = UITableViewCellStyle.Default
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "userFavi-32")
//                    if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
//                        FBSDKGraphRequest.init(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
//                            if error == nil {
//                                self.form.rowByTag("userName")?.title = result["name"]! as? String
//                                self.form.rowByTag("userName")?.updateCell()
//                            }
//                        })
//                    }
                    
                }.cellUpdate {
                    $0.cell.textLabel?.textAlignment = .Right
                }.onCellSelection({ (cell, row) -> () in
                    let alertController = UIAlertController(title: "Analise Facial", message: "Deseja sair do sistema?", preferredStyle: UIAlertControllerStyle.ActionSheet)
                    
                    alertController.addAction(UIAlertAction(title: "Sair", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                        if self.isConnectedToNetwork(){
                            Drop.down("Saindo", state: DropState.Info)
                            
                            // Send a request to log out a user
                            PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                                if error == nil {
                                    PFQuery.clearAllCachedResults()
                                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                                    
                                    self.presentViewController(viewController, animated: true, completion: nil)
                                }else{
                                    Drop.down("Erro ao sair.", state: DropState.Warning)
                                    row.baseValue = "@\(PFUser.currentUser()!.username!.lowercaseString)"
                                }
                            })

                            
                        }else{
                            Drop.down("Sem conexão com a Internet.", state: DropState.Warning)
                            row.baseValue = "@\(PFUser.currentUser()!.username!.lowercaseString)"
                        }
                    }))
                    
                    
                    alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    alertController.popoverPresentationController?.sourceView = cell
                    alertController.popoverPresentationController?.sourceRect = cell.bounds
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            
    }
}

extension AjustesVC {
    func showAlert() {
    let alert:UIAlertController = UIAlertController(title: "Alterar Imagem", message: "Sua imagem nao pode ser alterada porque sua conta esta atrelada ao FaceBook.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
        
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            AjustesVC().showAlert()
        }

    }
}



