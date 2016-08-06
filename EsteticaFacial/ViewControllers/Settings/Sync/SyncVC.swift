//
//  SyncVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 16/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import Eureka
import SwiftyDropbox

class SyncVC: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sync"
        // Do any additional setup after loading the view.
        setSync()
        self.initializeForm()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeForm() {
        
        form +++
            
            
            Section(header: "Recuperar dados do servidor", footer: "Esta operação não pode ser desfeita e pode demorar alguns minutos.")
            
            <<< SwitchRow("LabInCloud") {
                $0.title = "LabInCloud"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "CloudStorage")
            }.onChange({ (row) in
                if row.value == true {
                    let alert = UIAlertController(title: "Atenção", message: "Esta operação não pode ser desfeita, proceda com cautela.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Prosseguir", style: UIAlertActionStyle.Default, handler: { (alert) in
                        self.labInCloud()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: { (alert) in
                        row.value = false
                        row.updateCell()
                    }))
                    if self.setSync() != "LabInCloud" {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            })
            
            +++ Section(header: "", footer: "")
            
            <<< SwitchRow("iCloud") {
                $0.title = "iCloud"
                $0.disabled = true
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "iCloud")
            }
        
            +++ Section(header: "", footer: "")
            
            <<< SwitchRow("Dropbox") {
                $0.title = "Dropbox"
                $0.disabled = false
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "Dropbox")
                    if Dropbox.authorizedClient != nil {
                        row.baseValue = true
                    }else{
                        row.baseValue = false
                    }
                    
                }.onChange({ (switchRow) in
                    if switchRow.value == true {
                        if Dropbox.authorizedClient == nil {
                            Dropbox.authorizeFromController(self)
                        }
                    }else if switchRow.value == false {
                        if Dropbox.authorizedClient != nil {
                            RealmParse.cloud.cloudLogOut(completionHandler: { (cloudUpdated, error) in
                                if error != nil {
                                    self.form.rowByTag("Dropbox")?.baseValue = true
                                    self.form.rowByTag("Dropbox")?.updateCell()
                                }else {
                                    if cloudUpdated == false {
                                        let alert = UIAlertController(title: "Atenção" , message: "Verificamos que alguns registros ainda não estão sincronizados com o seu Dropbox. O que deseja fazer?", preferredStyle: .Alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Sincronizar com o Dropbox", style: .Default, handler: { (action) in
                                            RealmParse.cloud.sync()
                                            self.form.rowByTag("Dropbox")?.baseValue = true
                                            self.form.rowByTag("Dropbox")?.updateCell()
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: "Prosseguir sem sincronizar", style: .Default, handler: { (action) in
                                            RealmParse.cloud.cloudLogOut(true, completionHandler: { (cloudUpdated, error) in
                                                if error != nil {
                                                    if cloudUpdated == true {
                                                        Dropbox.unlinkClient()
                                                        self.form.rowByTag("Dropbox")?.baseValue = false
                                                        self.form.rowByTag("Dropbox")?.updateCell()
                                                    }
                                                }
                                            })
                                            
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) in
                                            self.form.rowByTag("Dropbox")?.baseValue = true
                                            self.form.rowByTag("Dropbox")?.updateCell()
                                        }))
                                        
                                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                                    }else {
                                        Dropbox.unlinkClient()
                                        let alert = UIAlertController.alertControllerWithTitle("Deslogado com Sucesso", message: "")
                                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                                    }
                                }
                            })
                        }
                    }
                })
        
            +++ Section(header: "", footer: "")
            
            <<< SwitchRow("GoogleDrive") {
                $0.title = "Google Drive"
                $0.disabled = true
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "GoogleDrive")
            }
        
            +++ Section(header: "", footer: "")
            
            <<< SwitchRow("OneDrive") {
                $0.title = "OneDrive"
                $0.disabled = true
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "Skydrive")
            }
    }

    internal func setSync() -> String? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("SyncType") != nil {
            let SyncType = userDefaults.valueForKey("SyncType")
            if SyncType as! String == "LabInCloud" {
                form.rowByTag("LabInCloud")?.baseValue = true
                form.rowByTag("LabInCloud")?.updateCell()
                form.rowByTag("LabInCloud")?.disabled = true
                form.rowByTag("LabInCloud")?.evaluateDisabled()
                return "LabInCloud"
            }else if SyncType as! String == "iCloud" {
                form.rowByTag("iCloud")?.baseValue = true
                form.rowByTag("iCloud")?.updateCell()
                return "iCloud"
            }else if SyncType as! String == "Dropbox" {
                form.rowByTag("Dropbox")?.baseValue = true
                form.rowByTag("Dropbox")?.updateCell()
                return "Dropbox"
            }else if SyncType as! String == "GoogleDrive" {
                form.rowByTag("GoogleDrive")?.baseValue = true
                form.rowByTag("GoogleDrive")?.updateCell()
                return "GoogleDrive"
            }else if SyncType as! String == "OneDrive" {
                form.rowByTag("OneDrive")?.baseValue = true
                form.rowByTag("OneDrive")?.updateCell()
                return "OneDrive"
            }
        }
        
        return nil
    }
    
    private func labInCloud(){
        let progressView = UIProgressView(progressViewStyle: .Bar)
        progressView.setProgress(1.0, animated: true)
        self.navigationController?.progress(progressView)
        
        
        let alert = UIAlertController(title: "LabInCloud", message: "Efetue login na sua conta.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (username) in
            username.placeholder = "Nome de Usuario"
        }
        
        alert.addTextFieldWithConfigurationHandler { (password) in
            password.placeholder = "Senha"
            password.secureTextEntry = true

        }
        
        alert.addAction(UIAlertAction(title: "Logar", style: UIAlertActionStyle.Default, handler: { (login) in
            let username = alert.textFields![0]
            let password = alert.textFields![1]
            if username.text == "" || password.text == "" {
                self.labInCloud()
            }else{
                LabInCloud.login(username.text!, password: password.text!, view: self)
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
