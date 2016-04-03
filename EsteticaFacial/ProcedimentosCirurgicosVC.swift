//
//  ProcedimentosCirurgicosVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 05/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import Eureka

class ProcedimentosCirurgicosVC:FormViewController {
    
    var delegate: ProcedimentoCirurgico! = nil

    var dicFormValues:[String : Any?] = [String : Any?]()
    var dicFormValuesAtual:[String : Any?] = [String : Any?]()
    
    var surgicalPlanning:SurgicalPlanningTypes = .PreSurgical

    override func viewDidLoad() {
        super.viewDidLoad()

        switch surgicalPlanning {
        case .PostSurgical: self.title = "Relatório Cirúrgico"
        case .PreSurgical: self.title = "Plano Cirúrgico"
        }
        initializeForm()
        self.form.setValues(dicFormValues)
        self.tableView?.reloadData()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "infoIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(showInfo))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController(){
            formValues()
        }
    }
    
    func showInfo(sender:UIBarButtonItem){
        let alert:UIAlertController = UIAlertController(title: NSLocalizedString("", comment:""), message: NSLocalizedString("Se não utilizou um item, deixe-o vazio.", comment:""), preferredStyle: UIAlertControllerStyle.ActionSheet)
        if let popView = alert.popoverPresentationController {
            popView.barButtonItem = sender
        }
    
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    
    func formValues(){
        if !NSDictionary(dictionary: Helpers.convertAnyToAnyObject(dicFormValues)).isEqualToDictionary(Helpers.convertAnyToAnyObject(dicFormValuesAtual)) {
            delegate.updateSurgicalPlanning(form.values(includeHidden: false), SurgicalPlanningType: surgicalPlanning)
        }
    }
    
    
    private func initializeForm() {
    
        form +++
            
        Section("Abordagem")
            <<< SwitchRow("abordagem") {
                $0.title = "Aberta"
                }.onChange { [weak self] in
                    if $0.value == true {
                        $0.title = "Fechada"
                        $0.updateCell()
                        self?.form.rowByTag("abordagem_opcoes")?.hidden = false
                        self?.form.rowByTag("abordagem_opcoes")?.updateCell()
                    }else if $0.value == false {
                        $0.title = "Aberta"
                        $0.updateCell()
                        self?.form.rowByTag("abordagem_opcoes")?.hidden = true
                        self?.form.rowByTag("abordagem_opcoes")?.updateCell()
                    }
            }
            
            
            <<< PushRow<String>("abordagem_opcoes") {
                $0.hidden = "$abordagem == false"
                $0.title = "Tipo:"
                $0.options = ["Retrógrada","Trans-cartilaginosa","Liberação"]
                $0.selectorTitle = "Tipo de Abordagem Fechada"
            }
    
        
        +++ Section("Incisoes")
            <<< MultipleSelectorRow<String>("incisoes") {
                $0.title = "Tipo:"
                $0.options =  ["Inter","Intra","Infra","Transcolumelar"]
                $0.selectorTitle = "Tipo da Incisao"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
                }
        +++ Section("Ponta Nasal")
            
            <<< MultipleSelectorRow<String>("liberacao") {
                $0.title = "Liberação:"
                $0.options = ["Ressecção Cefálica","Incisões","Excisão do Seg Lateral","Excisão domal"]
                $0.selectorTitle = "Tipo da Liberação"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
            <<< MultipleSelectorRow<String>("suturas") {
                $0.title = "Suturas:"
                $0.options = ["Intradomal","Transdomal","Criação","Outros"]
                $0.selectorTitle = "Tipo da Sutura"
            }.onChange { [weak self] row in
                if row.value!.contains("Outros") {
                    self?.form.rowByTag("outras_suturas")?.hidden = false
                    self?.form.rowByTag("outras_suturas")?.updateCell()
                }else{
                    self?.form.rowByTag("outras_suturas")?.hidden = true
                    self?.form.rowByTag("outras_suturas")?.updateCell()
                    
                }

                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            
            <<< TextAreaRow("outras_suturas") {
                $0.hidden = "$suturas != 'Outros'"
                $0.placeholder = "Outras Suturas"
            }
            
        
            <<< MultipleSelectorRow<String>("enxerto_de_ponta") {
                $0.title = "Enxerto de Ponta:"
                $0.options = ["Tampão","Júri","Strut columelar","Strut pré-columelar","Outros"]
                $0.selectorTitle = "Tipo de Enxerto de Ponta"
                
            } .onChange { [weak self] row in
                if row.value!.contains("Outros") {
                    self?.form.rowByTag("outros_enxertos_de_ponta")?.hidden = false
                    self?.form.rowByTag("outros_enxertos_de_ponta")?.updateCell()
                }else{
                    self?.form.rowByTag("outros_enxertos_de_ponta")?.hidden = true
                    self?.form.rowByTag("outros_enxertos_de_ponta")?.updateCell()
                    
                }

                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            <<< TextAreaRow("outros_enxertos_de_ponta") {
            $0.hidden = "$enxerto_de_ponta != 'Outros'"
            $0.placeholder = "Outros Enxertos de Ponta"
            }
            
            <<< MultipleSelectorRow<String>("enxerto_de_sheen") {
                $0.title = "Enxerto de Sheen:"
                $0.options = ["Tipo I Esmagado","Tipo II Contuso","Tipo III Sólido","Tipo IV Barreira"]
                $0.selectorTitle = "Tipo de Enxerto de Sheen"
            }
        
        +++ Section("Dorso")
        
            <<< MultipleSelectorRow<String>("dorso") {
                $0.title = "Dorso:"
                $0.options = ["Abaixado","Aumentado","Aplainado"]
                $0.selectorTitle = "Tipo de Dorso"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
            <<< MultipleSelectorRow<String>("raiz") {
                $0.title = "Raiz:"
                $0.options = ["Redução Raspa","Redução Osteótomo","Aumentada Enxerto Único","Aumentada Enxertos Múltiplos"]
                $0.selectorTitle = "Tipo de Raiz"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }

            <<< MultipleSelectorRow<String>("osso") {
                $0.title = "Osso:"
                $0.options = ["Raspa","Osteótomo","Outros"]
                $0.selectorTitle = "Tipo de Osso"
                } .onChange { [weak self] row in
                    if row.value!.contains("Outros") {
                        self?.form.rowByTag("outros_ossos")?.hidden = false
                        self?.form.rowByTag("outros_ossos")?.updateCell()
                    }else{
                        self?.form.rowByTag("outros_ossos")?.hidden = true
                        self?.form.rowByTag("outros_ossos")?.updateCell()
                        
                    }
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            
            <<< TextAreaRow("outros_ossos") {
                $0.hidden = "$osso != 'Outros'"
                $0.placeholder = "Outros ossos"
            }
            
        
            <<< MultipleSelectorRow<String>("cartilagem") {
                $0.title = "Cartilagem:"
                $0.options = ["Abaixada","Aumentada","Encurtada","Expansor","Enxerto Extensão"]
                $0.selectorTitle = "Tipo de Cartilagem"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            
        +++ Section("OSTEOTOMIAS")
        
            <<< MultipleSelectorRow<String>("lateral") {
                $0.title = "Lateral:"
                $0.options = ["Baixa-alta","Baixa-baixa","Duplo Nível"]
                $0.selectorTitle = "Lateral"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
            <<< MultipleSelectorRow<String>("transversa") {
                $0.title = "Transversa:"
                $0.options = ["Digital","Osteótomo"]
                $0.selectorTitle = "Transversa"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            <<< MultipleSelectorRow<String>("medial") {
                $0.title = "Medial:"
                $0.options = ["Medial", "Medial Oblíqua", "Contínua"]
                $0.selectorTitle = "Medial"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }

        +++ Section()
            <<< MultipleSelectorRow<String>("base_alar") {
                $0.title = "Base Alar:"
                $0.options = ["Estreitamento de Assoalho", "Redução da Dilatação Alar", "Sutura de Estreitamento"]
                $0.selectorTitle = "Lateral"
                } .onChange { [weak self] row in
                    if row.value!.contains("Estreitamento de Assoalho") {
                        self?.form.rowByTag("estreitamento_de_assoalho_option")?.hidden = false
                        self?.form.rowByTag("estreitamento_de_assoalho_option")?.updateCell()
                    }else if !row.value!.contains("Estreitamento de Assoalho"){
                        self?.form.rowByTag("estreitamento_de_assoalho_option")?.hidden = true
                        self?.form.rowByTag("estreitamento_de_assoalho_option")?.updateCell()
                        
                    }
                    
                    if row.value!.contains("Redução da Dilatação Alar") {
                        self?.form.rowByTag("redução_da_dilatação_alar_option")?.hidden = false
                        self?.form.rowByTag("redução_da_dilatação_alar_option")?.updateCell()
                    }else if !row.value!.contains("Redução da Dilatação Alar"){
                        self?.form.rowByTag("redução_da_dilatação_alar_option")?.hidden = true
                        self?.form.rowByTag("redução_da_dilatação_alar_option")?.updateCell()
                        
                    }
                    
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
            <<< MultipleSelectorRow<String>("estreitamento_de_assoalho_option") {
                $0.hidden = "$base_alar != 'Estreitamento de Assoalho'"
                $0.title = "Estreitamento de Assoalho:"
                $0.options = ["mm esquerda","mm direita"]
                $0.selectorTitle = "Estreitamento de Assoalho Tipo:"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
            <<< MultipleSelectorRow<String>("redução_da_dilatação_alar_option") {
                $0.hidden = "$base_alar != 'Redução da Dilatação Alar'"
                $0.title = "Redução da Dilatação Alar:"
                $0.options = ["mm esquerda","mm direita"]
                $0.selectorTitle = "Redução da Dilatação Alar Tipo"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
        +++ Section()
        
            <<< MultipleSelectorRow<String>("enxertos_autologos") {
                $0.title = "Enxertos (autólogos):"
                $0.options = ["Septal", "Auricular", "Costelas", "Implantes", "Outros"]
                $0.selectorTitle = "Tipo de Enxertos (autólogos):"
                } .onChange { [weak self] row in
                    if row.value!.contains("Outros") {
                        self?.form.rowByTag("outros_enxertos_autologos")?.hidden = false
                        self?.form.rowByTag("outros_enxertos_autologos")?.updateCell()
                    }else{
                        self?.form.rowByTag("outros_enxertos_autologos")?.hidden = true
                        self?.form.rowByTag("outros_enxertos_autologos")?.updateCell()
                        
                    }
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            
            <<< TextAreaRow("outros_enxertos_autologos") {
                $0.hidden = "$enxertos_autologos != 'Outros'"
                $0.placeholder = "Outros Enxertos (autólogos)"
        }
        
        
            +++ Section()
            <<< MultipleSelectorRow<String>("miscelanea") {
                $0.title = "Miscelânea:"
                $0.options = ["Ressecção do Septo Nasal", "Turbinectomia", "Mentoplastia", "Outros"]
                $0.selectorTitle = "Lateral"
                } .onChange { [weak self] row in
                    if row.value!.contains("Mentoplastia") {
                        self?.form.rowByTag("mentoplastia_option")?.hidden = false
                        self?.form.rowByTag("mentoplastia_option")?.updateCell()
                    }else if !row.value!.contains("Mentoplastia"){
                        self?.form.rowByTag("mentoplastia_option")?.hidden = true
                        self?.form.rowByTag("mentoplastia_option")?.updateCell()
                        
                    }
                    
                    if row.value!.contains("Outros") {
                        self?.form.rowByTag("miscelanea_outros")?.hidden = false
                        self?.form.rowByTag("miscelanea_outros")?.updateCell()
                    }else if !row.value!.contains("Outros"){
                        self?.form.rowByTag("miscelanea_outros")?.hidden = true
                        self?.form.rowByTag("miscelanea_outros")?.updateCell()
                        
                    }
                    
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
            
            <<< MultipleSelectorRow<String>("mentoplastia_option") {
                $0.hidden = "$miscelanea != 'Mentoplastia'"
                $0.title = "Mentoplastia:"
                $0.options = ["Aumento","Redução"]
                $0.selectorTitle = "Mentoplastia Tipo:"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: #selector(ProcedimentosCirurgicosVC.multipleSelectorDone(_:)))
            }
        
            <<< TextAreaRow("miscelanea_outros") {
                $0.hidden = "$miscelanea != 'Outros'"
                $0.placeholder = "Outros Miscelânea"
        }
    }
    
    
    func multipleSelectorDone(item:UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
}
