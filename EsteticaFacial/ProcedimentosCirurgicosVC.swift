//
//  ProcedimentosCirurgicosVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 05/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import Parse
import Eureka

class ProcedimentosCirurgicosVC:FormViewController {
    
    var delegate: ProcedimentoCirurgico! = nil

    var dicFormValues:[String : Any?] = [String : Any?]()
    var dicFormValuesAtual:[String : Any?] = [String : Any?]()
    var searchPlanoCirurgico:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Plano Cirurgico"
        initializeForm()
        self.tableView?.reloadData()
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
    
    func formValues(){
        
        if let aberta = self.form.rowByTag("aberta")?.baseValue as? Bool {
            dicFormValuesAtual.updateValue(aberta, forKey: "aberta")
        }
        
        if let fechada = self.form.rowByTag("fechada")?.baseValue as? Bool {
            dicFormValuesAtual.updateValue(fechada, forKey: "fechada")
        }

        //fechada_opcoes
        if let fechada_opcoes = self.form.rowByTag("fechada_opcoes")?.baseValue as? String {
            dicFormValuesAtual.updateValue(fechada_opcoes, forKey: "fechada_opcoes")
        }
        
        //incisoes
        let incisoes = (self.form.rowByTag("incisoes") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(incisoes!), forKey: "incisoes")
        
        //liberacao
        let liberacao = (self.form.rowByTag("liberacao") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(liberacao!), forKey: "liberacao")
        
        //suturas
        let suturas = (self.form.rowByTag("suturas") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(suturas!), forKey: "suturas")
        
        //outras_suturas
        if let outras_suturas = self.form.rowByTag("outras_suturas")?.baseValue as? String {
            dicFormValuesAtual.updateValue(outras_suturas, forKey: "outras_suturas")
        }
        //enxerto_de_ponta
        let enxerto_de_ponta = (self.form.rowByTag("enxerto_de_ponta") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(enxerto_de_ponta!), forKey: "enxerto_de_ponta")
        
        //outros_enxertos_de_ponta
        if let outros_enxertos_de_ponta = self.form.rowByTag("outros_enxertos_de_ponta")?.baseValue as? String {
            dicFormValuesAtual.updateValue(outros_enxertos_de_ponta, forKey: "outros_enxertos_de_ponta")
        }
        
        //enxerto_de_sheen
        let enxerto_de_sheen = (self.form.rowByTag("enxerto_de_sheen") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(enxerto_de_sheen!), forKey: "enxerto_de_sheen")
        
        //dorso
        let dorso = (self.form.rowByTag("dorso") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(dorso!), forKey: "dorso")
        
        //raiz
        let raiz = (self.form.rowByTag("raiz") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(raiz!), forKey: "raiz")
        
        //osso
        let osso = (self.form.rowByTag("osso") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(osso!), forKey: "osso")
        
        //outros_ossos
        if let outros_ossos = self.form.rowByTag("outros_ossos")?.baseValue as? String {
            dicFormValuesAtual.updateValue(outros_ossos, forKey: "outros_ossos")
        }
        
        //cartilagem
        let cartilagem = (self.form.rowByTag("cartilagem") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(cartilagem!), forKey: "cartilagem")
        
        //lateral
        let lateral = (self.form.rowByTag("lateral") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(lateral!), forKey: "lateral")
        
        //transversa
        let transversa = (self.form.rowByTag("transversa") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(transversa!), forKey: "transversa")
        
        //medial
        let medial = (self.form.rowByTag("medial") as! MultipleSelectorRow<String>).baseValue! as? Set<String>
        dicFormValuesAtual.updateValue(Helpers.getArrayFromSet(medial!), forKey: "medial")
        
        if !NSDictionary(dictionary: convertAnyToAnyObject(dicFormValues)).isEqualToDictionary(convertAnyToAnyObject(dicFormValuesAtual)) {
            delegate.alterarDic(dicFormValuesAtual)
        }
    }
    
    
    private func initializeForm() {
    
        form +++
        
        Section("Abordagem")
            
            <<< CheckRow("aberta") {
                $0.title = "Aberta"
                $0.value = dicFormValues["aberta"]! as? Bool
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("fechada")?.baseValue = false
                        self?.form.rowByTag("fechada")?.updateCell()
                    }
            }
            
