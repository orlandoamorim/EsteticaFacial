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
import AcknowList
import SafariServices

class SettingsTableVC: FormViewController {

    var passcodeActivated:Bool = Bool()
    var notificationActivated:Int = Int()
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
                    
                    var passcodeVC: PasscodeLockViewController?
                    if $0.value == true {
                        if self!.configuration.repository.hasPasscode {
                            self!.passcodeActivated = true
                            return
                        }
                        passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: self!.configuration)

                    } else if $0.value == false {
                        if !self!.configuration.repository.hasPasscode {
                            self!.passcodeActivated = false
                            return
                        }
                        passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: self!.configuration)
                        passcodeVC!.successCallback = { lock in
                            lock.repository.deletePasscode()
                        }
                    }
                    
                    passcodeVC!.dismissCompletionCallback = { [weak self] in
                        if self!.configuration.repository.hasPasscode{
                            if self!.passcodeActivated {
                                return
                            }
                            self?.form.rowByTag("password")?.baseValue = true
                            self?.form.rowByTag("password")?.updateCell()
                        } else {
                            if !self!.passcodeActivated {
                                return
                            }
                            self?.form.rowByTag("password")?.baseValue = false
                            self?.form.rowByTag("password")?.updateCell()
                        }

                    }

                    
                    self!.presentViewController(passcodeVC!, animated: true, completion: nil)

                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "Beta")
            }
        
            <<< LabelRow ("changePassword") {
                $0.title = "Mudar a senha?"
                $0.hidden = "$password == false"
                $0.value = "Mudar!"
                }.onCellSelection({ (_, _) in
                    let repo = UserDefaultsPasscodeRepository()
                    let config = PasscodeLockConfiguration(repository: repo)
                    
                    let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
                    
                    self.presentViewController(passcodeLock, animated: true, completion: nil)
                }).cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "Beta")
            }
            +++ Section(header: "", footer: "Beta para proximas atualizações.")
            
            <<< ButtonRow("btn_show_patients") { (row: ButtonRow) -> Void in
                row.title = "Pacientes"
                row.presentationMode = PresentationMode.SegueName(segueName: "PacientsSegue", completionCallback: nil)
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "Beta")
            }
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                    if #available(iOS 9.2, *) {
                        row.title = "We 🤗 Open Source Software"
                    } else {
                        row.title = "We ❤️ Open Source Software"
                    }
                }.onCellSelection({ (cell, row) in
                    let path = NSBundle.mainBundle().pathForResource("Pods-EsteticaFacial-acknowledgements", ofType: "plist")
                    let viewController = AcknowListViewController(acknowledgementsPlistPath: path)
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(viewController, animated: true)
                    }
                }).cellSetup() {cell, row in
                    cell.backgroundColor = UIColor.clearColor()
                    cell.tintColor = UIColor(hexString: "#4BCAD1")
                    
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clearColor()
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#A8A8A8")
                    cell.selectedBackgroundView = bgColorView

//                    let indent_large_enought_to_hidden:CGFloat = 10000
//                    cell.separatorInset = UIEdgeInsetsMake(0, indent_large_enought_to_hidden, 0, 0) // indent large engough for separator(including cell' content) to hidden separator
//                    cell.indentationWidth = indent_large_enought_to_hidden * -1 // adjust the cell's content to show normally
//                    cell.indentationLevel = 1 // must add this, otherwise default is 0, now actual indentation = indentationWidth * indentationLevel = 10000 * 1 = -10000
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                if #available(iOS 9.3, *) {
                    row.title = "Relatar Bug 🐛"
                } else {
                    row.title = "Relatar Bug"
                }
                
                }.onCellSelection({ (cell, row) in
                    if #available(iOS 9.0, *) {
                        let svc = SFSafariViewController(URL: NSURL(string: AppDelegate().trelloCard)!, entersReaderIfAvailable: true)
                        self.presentViewController(svc, animated: true, completion: nil)
                    } else {
                        let url = NSURL(string: AppDelegate().trelloCard)!
                        UIApplication.sharedApplication().openURL(url)
                    }
                }).cellSetup() {cell, row in
                    cell.backgroundColor = UIColor.clearColor()
                    cell.tintColor = UIColor(hexString: "#4BCAD1")
                    
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clearColor()
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#A8A8A8")
                    cell.selectedBackgroundView = bgColorView
            }
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Saiba mais sobre o projeto"
                
                }.onCellSelection({ (cell, row) in
                    if #available(iOS 9.0, *) {
                        let svc = SFSafariViewController(URL: NSURL(string: AppDelegate().trelloBoard)!, entersReaderIfAvailable: true)
                        self.presentViewController(svc, animated: true, completion: nil)
                    } else {
                        let url = NSURL(string: AppDelegate().trelloBoard)!
                        UIApplication.sharedApplication().openURL(url)
                    }
                }).cellSetup() {cell, row in
                    cell.backgroundColor = UIColor.clearColor()
                    cell.tintColor = UIColor(hexString: "#4BCAD1")
                    
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clearColor()
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#A8A8A8")
                    cell.selectedBackgroundView = bgColorView
            }
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Versão \(AppDelegate().version)"
                row.disabled = true

                }.cellSetup() {cell, row in
                    cell.backgroundColor = UIColor.clearColor()
                    cell.tintColor = UIColor(hexString: "#4C6B94")
                    
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clearColor()
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#A8A8A8")
                    cell.selectedBackgroundView = bgColorView
                    cell.selected = true
                    
        }
    }
    
    
    
    //MARK: - Verifica Notificacao
    private func verificaNotificacao() {
        
        let settings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        
        if settings.types != UIUserNotificationType.None {
            self.notificationActivated = 1
        }else {
            //"Desativadas"
            self.notificationActivated = 0
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


