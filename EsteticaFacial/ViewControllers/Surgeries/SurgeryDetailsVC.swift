//
//  SurgeryDetailsVC.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 09/11/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView
import DeviceKit
import RealmSwift

class SurgeryDetailsVC: FormViewController{
    
    var record:Record!
    var patient:Patient?
    var tapBGGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var btnFront: UIButton!
    @IBOutlet weak var btnProfileRight: UIButton!
    @IBOutlet weak var btnNasal: UIButton!
    
    @IBOutlet weak var btnObliqueRight: UIButton!
    @IBOutlet weak var btnProfileLeft: UIButton!
    @IBOutlet weak var btnObliqueLeft: UIButton!
    
    var frontPoints : [String:NSValue]?
    var profileRightPoints : [String:NSValue]?
    var nasalPoints : [String:NSValue]?
    
    var sourceTypes: ImageRowSourceTypes = []
    var showAction = ImageShowAction.Yes(style: .Default)
    var clearAction = ImageClearAction.Yes(style: .Destructive)
    
    //Procedimentos Cirurgicos
    var preSurgicalPlanningForm:[String : Any?] = [String : Any?]()
    var postSurgicalPlanningForm:[String : Any?] = [String : Any?]()
    
    var recordID:String = NSUUID().UUIDString
    var compareImages:[CompareImage] = [CompareImage]()

    var imageType:ImageTypes = .Front
    var contentToDisplay:contentTypes = .Nil
    var surgicalPlanning:SurgicalPlanningTypes = .PreSurgical
    
    var alertViewResponder: SCLAlertViewResponder?
    
    var handleShortcut:Bool = false
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        initializeForm()
        setButtons()
        sourceTypes = .All
        preSurgicalPlanningForm = Helpers.surgicalPlanningForm()
        postSurgicalPlanningForm = Helpers.surgicalPlanningForm()
        
