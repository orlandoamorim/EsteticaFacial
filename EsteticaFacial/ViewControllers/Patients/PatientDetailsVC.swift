//
//  PatientDetailsVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 12/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import Eureka
import DeviceKit
import SCLAlertView

class PatientDetailsVC: FormViewController {

    var patient:Patient?
    var contentToDisplay:contentTypes = .Nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeForm()
        switch contentToDisplay {
        case .Adicionar :
            self.title = "Add Ficha"
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SurgeryDetailsVC.cancelPressed(_:)))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SurgeryDetailsVC.getConfirmation))
        case .Atualizar:
            self.title = "Atualizar Ficha"
            self.form.setValues(RealmParse.convertRealmPatientForm(patient!))
            self.tableView?.reloadData()
            
            self.navigationItem.leftBarButtonItem = Device().isPad ? UIBarButtonItem(title: "Fechar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(noData)) : nil
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SurgeryDetailsVC.getConfirmation))
        case .Nil : noData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //--------------------
    
    private func initializeForm() {
        
        DateInlineRow.defaultRowInitializer = { row in row.maximumDate = NSDate() }
        
        form +++
            

            Section("Dados do Paciente")
            
            
            <<< NameRow("name") {
                $0.title = "Nome:"
            }
            
            <<< PickerInlineRow<String>("sex") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Sexo:"
                row.options = ["Masculino", "Feminino"]
                row.value = row.options[0]
            }
            
            <<< PickerInlineRow<String>("ethnic") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Etnia:"
                row.options = ["Caucasiano","Negróide","Asiático"]
                row.value = row.options[0]
            }
            
            <<< DateInlineRow("date_of_birth") {
                $0.title = "Data de Nascimento:"
                $0.value = NSDate()
                let formatter = NSDateFormatter()
                formatter.locale = .currentLocale()
                formatter.dateStyle = .ShortStyle
                $0.dateFormatter = formatter
            }
            
            <<< EmailRow("mail") {
                $0.title = "E-mail:"
            }
            
            <<< PhoneRow("phone") {
                $0.title = "Telefone:"
            }
        
          +++ Section(header: "", footer: "Leva você à cirurgias deste paciente.")
            <<< ButtonRow("btn_show_surgeries") { (row: ButtonRow) -> Void in
                row.title = "Cirurgias:"
                row.hidden = patient?.records.count > 0 ? false : true
                row.presentationMode = PresentationMode.SegueName(segueName: "RecoverPatientSegue", completionCallback: nil)
            }
        
        
        }
    
    //--------------------
    //--------------------
    func getConfirmation(){
        let (verify, keyMissing) = Helpers.verifyFormValues(form.values(includeHidden: false))
        
        if !verify {
            SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio \(keyMissing) nao foi preenchido", closeButtonTitle: "OK")
            return
        }
        
        switch contentToDisplay {
        case .Adicionar: self.getFormValues()
        case .Atualizar:
            
            let alertView = SCLAlertView()
            
            alertView.addButton("Atualizar") { () -> Void in
                self.getFormValues()
            }
            alertView.addButton("Cancelar") { () -> Void in
                print("cancelar")
            }
            alertView.showCloseButton = false
            
            alertView.showWarning("Atenção!", subTitle: "Esta operação nao pode ser desfeita, então proceda com cautela.")
            
        case .Nil: SCLAlertView().showError("Ops...", subTitle: "Ocorreu algum erro :(", closeButtonTitle: "OK")
        }
        
        
    }
    
    func getFormValues(){
        switch contentToDisplay {
        case .Adicionar:
            RealmParse.auPatient(formValues: self.form.values(includeHidden: false))
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                let alertView = SCLAlertView()
                alertView.showSuccess("🎉🎉🎉🎉", subTitle: "Ficha adicionada com sucesso!", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
            })
            
        case .Atualizar:
            RealmParse.auPatient(patient, formValues: self.form.values(includeHidden: false))
            
            let alertView = SCLAlertView()
            alertView.showSuccess("🎉🎉🎉🎉", subTitle: "Ficha atualizada com sucesso!", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
            self.form.setValues(self.form.values(includeHidden: false))
            self.tableView?.reloadData()
            
        case .Nil : return
        }
    }
    //--------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SurgerySegue"{
            let controller = segue.destinationViewController as! SurgeriesTableVC
            
            if let test = sender as? ButtonRow {
                if test.tag == "btn_show_surgeries"{
                    controller.surgeryShow = .Patient
                    controller.patient = patient
                }
            }
        }
    }
    
    
    
    
    // MARK: - Tela Sem Dados
    
    func noData(){
        
        let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        imageView.image = UIImage(named: "LabInC")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.sizeToFit()
        
        
        self.tableView!.backgroundView = imageView
        self.tableView!.backgroundView?.hidden = false
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        self.form.removeAll()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        self.tableView!.reloadData()
        self.title = nil
        
    }

}
