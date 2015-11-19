//
//  MostrarCirurgiasVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 19/11/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit
import Eureka

class MostrarCirurgiasVC: FormViewController {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var formValues:[String : Any?] = [String : Any?]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()

        //---
        if (userDefaults.valueForKey("switchCT") != nil) {
            let switchCT = userDefaults.valueForKey("switchCT")
            
            if switchCT as! String == "Realizadas" {
                formValues.updateValue(true, forKey: "realizadas")
            }else if switchCT as! String == "Não Realizadas" {
                formValues.updateValue(true, forKey: "nao_realizadas")
            }else if switchCT as! String == "Todas" {
                formValues.updateValue(true, forKey: "todas")
            }
        }else {
            formValues.updateValue(true, forKey: "todas")
            userDefaults.setValue("Todas", forKey: "switchCT")
            userDefaults.synchronize()
        }
        
        
        self.form.setValues(formValues)
        self.tableView?.reloadData()
        //---
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeForm() {
        
        form +++
            
            Section("Abordagem")
            
            <<< CheckRow("realizadas") {
                $0.title = "Realizadas"
                $0.value = false
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("nao_realizadas")?.baseValue = false
                        self?.form.rowByTag("nao_realizadas")?.updateCell()
                        
                        self?.form.rowByTag("todas")?.baseValue = false
                        self?.form.rowByTag("todas")?.updateCell()
                        
                        self!.userDefaults.setValue("Realizadas", forKey: "switchCT")
                        self!.userDefaults.synchronize()
                        
                        self?.dismissViewControllerAnimated(true, completion: nil)
                    }
            }
            
            <<< CheckRow("nao_realizadas") {
                $0.title = "Não Realizadas"
                $0.value = false
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("realizadas")?.baseValue = false
                        self?.form.rowByTag("realizadas")?.updateCell()
                        
                        self?.form.rowByTag("todas")?.baseValue = false
                        self?.form.rowByTag("todas")?.updateCell()
                        
                        self!.userDefaults.setValue("Não Realizadas", forKey: "switchCT")
                        self!.userDefaults.synchronize()
                        self?.dismissViewControllerAnimated(true, completion: nil)
                    }
            }
            <<< CheckRow("todas") {
                $0.title = "Todas"
                $0.value = false
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("realizadas")?.baseValue = false
                        self?.form.rowByTag("realizadas")?.updateCell()
                        
                        self?.form.rowByTag("nao_realizadas")?.baseValue = false
                        self?.form.rowByTag("nao_realizadas")?.updateCell()
                        
                        self!.userDefaults.setValue("Todas", forKey: "switchCT")
                        self!.userDefaults.synchronize()
                        
                        self?.dismissViewControllerAnimated(true, completion: nil)

                    }
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }


}
