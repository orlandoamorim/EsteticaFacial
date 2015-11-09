//
//  ProcedimentosCirurgicosVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 05/11/15.
//  Copyright © 2015 UFPI. All rights reserved.
//

import UIKit
import Parse
import Eureka

class ProcedimentosCirurgicosVC:FormViewController {
    
    var delegate: ProcedimentoCirurgico! = nil

    var dicFormValues:[String : Any] = [String : Any]()
    var dicFormValuesAtual:[String : Any] = [String : Any]()
    var searchPlanoCirurgico:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Plano Cirurgico"
        initializeForm()
        
        form.setValues(dicFormValues)
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

        if !NSDictionary(dictionary: convertAnyToAnyObject(dicFormValues)).isEqualToDictionary(convertFormAnyToAnyObject()) {
            delegate.alterarDic(form.values(includeHidden: false))
        }
    }
    
    
    private func initializeForm() {
    
        form +++
        
        Section("Abordagem")
            
            <<< CheckRow("aberta") {
                $0.title = "Aberta"
                $0.value = false
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("fechada")?.baseValue = false
                        self?.form.rowByTag("fechada")?.updateCell()
                    }
            }
            
            <<< CheckRow("fechada") {
                $0.title = "Fechada"
                $0.value = false
                }.onChange { [weak self] row in
                    if row.value == true {
                        self?.form.rowByTag("aberta")?.baseValue = false
                        self?.form.rowByTag("aberta")?.updateCell()
                    }
            }
        
            <<< PushRow<String>("fechada_opcoes") {
                $0.hidden = "$fechada == false"
                $0.title = "Tipo:"
                $0.options = ["Retrograda","Trans Cartilaginosa","Liberacao"]
                //                $0.value = ""
                $0.selectorTitle = "Tipo de Abordagem Fechada"
            }
    
        
        +++ Section("Incisoes")
            <<< PushRow<String>("incisoes") {
                $0.title = "Tipo:"
                $0.options = ["Inter","Intra","Infra","Transcolumelar"]
                $0.selectorTitle = "Tipo da Incisao"
            }
        
        +++ Section("Ponta Nasal")
            
            <<< PushRow<String>("liberacao") {
                $0.title = "Liberacao:"
                $0.options = ["Resseccao Cefalica","Incisoes Liberacao","Excisao do Seg Lateral","Excisao Domal"]
                $0.selectorTitle = "Tipo da Liberacao"
            }
        
            <<< PushRow<String>("suturas") {
                $0.title = "Suturas:"
                $0.options = ["Intradomal","Transdomal","Criacao","Outras"]
                $0.selectorTitle = "Tipo da Sutura"
            }.onChange { [weak self] row in
                if row.value == "Outras" {
                    guard let _ : TextAreaRow = self?.form.rowByTag("outras_suturas") else {
                        let textAreaRow = TextAreaRow("outras_suturas") {
                            $0.placeholder = "Outras Suturas"
                        }
                        row.section?.insert(textAreaRow, atIndex: row.indexPath()!.row + 1)
                        return
                    }
                }else{
                    if let textAreaRow : TextAreaRow = self?.form.rowByTag("outras_suturas"), let textAreaRowIndexPath = textAreaRow.indexPath() {
                        row.section?.removeAtIndex(textAreaRowIndexPath.row)
                    }
                    
                }

            }
            
        
            <<< PushRow<String>("enxerto_de_ponta") {
                $0.title = "Enxerto de Ponta:"
                $0.options = ["Tampao","Juri","Strut Columelar","Strut Pre Columelar","Outros"]
                $0.selectorTitle = "Tipo de Enxerto de Ponta"
                
            } .onChange { [weak self] row in
                if row.value == "Outros" {
                    guard let _ : TextAreaRow = self?.form.rowByTag("outros_enxertos_de_ponta") else {
                        let textAreaRow = TextAreaRow("outros_enxertos_de_ponta") {
                            $0.placeholder = "Outros Enxertos de Ponta"
                        }
                        row.section?.insert(textAreaRow, atIndex: row.indexPath()!.row + 1)
                        return
                    }
                }else{
                    if let textAreaRow : TextAreaRow = self?.form.rowByTag("outros_enxertos_de_ponta"), let textAreaRowIndexPath = textAreaRow.indexPath() {
                        row.section?.removeAtIndex(textAreaRowIndexPath.row)
                    }
                }
            }
            
            <<< PushRow<String>("enxerto_de_sheen") {
                $0.title = "Enxerto de Sheen:"
                $0.options = ["Tipo I Esmagado","Tipo II Contuso","Tipo III Solido","Tipo IV Barreira"]
                $0.selectorTitle = "Tipo de Enxerto de Sheen"
            }
        
        +++ Section()
        
            <<< PushRow<String>("dorso") {
                $0.title = "Dorso:"
                $0.options = ["Nao Tocado","Abaixado","Aumentado","Aplainado"]
                $0.selectorTitle = "Tipo de Dorso"
            }
        
            <<< PushRow<String>("raiz") {
                $0.title = "Raiz:"
                $0.options = ["Reducao Raspa","Reducao Osteotomo","Aumenta Enxerto Unico","Aumenta Enxertos Multiplos"]
                $0.selectorTitle = "Tipo de Raiz"
            }

            <<< PushRow<String>("osso") {
                $0.title = "Osso:"
                $0.options = ["Raspa","Osteotomo Osso","Outros"]
                $0.selectorTitle = "Tipo de Osso"
                } .onChange { [weak self] row in
                    if row.value == "Outros" {
                        guard let _ : TextAreaRow = self?.form.rowByTag("outros_ossos") else {
                            let textAreaRow = TextAreaRow("outros_ossos") {
                                $0.placeholder = "Outros Ossos"
                            }
                            row.section?.insert(textAreaRow, atIndex: row.indexPath()!.row + 1)
                            return
                        }
                    }else{
                        if let textAreaRow : TextAreaRow = self?.form.rowByTag("outros_ossos"), let textAreaRowIndexPath = textAreaRow.indexPath() {
                            row.section?.removeAtIndex(textAreaRowIndexPath.row)
                        }
                    }
            }
        
            <<< PushRow<String>("cartilagem") {
                $0.title = "Cartilagem:"
                $0.options = ["Abaixada","Aumentada","Encurtada","Expansor","Enxerto Extensao"]
                $0.selectorTitle = "Tipo de Cartilagem"
            }
            
        +++ Section("Osteotomos")
        
            <<< PushRow<String>("lateral") {
                $0.title = "Lateral:"
                $0.options = ["Nenhum Lateral","Baixa Alta","Baixa Baixa","Duplo Nivel"]
                $0.selectorTitle = "Lateral"
            }
        
            <<< PushRow<String>("transversa") {
                $0.title = "Transversa:"
                $0.options = ["Nenhum Transversa","Digital","Osteotomo Transversa"]
                $0.selectorTitle = "Transversa"
            }
            <<< PushRow<String>("medial") {
                $0.title = "Medial:"
                $0.options = ["Nenhum Medial","Medial","Medial_Obliqua"]
                $0.selectorTitle = "Medial"
        }
    }

    func convertAnyObjectToAny(anyObjectDict:[String: AnyObject]) -> [String: Any] {
        
        var anyDict = [String: Any]()
        
        for key in anyObjectDict.keys {
            anyDict.updateValue(anyObjectDict[key], forKey: key)
        }
        return anyDict
    }
    
    func convertFormAnyToAnyObject() -> [String: AnyObject] {
        let anyDict = form.values(includeHidden: false)
        var anyObjectDict = [String: AnyObject]()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                anyObjectDict.updateValue(string, forKey: key)
            }else if let bool = anyDict[key]! as? Bool {
                anyObjectDict.updateValue(bool, forKey: key)

            }
        }
        
        return anyObjectDict
    }
    
    func convertAnyToAnyObject(anyDict:[String: Any]) -> [String: AnyObject] {
        
        var anyObjectDict = [String: AnyObject]()
        
        for key in anyDict.keys {
            if let string = anyDict[key]! as? String {
                anyObjectDict[key] = string
            }else if let bool = anyDict[key]! as? Bool {
                anyObjectDict[key] = bool
            }
        }
        return anyObjectDict
    }
    
    
}