        let centroDeNotificacao: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        centroDeNotificacao.addObserver(self, selector: #selector(noData), name: "noData", object: nil)
        
        switch contentToDisplay {
        case .Adicionar:
            self.title = "Adicionar Cirurgia"
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelPressed(_:)))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(getConfirmation))
            if patient != nil {
                ajustToPacient("Adicionando")
            }
            
            if handleShortcut {
                handleShortcutItem()
            }
            
        case .Atualizar:
            recordID = record.id
            
            for surgicalPlanning in record.surgicalPlanning {
                if surgicalPlanning.type ==  false {
                    self.preSurgicalPlanningForm = RealmParse.convertRealmSurgicalPlanningForm(surgicalPlanning)
                }else if surgicalPlanning.type ==  true {
                    self.postSurgicalPlanningForm = RealmParse.convertRealmSurgicalPlanningForm(surgicalPlanning)
                }
            }
            for compareImage in record.compareImage {
                if compareImage.reference == 0.toString() {
                    for image in compareImage.image {
                        switch Int(image.imageType)! {
                        case ImageTypes.Front.hashValue :
                            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                if error != nil {
                                    print(error!.description)
                                    self.btnFront.enabled = false
                                    self.btnFront.setBackgroundImage(UIImage(named: "DropboxError"), forState: UIControlState.Normal)
                                    self.btnFront.backgroundColor = UIColor.clearColor()
                                }else {
                                    self.btnFront.setImage(object as? UIImage, forState: UIControlState.Normal)
                                    self.frontPoints = image.points != nil ? (NSKeyedUnarchiver.unarchiveObjectWithData(image.points!) as! [String : NSValue]?) : nil
                                }
                            })

                        
                        case ImageTypes.ProfileRight.hashValue :
                            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                if error != nil {
                                    print(error!.description)
                                    self.btnProfileRight.enabled = false
                                    self.btnProfileRight.setBackgroundImage(UIImage(named: "DropboxError"), forState: UIControlState.Normal)
                                    self.btnProfileRight.backgroundColor = UIColor.clearColor()
                                }else {
                                    self.btnProfileRight.setImage(object as? UIImage, forState: UIControlState.Normal)
                                    self.profileRightPoints = image.points != nil ? (NSKeyedUnarchiver.unarchiveObjectWithData(image.points!) as! [String : NSValue]?) : nil
                                }
                            })

                            
                        case ImageTypes.Nasal.hashValue :
                            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                if error != nil {
                                    print(error!.description)
                                    self.btnNasal.enabled = false
                                    self.btnNasal.setBackgroundImage(UIImage(named: "DropboxError"), forState: UIControlState.Normal)
                                    self.btnNasal.backgroundColor = UIColor.clearColor()
                                    
                                }else {
                                    self.btnNasal.setImage(object as? UIImage, forState: UIControlState.Normal)
                                    self.nasalPoints = image.points != nil ? (NSKeyedUnarchiver.unarchiveObjectWithData(image.points!) as! [String : NSValue]?) : nil
                                }
                            })
                            
                        case ImageTypes.ObliqueLeft.hashValue :
                            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                if error != nil {
                                    print(error!.description)
                                    self.btnObliqueLeft.enabled = false
                                    self.btnObliqueLeft.setBackgroundImage(UIImage(named: "DropboxError"), forState: UIControlState.Normal)
                                    self.btnObliqueLeft.backgroundColor = UIColor.clearColor()
                                    
                                }else {
                                    self.btnObliqueLeft.setImage(object as? UIImage, forState: UIControlState.Normal)
                                }
                            })


                        case ImageTypes.ProfileLeft.hashValue :
                            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                if error != nil {
                                    print(error!.description)
                                    self.btnProfileLeft.enabled = false
                                    self.btnProfileLeft.setBackgroundImage(UIImage(named: "DropboxError"), forState: UIControlState.Normal)
                                    self.btnProfileLeft.backgroundColor = UIColor.clearColor()
                                    
                                }else {
                                    self.btnProfileLeft.setImage(object as? UIImage, forState: UIControlState.Normal)
                                }
                            })


                        case ImageTypes.ObliqueRight.hashValue :
                            RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                if error != nil {
                                    print(error!.description)
                                    self.btnObliqueRight.enabled = false
                                    self.btnObliqueRight.setBackgroundImage(UIImage(named: "DropboxError"), forState: UIControlState.Normal)
                                    self.btnObliqueRight.backgroundColor = UIColor.clearColor()
                                    
                                    
                                }else {
                                    self.btnObliqueRight.setImage(object as? UIImage, forState: UIControlState.Normal)
                                }
                            })

                        default:   continue
                        }
                    }
                }
            }
            
            self.form.setValues(RealmParse.convertRealmRecordForm(record))
            self.tableView?.reloadData()
            self.title = "Dados da Cirurgia"
            if patient != nil {
                ajustToPacient("Dados da")
            }else{
                self.form.sectionByTag("recover_patient")?.hidden = true
                self.form.sectionByTag("recover_patient")?.evaluateHidden()
            }
            
            self.navigationItem.leftBarButtonItem = Device().isPad ? UIBarButtonItem(title: "Fechar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(noData)) : nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editBarBtn))
            
            form.last! <<< ButtonRow() { (row: ButtonRow) -> Void in
                if record != nil {
                    if record!.create_at == record!.update_at {
                        row.title = "Adicionado(a) \(dateTimeAgo(record!.create_at))"
                    }else{
                        row.title = "Atualizado(a) \(dateTimeAgo(record!.update_at))"
                    }
                }
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
        case .Nil : noData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleShortcutItem(){
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            self.imageType = .Front
            self.performSegueWithIdentifier(Device().isPad ? "iPadCameraSegue" : "iPhoneCameraSegue", sender: nil)
        }
    }
    
    
    //-------------------
    
    func editBarBtn(){
        self.tableView?.endEditing(true)
        if patient != nil{
            self.navigationItem.titleView = Helpers.setTitle("\(patient!.name)", subtitle: "Atualizando Cirurgia")
        }else{
            self.navigationItem.titleView = Helpers.setTitle("\(record.patient!.name)", subtitle: "Atualizando Cirurgia")
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelEditBarBtn))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(getConfirmation))
    }
    
    func cancelEditBarBtn(){
        self.tableView?.endEditing(true)
        if patient != nil{
            self.navigationItem.titleView = Helpers.setTitle("\(patient!.name)", subtitle: "Dados Cirurgia")
        }else{
            self.navigationItem.titleView = nil
            self.title = "Dados da Cirurgia"
        }
        self.form.setValues(RealmParse.convertRealmRecordForm(record))
        
        self.navigationItem.leftBarButtonItem = Device().isPad ? UIBarButtonItem(title: "Fechar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(noData)) : nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editBarBtn))
        self.tableView?.reloadData()
        
        
    }
    //--------------------
    func ajustToPacient(word: String){
        self.navigationItem.titleView = Helpers.setTitle("\(patient!.name)", subtitle: "\(word) Cirurgia")
        self.form.sectionByTag("recover_patient")?.hidden = true
        self.form.sectionByTag("recover_patient")?.evaluateHidden()

        self.form.sectionByTag("patient_data")?.hidden = true
        self.form.sectionByTag("patient_data")?.evaluateHidden()
    }
    
    //--------------------
    func getConfirmation(){
        self.tableView?.endEditing(true)
        let (verify, keyMissing) = Helpers.verifyFormValues(form.values(includeHidden: false))
        
        if !verify {
            SCLAlertView().showInfo("UFPI", subTitle: "Campo obrigatorio \(keyMissing) nao foi preenchido", closeButtonTitle: "OK")
            return
        }
        
        switch contentToDisplay {
        case .Adicionar: self.getFormValues()
        case .Atualizar:

            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("Atualizar") { () -> Void in
                self.getFormValues()
            }
            alertView.addButton("Cancelar") { () -> Void in }
                        
            alertView.showWarning("Atenção!", subTitle: "Esta operação nao pode ser desfeita, então proceda com cautela.")

        case .Nil: SCLAlertView().showError("Ops...", subTitle: "Ocorreu algum erro :(", closeButtonTitle: "OK")
        }
        

    }
    
    func getFormValues(){
        switch contentToDisplay {
        case .Adicionar:
            RealmParse.auSurgery(id: recordID, record: nil, patient: patient, formValues: self.form.values(includeHidden: false), preSugicalPlaningForm: self.preSurgicalPlanningForm, postSugicalPlaningForm: self.postSurgicalPlanningForm, compareImages: getImages())
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                let alertView = SCLAlertView()
                alertView.showSuccess("🎉🎉🎉🎉", subTitle: "Cirurgia adicionada com sucesso!", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
            })

        case .Atualizar:
            RealmParse.auSurgery(id: recordID, record: record, formValues: self.form.values(includeHidden: false), preSugicalPlaningForm: self.preSurgicalPlanningForm, postSugicalPlaningForm: self.postSurgicalPlanningForm, compareImages: getImages())

            let alertView = SCLAlertView()
            alertView.showSuccess("🎉🎉🎉🎉", subTitle: "Cirurgia atualizada com sucesso!", closeButtonTitle: "OK", colorStyle: 0x4C6B94, colorTextButton: 0xFFFFFF)
            
            if patient != nil{
                self.navigationItem.titleView = Helpers.setTitle("\(patient!.name)", subtitle: "Dados Cirurgia")
            }else{
                self.navigationItem.titleView = nil
                self.title = "Dados da Cirurgia"
            }
            self.form.setValues(self.form.values(includeHidden: false))
            
            self.navigationItem.leftBarButtonItem = Device().isPad ? UIBarButtonItem(title: "Fechar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(noData)) : nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editBarBtn))
            self.tableView?.reloadData()

        case .Nil : return
        }
    }
    
    func getImages() -> [CompareImage]{
        var compareImages:[CompareImage] = [CompareImage]()
        let btnArray = [self.btnFront, self.btnProfileRight, self.btnNasal, self.btnObliqueLeft, self.btnProfileLeft, self.btnObliqueRight]
        var images: [Image] = [Image]()
        let compareImage = CompareImage()
        compareImage.recordID = recordID
        compareImage.reference = 0.toString()
        
        if record != nil {
            for comapareImg in record.compareImage {
                if comapareImg.reference == 0.toString() {
                    compareImage.id = comapareImg.id
                    compareImage.create_at = comapareImg.create_at
                    compareImage.date = comapareImg.date
                    for image in compareImage.image {
                        images.append(image)
                    }
                }
            }
        }
        //    case Front, ProfileRight, Nasal, ObliqueLeft, ObliqueRight, ProfileLeft
        for btn in btnArray {
            if btn.currentImage != nil {
                switch btn {
                case self.btnFront:
                    compareImage.image.append(RealmParse.image(recordID,compareImageID: compareImage.id , imageRef: 0, imageType: ImageTypes.Front.hashValue, fileName: "[\(0)]Front-\(recordID)", image: btn.currentImage!, points: frontPoints != nil ? frontPoints : nil, uImage: RealmParse.imageObject(0, compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.Front.hashValue)))
                case self.btnProfileRight:
                    compareImage.image.append(RealmParse.image(recordID,compareImageID: compareImage.id , imageRef: 0, imageType: ImageTypes.ProfileRight.hashValue, fileName: "[\(0)]ProfileRight-\(recordID)", image: btn.currentImage!, points: profileRightPoints != nil ? frontPoints : nil, uImage: RealmParse.imageObject(0, compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ProfileRight.hashValue)))
                case self.btnNasal:
                    compareImage.image.append(RealmParse.image(recordID,compareImageID: compareImage.id , imageRef: 0, imageType: ImageTypes.Nasal.hashValue, fileName: "[\(0)]Nasal-\(recordID)", image: btn.currentImage!, points: nasalPoints != nil ? frontPoints : nil, uImage: RealmParse.imageObject(0, compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.Nasal.hashValue)))
                case self.btnObliqueLeft:
                    compareImage.image.append(RealmParse.image(recordID,compareImageID: compareImage.id , imageRef: 0, imageType: ImageTypes.ObliqueLeft.hashValue, fileName: "[\(0)]ObliqueLeft-\(recordID)", image: btn.currentImage!, points: nil, uImage: RealmParse.imageObject(0, compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ObliqueLeft.hashValue)))
                case self.btnProfileLeft:
                    compareImage.image.append(RealmParse.image(recordID,compareImageID: compareImage.id , imageRef: 0, imageType: ImageTypes.ProfileLeft.hashValue, fileName: "[\(0)]ProfileLeft-\(recordID)", image: btn.currentImage!, points: nil, uImage: RealmParse.imageObject(0, compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ProfileLeft.hashValue)))
                case self.btnObliqueRight:
                    compareImage.image.append(RealmParse.image(recordID,compareImageID: compareImage.id , imageRef: 0, imageType: ImageTypes.ObliqueRight.hashValue, fileName: "[\(0)]ObliqueRight-\(recordID)", image: btn.currentImage!, points: nil, uImage: RealmParse.imageObject(0, compareImages: record?.compareImage, imageTypeHashValue: ImageTypes.ObliqueRight.hashValue)))
                default: continue
                }
            }
        }
        
        compareImages.append(compareImage)
        
        for compareImg in self.compareImages {
            compareImages.append(compareImg)
        }
        
        return compareImages
    }
    
    //--------------------
    
    private func initializeForm() {
        
        DateInlineRow.defaultRowInitializer = { row in row.maximumDate = NSDate() }
        
        form +++
            
            Section(header: "", footer: "Aqui você pode colocar do que se trata a cirurgia, a especificação, por ex. \rObs: Esta opção passará a ser obrigatória em futuras atualizações.")
            <<< NameRow("surgeryDescription") {
                $0.title = "Nome da Cirurgia:"
            }
            
            +++ Section("") {
                $0.tag = "recover_patient"
            }
            
            <<< ButtonRow("btn_recover_patient") { (row: ButtonRow) -> Void in
                row.title = "Recuperar Paciente:"
                row.value = "false"
                row.presentationMode = PresentationMode.SegueName(segueName: "RecoverPatientSegue", completionCallback: nil)
            }
            
            <<< LabelRow ("cleanPatient") {
                $0.title = "Limpar Paciente"
                $0.hidden = "$btn_recover_patient != 'true'"
                }.onCellSelection({ (_, _) in
                    
                    let alert:UIAlertController = UIAlertController(title: "Atenção!", message: "O paciente desta cirurgia não é \(self.patient!.name)?", preferredStyle: Device().isPad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Limpar", style: UIAlertActionStyle.Destructive, handler: { (delete) -> Void in
                        self.patient = nil
                        self.form.rowByTag("btn_recover_patient")?.baseCell.imageView!.image = nil
                        self.form.rowByTag("btn_recover_patient")?.title = "Recuperar Paciente:"
                        self.form.rowByTag("btn_recover_patient")?.baseValue = "false"
                        self.form.rowByTag("btn_recover_patient")?.updateCell()
                        self.form.sectionByTag("recover_patient")?.header?.title = ""
                        self.form.sectionByTag("recover_patient")?.reload()

                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    

                })
            
            +++ Section("Dados do Paciente"){
                $0.tag = "patient_data"
                $0.hidden = "$btn_recover_patient != 'false'"

            }
            
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
            
//            +++ Section(){
//                $0.hidden = contentToDisplay == .Atualizar ? false : true
//            }
//            
//            //Ira servir para compara as imagens futuramente
//            <<< ButtonRow("btn_compare_images") { (row: ButtonRow) -> Void in
//                row.title = "Imagens"
//                row.presentationMode = PresentationMode.SegueName(segueName: "CompareImagesSegue", completionCallback: nil)
//            }
            
            +++ Section("Dados da Cirurgia")
            
            <<< ButtonRow("btn_plano_cirurgico") { (row: ButtonRow) -> Void in
                row.title = "Plano Cirurgico"
                row.presentationMode = PresentationMode.SegueName(segueName: "SurgeryPlanSegue", completionCallback: nil)
            }
            
            <<< SwitchRow("surgeryRealized") {
                $0.title = "Cirurgia Realizada?"
                $0.value = false
                
            }
            
            <<< DateInlineRow("date_of_surgery") {
                $0.hidden = "$surgeryRealized == false"
                $0.title = "Data da Cirurgia:"
                $0.value = NSDate()
                let formatter = NSDateFormatter()
                formatter.locale = .currentLocale()
                formatter.dateStyle = .ShortStyle
                $0.dateFormatter = formatter
            }
            
            <<< ButtonRow("btn_cirurgia_realizada") { (row: ButtonRow) -> Void in
                row.title = "Relatório Cirúgico"
                row.hidden = "$surgeryRealized == false"
                row.presentationMode = PresentationMode.SegueName(segueName: "SurgeryPlanSegue", completionCallback: nil)
            }
            
            +++ Section("Notas")
            <<< TextAreaRow("note") { $0.placeholder = "Esta cirurgia..." }
    }
    
    //--------------------
    
    
    // MARK: - Tela Sem Dados
    
    func noData(){
        
        let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        imageView.image = UIImage(named: "LabInC")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.sizeToFit()
        
        
        let messageLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        messageLabel.text = "Clique em uma cirrurgia para carregar os dados. "
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 5
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        messageLabel.sizeToFit()
        
        self.tableView!.backgroundView = imageView
        self.tableView!.backgroundView?.hidden = false
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.header.hidden = true
        
        self.form.removeAll()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        self.tableView!.reloadData()
        self.title = nil
        self.navigationItem.titleView = nil
    }
    
    //--------------------
    func setButtons() {
        self.btnFront.addTarget(self, action: #selector(SurgeryDetailsVC.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.btnProfileRight.addTarget(self, action: #selector(SurgeryDetailsVC.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.btnNasal.addTarget(self, action: #selector(SurgeryDetailsVC.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        self.btnObliqueLeft.addTarget(self, action: #selector(SurgeryDetailsVC.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.btnProfileLeft.addTarget(self, action: #selector(SurgeryDetailsVC.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.btnObliqueRight.addTarget(self, action: #selector(SurgeryDetailsVC.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func showOptions(sender: UIButton!) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            switch sender {
            case self.btnFront: self.imageType = .Front
            case self.btnProfileRight: self.imageType = .ProfileRight
            case self.btnNasal: self.imageType = .Nasal
            case self.btnObliqueLeft: self.imageType = .ObliqueLeft
            case self.btnProfileLeft: self.imageType = .ProfileLeft
            case self.btnObliqueRight: self.imageType = .ObliqueRight
            default: self.imageType = .Front
            }
            
            if sender.currentImage == nil {
                self.performSegueWithIdentifier(Device().isPad ? "iPadCameraSegue" : "iPhoneCameraSegue", sender: nil)
                return
            }
            
            var availableSources: ImageRowSourceTypes = []
            
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                availableSources.insert(.PhotoLibrary)
            }
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                availableSources.insert(.Camera)
            }
            if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
                availableSources.insert(.SavedPhotosAlbum)
            }
            
            
            self.sourceTypes.intersectInPlace(availableSources)
            
            if self.sourceTypes.isEmpty {
                return
            }
            
            // now that we know the number of actions aren't empty
            let sourceActionSheet = UIAlertController(title: nil, message: "UFPI", preferredStyle: .ActionSheet)
            if let popView = sourceActionSheet.popoverPresentationController {
                sourceActionSheet.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                popView.sourceView = sender
                popView.sourceRect = sender.bounds
                
            }
            
            if self.sourceTypes.contains(.Camera) {
                let cameraOption = UIAlertAction(title: NSLocalizedString("Tirar Foto", comment: ""), style: .Default, handler: { (_) in
                    self.performSegueWithIdentifier(Device().isPad ? "iPadCameraSegue" : "iPhoneCameraSegue", sender: nil)
                })
                sourceActionSheet.addAction(cameraOption)
            }
    
    
            switch self.showAction {
            case .Yes(let style):
                if let _ = sender.currentImage {
                    let showPhotoOption = UIAlertAction(title: NSLocalizedString("Processar Imagem", comment: ""), style: style, handler: { (_) in
                        self.performSegueWithIdentifier("ShowImageSegue", sender: nil)
                    })
                    sourceActionSheet.addAction(showPhotoOption)
                }
            case .No:
                break
            }
            
            switch self.clearAction {
            case .Yes(let style):
                if let _ = sender.currentImage {
                    let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Apagar Imagem", comment: ""), style: style, handler: { (_) in
                        sender.setImage(nil, forState: UIControlState.Normal)
                        let realm = try! Realm()
                        if self.record != nil{
                            for compImg in self.record.compareImage {
                                if compImg.reference == 0.toString() {
                                    for image in compImg.image {
                                        if Int(image.imageType) == self.imageType.hashValue {
                                            if RealmParse.cloud.isLogIn() != CloudTypes.LogOut {

                                                try! realm.write {
                                                    
                                                    //CompareImage
                                                    compImg.image.removeAtIndex(compImg.image.indexOf(image)!)                                                     
                                                    //Image
                                                    image.cloudState = CloudState.Delete.rawValue
                                                    
                                                    realm.add(compImg, update: true)
                                                    realm.add(image, update: true)
                                                }
                                                
                                            }else {
                                                RealmParse.deleteImage(image)
                                            }
                                        }
                                    }

                                }
                            }
                        }
                        switch sender {
                        case self.btnFront: self.frontPoints = nil
                        case self.btnProfileRight: self.profileRightPoints = nil
                        case self.btnNasal: self.nasalPoints = nil
                        default : return
                        }
                        
                    })
                    sourceActionSheet.addAction(clearPhotoOption)
                }
            case .No:
                break
            }
            
            // check if we have only one source type given
            if sourceActionSheet.actions.count == 1 {
                
            } else {
                
                
            }
            sourceActionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .Cancel, handler:nil))


            dispatch_async(dispatch_get_main_queue(), { 
                self.presentViewController(sourceActionSheet, animated: true, completion: nil)
                sourceActionSheet.view.layoutIfNeeded()
            })
        }
    }
    
    
    //MARK: - Pressionou o btn Cancelar
    
    func cancelPressed(button: UIBarButtonItem){
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == (Device().isPad ? "iPadCameraSegue" : "iPhoneCameraSegue"){
            if let camera = segue.destinationViewController as? CameraVC{
                camera.delegate = self
                camera.imageType = self.imageType
            }
        }
        
        if segue.identifier == "ShowImageSegue"{
            if let showImagePoints = segue.destinationViewController as? ProcessImageVC{
                showImagePoints.delegate = self
                showImagePoints.imageType = self.imageType
                
                switch imageType {
                case .Front:        showImagePoints.image = self.btnFront.currentImage!
                                    showImagePoints.points = self.frontPoints
                                    showImagePoints.pointsUpdated = self.frontPoints
                    
                case .ProfileRight: showImagePoints.image = self.btnProfileRight.currentImage!
                                    showImagePoints.points = self.profileRightPoints
                                    showImagePoints.pointsUpdated = self.profileRightPoints
                    
                case .Nasal:        showImagePoints.image = self.btnNasal.currentImage!
                                    showImagePoints.points = self.nasalPoints
                                    showImagePoints.pointsUpdated = self.nasalPoints
                    
                case .ObliqueLeft:  showImagePoints.image = self.btnObliqueLeft.currentImage!
                    
                case .ProfileLeft:  showImagePoints.image = self.btnProfileLeft.currentImage!
                    
                case .ObliqueRight: showImagePoints.image = self.btnObliqueRight.currentImage!

                }
            }
        }
        
        if segue.identifier == "SurgeryPlanSegue"{
            let controller = segue.destinationViewController as! SurgicalPlanVC
            
            controller.delegate = self
            
            if let test = sender as? ButtonRow {
                if test.tag == "btn_plano_cirurgico"{
                    controller.surgicalPlanning = .PreSurgical
                    controller.dicFormValues = self.preSurgicalPlanningForm
                }else if test.tag == "btn_cirurgia_realizada"{
                    controller.surgicalPlanning = .PostSurgical
                    controller.dicFormValues = self.postSurgicalPlanningForm
                }
            }
        }
        
        if segue.identifier == "RecoverPatientSegue"{
            let controller = segue.destinationViewController as! PatientsTableVC
            controller.delegate = self
            if let test = sender as? ButtonRow {
                if test.tag == "btn_recover_patient"{
                    controller.patientShow = .CheckPatient
                    controller.patient = patient
                }
            }
        }
        
        if segue.identifier == "CompareImagesSegue"{
            let controller = segue.destinationViewController as! CompareImagesController
            if let btn_compare_images = sender as? ButtonRow {
                if btn_compare_images.tag == "btn_compare_images"{
                    controller.compareImages = self.getImages()
                    controller.record = record
                }
            }
        }
        
    }
}
extension SurgeryDetailsVC: RecoverPatient {
    func recoverPatient(patient: Patient?) {

        if patient != nil {
            self.patient = patient
            for record in patient!.records {
                for compareImage in record.compareImage {
                    if compareImage.reference == 0.toString() {
                        for image in compareImage.image {
                            if image.name != "" && image.imageType == "\(ImageTypes.Front.hashValue)" {
                                RealmParse.getFile(fileName: image.name, fileExtension: .JPG, completionHandler: { (object, error) in
                                    if error != nil {
                                        print(error!.description)
                                    }else {
                                        self.form.rowByTag("btn_recover_patient")?.baseCell.imageView!.image = object as? UIImage
                                    }
                                })
                                
                                break
                            }
                        }
                    }
                }
            }
            self.form.rowByTag("btn_recover_patient")?.title = "\(patient!.name)"
            self.form.rowByTag("btn_recover_patient")?.baseValue = "true"
            self.form.rowByTag("btn_recover_patient")?.updateCell()

            self.form.sectionByTag("recover_patient")?.header?.title = "Paciente"
            self.form.sectionByTag("recover_patient")?.reload()
        }else{
            self.patient = nil
            self.form.rowByTag("btn_recover_patient")?.baseCell.imageView!.image = nil
            self.form.rowByTag("btn_recover_patient")?.title = "Recuperar Paciente:"
            self.form.rowByTag("btn_recover_patient")?.baseValue = "false"
            self.form.rowByTag("btn_recover_patient")?.updateCell()
            
            self.form.sectionByTag("recover_patient")?.header?.title = ""
            self.form.sectionByTag("recover_patient")?.reload()
        }

    }
}