            <<< CheckRow("fechada") {
                $0.title = "Fechada"
                $0.value = dicFormValues["fechada"]! as? Bool
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("aberta")?.baseValue = false
                        self?.form.rowByTag("aberta")?.updateCell()
                    }
            }
        
            <<< PushRow<String>("fechada_opcoes") {
                $0.hidden = "$fechada == false"
                $0.title = "Tipo:"
                $0.value = dicFormValues["fechada_opcoes"]! as? String
                $0.options = ["Retrograda","Trans Cartilaginosa","Liberacao"]
                $0.selectorTitle = "Tipo de Abordagem Fechada"
            }
    
        
        +++ Section("Incisoes")
            <<< MultipleSelectorRow<String>("incisoes") {
                $0.title = "Tipo:"
                $0.options =  ["Inter","Intra","Infra","Transcolumelar"] //["Inter","Intra","Infra","Transcolumelar"]
                $0.value = Set(dicFormValues["incisoes"] as! [String])
                $0.selectorTitle = "Tipo da Incisao"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
                }
        +++ Section("Ponta Nasal")
            
            <<< MultipleSelectorRow<String>("liberacao") {
                $0.title = "Liberacao:"
                $0.options = ["Resseccao Cefalica","Incisoes Liberacao","Excisao do Seg Lateral","Excisao Domal"]
                $0.value = Set(dicFormValues["liberacao"] as! [String])
                $0.selectorTitle = "Tipo da Liberacao"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
        
            <<< MultipleSelectorRow<String>("suturas") {
                $0.title = "Suturas:"
                $0.options = ["Intradomal","Transdomal","Criacao","Outras"]
                $0.value = Set(dicFormValues["suturas"] as! [String])
                $0.selectorTitle = "Tipo da Sutura"
            }.onChange { [weak self] row in
                if row.value == ["Outras"] {
                    guard let _ : TextAreaRow = self?.form.rowByTag("outras_suturas") else {
                        let textAreaRow = TextAreaRow("outras_suturas") {
                            $0.placeholder = "Outras Suturas"
                            $0.value = self!.dicFormValues["outras_suturas"] as? String
                        }
                        row.section?.insert(textAreaRow, atIndex: row.indexPath()!.row + 1)
                        return
                    }
                }else{
                    if let textAreaRow : TextAreaRow = self?.form.rowByTag("outras_suturas"), let textAreaRowIndexPath = textAreaRow.indexPath() {
                        row.section?.removeAtIndex(textAreaRowIndexPath.row)
                    }
                    
                }

                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
            
        
            <<< MultipleSelectorRow<String>("enxerto_de_ponta") {
                $0.title = "Enxerto de Ponta:"
                $0.options = ["Tampao","Juri","Strut Columelar","Strut Pre Columelar","Outros"]
                $0.value = Set(dicFormValues["enxerto_de_ponta"] as! [String])
                $0.selectorTitle = "Tipo de Enxerto de Ponta"
                
            } .onChange { [weak self] row in
                if row.value == ["Outros"] {
                    guard let _ : TextAreaRow = self?.form.rowByTag("outros_enxertos_de_ponta") else {
                        let textAreaRow = TextAreaRow("outros_enxertos_de_ponta") {
                            $0.placeholder = "Outros Enxertos de Ponta"
                            $0.value = self!.dicFormValues["outros_enxertos_de_ponta"] as? String
                        }
                        row.section?.insert(textAreaRow, atIndex: row.indexPath()!.row + 1)
                        return
                    }
                }else{
                    if let textAreaRow : TextAreaRow = self?.form.rowByTag("outros_enxertos_de_ponta"), let textAreaRowIndexPath = textAreaRow.indexPath() {
                        row.section?.removeAtIndex(textAreaRowIndexPath.row)
                    }
                }
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
            
            <<< MultipleSelectorRow<String>("enxerto_de_sheen") {
                $0.title = "Enxerto de Sheen:"
                $0.options = ["Tipo I Esmagado","Tipo II Contuso","Tipo III Solido","Tipo IV Barreira"]
                $0.value = Set(dicFormValues["enxerto_de_sheen"] as! [String])
                $0.selectorTitle = "Tipo de Enxerto de Sheen"
            }
        
        +++ Section()
        
            <<< MultipleSelectorRow<String>("dorso") {
                $0.title = "Dorso:"
                $0.options = ["Nao Tocado","Abaixado","Aumentado","Aplainado"]
                $0.value = Set(dicFormValues["dorso"] as! [String])
                $0.selectorTitle = "Tipo de Dorso"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
        
            <<< MultipleSelectorRow<String>("raiz") {
                $0.title = "Raiz:"
                $0.options = ["Reducao Raspa","Reducao Osteotomo","Aumenta Enxerto Unico","Aumenta Enxertos Multiplos"]
                $0.value = Set(dicFormValues["raiz"] as! [String])
                $0.selectorTitle = "Tipo de Raiz"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }

            <<< MultipleSelectorRow<String>("osso") {
                $0.title = "Osso:"
                $0.options = ["Raspa","Osteotomo Osso","Outros"]
                $0.value = Set(dicFormValues["osso"] as! [String])
                $0.selectorTitle = "Tipo de Osso"
                } .onChange { [weak self] row in
                    if row.value == ["Outros"] {
                        guard let _ : TextAreaRow = self?.form.rowByTag("outros_ossos") else {
                            let textAreaRow = TextAreaRow("outros_ossos") {
                                $0.placeholder = "Outros Ossos"
                                $0.value = self!.dicFormValues["outros_ossos"] as? String
                            }
                            row.section?.insert(textAreaRow, atIndex: row.indexPath()!.row + 1)
                            return
                        }
                    }else{
                        if let textAreaRow : TextAreaRow = self?.form.rowByTag("outros_ossos"), let textAreaRowIndexPath = textAreaRow.indexPath() {
                            row.section?.removeAtIndex(textAreaRowIndexPath.row)
                        }
                    }
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
        
            <<< MultipleSelectorRow<String>("cartilagem") {
                $0.title = "Cartilagem:"
                $0.options = ["Abaixada","Aumentada","Encurtada","Expansor","Enxerto Extensao"]
                $0.value = Set(dicFormValues["cartilagem"] as! [String])
                $0.selectorTitle = "Tipo de Cartilagem"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
            
        +++ Section("Osteotomos")
        
            <<< MultipleSelectorRow<String>("lateral") {
                $0.title = "Lateral:"
                $0.options = ["Nenhum Lateral","Baixa Alta","Baixa Baixa","Duplo Nivel"]
                $0.value = Set(dicFormValues["lateral"] as! [String])
                $0.selectorTitle = "Lateral"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
        
            <<< MultipleSelectorRow<String>("transversa") {
                $0.title = "Transversa:"
                $0.options = ["Nenhum Transversa","Digital","Osteotomo Transversa"]
                $0.value = Set(dicFormValues["transversa"] as! [String])
                $0.selectorTitle = "Transversa"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
            }
            <<< MultipleSelectorRow<String>("medial") {
                $0.title = "Medial:"
                $0.options = ["Nenhum Medial","Medial","Medial_Obliqua"]
                $0.value = Set(dicFormValues["medial"] as! [String])
                $0.selectorTitle = "Medial"
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleSelectorDone:")
        }
    }
    

    
    func multipleSelectorDone(item:UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }

    func convertAnyObjectToAny(anyObjectDict:[String: AnyObject]) -> [String: Any] {
        
        var anyDict = [String: Any]()
        
        for key in anyObjectDict.keys {
            anyDict.updateValue(anyObjectDict[key], forKey: key)
        }
        return anyDict
    }
 
    func convertAnyToAnyObject(anyDict:[String: Any?]) -> [String: AnyObject] {
        
        var anyObjectDict = [String: AnyObject]()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                anyObjectDict[key] = string
            }else if let bool = anyDict[key]! as? Bool {
                anyObjectDict[key] = bool
            }else if let teste = anyDict[key]! as? [String]{
                anyObjectDict[key] = teste
            }
        }
        return anyObjectDict
    }
    


    
}
