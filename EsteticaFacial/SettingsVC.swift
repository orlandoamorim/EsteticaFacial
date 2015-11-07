//
//  SettingsVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 29/10/15.
//  Copyright © 2015 UFPI. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var switchCR: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (userDefaults.valueForKey("switchCR") != nil) {
            let switchR = userDefaults.valueForKey("switchCR")
            
            if switchR as! String == "on" {
                switchCR.on = true
            }else if switchR as! String == "off" {
                switchCR.on = false
            }
        }else {
            userDefaults.setValue("off", forKey: "switchCR")
            userDefaults.synchronize()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cirurgiaRealizadaSwitch(sender: UISwitch) {
        if sender.on {
            userDefaults.setValue("on", forKey: "switchCR")
            userDefaults.synchronize()
        } else {
            userDefaults.setValue("off", forKey: "switchCR")
            userDefaults.synchronize()
        }
        
    }

    @IBAction func sair(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