extension SurgeryDetailsVC: RecordImageDelegate{
    func updateData(image image: UIImage, ImageType: ImageTypes) {
        switch imageType {
        case .Front:        self.btnFront.setImage(image, forState: UIControlState.Normal)
            
        case .ProfileRight: self.btnProfileRight.setImage(image, forState: UIControlState.Normal)
            
        case .Nasal:        self.btnNasal.setImage(image, forState: UIControlState.Normal)
            
        case .ObliqueLeft:  self.btnObliqueLeft.setImage(image, forState: UIControlState.Normal)
            
        case .ProfileLeft:  self.btnProfileLeft.setImage(image, forState: UIControlState.Normal)
            
        case .ObliqueRight: self.btnObliqueRight.setImage(image, forState: UIControlState.Normal)
            
        }
    }
}
extension SurgeryDetailsVC: RecordPointsDelegate{
    func updateData(points points: [String : NSValue]?, ImageType: ImageTypes) {
        switch imageType {
        case .Front:        self.frontPoints = points
            
        case .ProfileRight: self.profileRightPoints = points
            
        case .Nasal:        self.nasalPoints = points
            
        case .ObliqueLeft:  return
            
        case .ProfileLeft:  return
            
        case .ObliqueRight: return
            
        }
    }
}

extension SurgeryDetailsVC: SurgicalPlan{
    func updateSurgicalPlanning(surgicalPlanningForm: [String : Any?], SurgicalPlanningType: SurgicalPlanningTypes) {
        
        switch SurgicalPlanningType {
        case .PreSurgical:
            self.preSurgicalPlanningForm = surgicalPlanningForm
        case .PostSurgical:
            self.postSurgicalPlanningForm = surgicalPlanningForm
        }
        
    }
}