//
//  Settings.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 29/03/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import Eureka
import PasscodeLock

class SettingsTableVC: FormViewController {

    var ativada:Int = Int()
    var appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
    
    private let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Configurações"

        initializeForm()
        
        verificaNotificacao()
        //PacientSegue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        
        
        form.rowByTag("password")?.baseValue = hasPasscode
        form.rowByTag("password")?.updateCell()
        self.tableView?.reloadData()

    }
    
    
    private func initializeForm() {
        
        DateInlineRow.defaultRowInitializer = { row in row.maximumDate = NSDate() }
        
        form +++
            
            
            Section()
            
            <<< ButtonRow("btn_show_cloud") { (row: ButtonRow) -> Void in
                row.title = "Sync"
                row.disabled = true
                row.presentationMode = PresentationMode.SegueName(segueName: "Sync", completionCallback: nil)
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "cloud")
            }
            
            +++ Section(header: "", footer: "Adiciomanos isto para dar mais segurança ao app.")
            
            <<< SwitchRow("password") {
                $0.title = "Password"
                $0.value = configuration.repository.hasPasscode
                }.onChange { [weak self] in
                    
                    let passcodeVC: PasscodeLockViewController
                    
                    if $0.value == true {
                        
                        passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: self!.configuration)
                        self!.presentViewController(passcodeVC, animated: true, completion: nil)
                        
                    } else {
                        
                        passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: self!.configuration)
                        self!.presentViewController(passcodeVC, animated: true, completion: nil)

                        passcodeVC.successCallback = { lock in
                            
                            lock.repository.deletePasscode()
                            self?.form.rowByTag("changePassword")?.hidden = true
                            self?.form.rowByTag("changePassword")?.updateCell()
                        }
                        
                        passcodeVC.dismissCompletionCallback = {
                            print("Dismiss or Change")
                        }

                    }
            }
        
            <<< LabelRow ("changePassword") {
                $0.title = "Mudar a senha?"
                $0.hidden = "$password == false"
                }.onCellSelection({ (_, _) in
                    let repo = UserDefaultsPasscodeRepository()
                    let config = PasscodeLockConfiguration(repository: repo)
                    
                    let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
                    
                    self.presentViewController(passcodeLock, animated: true, completion: nil)
                })
            +++ Section(header: "", footer: "Beta para proximas atualizações.")
            
            <<< ButtonRow("btn_show_patients") { (row: ButtonRow) -> Void in
                row.title = "Pacientes"
                row.presentationMode = PresentationMode.SegueName(segueName: "PacientsSegue", completionCallback: nil)
                }
//                .cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "Beta")
//        }
   
    }
    

    
    //MARK: - Verifica Notificacao
    private func verificaNotificacao() {
        
        let settings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        
        if settings.types != UIUserNotificationType.None {
            self.ativada = 1
        }else {
            //"Desativadas"
            self.ativada = 0
        }
    }
    
    private func ajustes() {
        
        // Do any additional setup after loading the view.
        
        let url = NSURL(string: UIApplicationOpenSettingsURLString)!
        //println(url)
        
        let app = UIApplication.sharedApplication()
        
        if app.canOpenURL(url){
            app.openURL(url)
        }
    }
}
