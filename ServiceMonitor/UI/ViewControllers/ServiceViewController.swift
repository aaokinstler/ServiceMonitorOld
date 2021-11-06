//
//  ServiceViewCintroller.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 19.09.2021.
//

import UIKit
import Firebase


class ServiceViewController: MonitorObjectViewController {
    
    var typePicker: UIPickerView!
    var updateObserverToken: Any?
    var refreshControl: UIRefreshControl!
   
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var intervalTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var intevalLabel: UILabel!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var lastExecutionTimeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if object == nil {
            object = Service.createEntityObject(context: dataManager.dataController.viewContext)
        }
        
        setView()
        initTypePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewData()
        subscribeToKeyboardNotifications()
        dataManager.object = object
        setRefreshControl()
        
        updateObserverToken = NotificationCenter.default.addObserver(self, selector: #selector(onServiceUpdate(_:)), name: .didUpdateService , object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let token = updateObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func setRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.scrollView.alwaysBounceVertical = true
        self.refreshControl.tintColor = UIColor.gray
        self.refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    @objc func loadData() {
        guard self.saveButton.isHidden else {
            refreshControl.endRefreshing()
            return
        }
        
        guard let object = object as? Service else {
            refreshControl.endRefreshing()
            return
        }

        dataManager.updateServiceData(id: Int(object.monitorId))

     }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertVC = UIAlertController(title: "Warning!", message: "Group will be deleted! Are you shure?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteButton(_:)))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func handleDeleteButton(_ sender: Any) {
        let object  = object as! Service
        ServiceClient.deleteOnMonitor(id: Int(object.monitorId), url: Endpoints.deleteService(id: Int(object.monitorId)).url) { success, error in
            guard success else {
                self.showFailure(title: "Error", message: error ?? "Something goes wrong")
                return
            }
            
            self.dataManager.dataController.viewContext.delete(object)
            try! self.dataManager.dataController.viewContext.save()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        setSavingActivity(saving: true)
        let object = object as! Service
        do {
            let monitorService = try object.getMonitorService()
            if monitorService.id != nil {
                ServiceClient.updateOnMonitor(serviceObject: monitorService, url: Endpoints.updateService.url
                                              , completion: handleUpdate(success:error:))
            } else {
                ServiceClient.addToMonitor(serviceObject: monitorService, url: Endpoints.addService.url, completion: handleSaving(id:error:))
            }
        } catch {
            showFailure(title: "Error", message: error.localizedDescription)
            setSavingActivity(saving: false)
        }

    }
    
    @IBAction func notificationSwitchChanged(_ sender: Any) {
        let object = object as! Service
        if notificationSwitch.isOn {
            Messaging.messaging().subscribe(toTopic: String(object.monitorId), completion: handleTopicSubscription(error:))
        } else {
            Messaging.messaging().unsubscribe(fromTopic: String(object.monitorId), completion: handleTopicSubscription(error:))
        }
    }
    
    
    @objc func handleTopicSubscription(error: Error!) {
        if let error = error {
            showFailure(title: "Error", message: error.localizedDescription)
            self.notificationSwitch.setOn(!self.notificationSwitch.isOn, animated: true)
            return
        }
        
        let object = object as! Service
        object.isSubscribed = self.notificationSwitch.isOn
        try! dataManager.dataController.viewContext.save()
        super.setSavingActivity(saving: false)
    }
    
    
    override func setView() {
        super.setView()
        nameTextField.delegate = self
        intervalTextField.delegate = self
        addressTextField.delegate = self
        descriptionTextField.delegate = self
    }
    
    override func setSavingActivity(saving: Bool) {
        nameTextField.isEnabled = !saving
        descriptionTextField.isEditable = !saving
        intervalTextField.isEnabled = !saving
        addressTextField.isEnabled = !saving
        typeTextField.isEnabled = !saving
        super.setSavingActivity(saving: saving)
    }
    
    func setViewData() {
        guard let object = object as? Service else {
            return
        }
        
        idLabel.text = String(object.monitorId)
        nameTextField.text = object.name
        descriptionTextField.text = object.descr
        typeTextField.text = ServiceTypes.init(rawValue: Int(object.type))?.stringValue
        intervalTextField.text = String(object.interval)
        addressTextField.text = object.address
        typeTextField.text = ServiceTypes(rawValue: Int(object.type))?.stringValue
        statusLabel.textColor = object.status?.getStatusColor() ?? .gray
        changeType(type: Int(object.type))
        notificationSwitch.setOn(object.isSubscribed, animated: false)
        setStatusData()
    }
    
    func setStatusData() {
        guard let object = object as? Service else {
            return
        }
        statusLabel.text = object.status?.name ?? "None"
        lastExecutionTimeLabel.text = object.getTimeFromLastExecution()
    }
    
    func changeType(type: Int) {
        switch type {
        case 1:
            intevalLabel.isHidden = false
            intervalTextField.isHidden = false
            addressLabel.isHidden = true
            addressTextField.isHidden = true
        case 2:
            intevalLabel.isHidden = true
            intervalTextField.isHidden = true
            addressLabel.isHidden = false
            addressTextField.isHidden = false
        default:
            intevalLabel.isHidden = false
            intervalTextField.isHidden = false
            addressLabel.isHidden = true
            addressTextField.isHidden = true
        }
    }
    
    
    func initTypePicker() {
        typePicker = UIPickerView()
        typePicker.dataSource = self
        typePicker.delegate = self
        typeTextField.inputView = typePicker
    }
    
    func handleSaving(id: Int?, error: String?) {
        guard let id = id else {
            showFailure(title: "Error", message: error ?? "Something go wrong!")
            setSavingActivity(saving: false)
            return
        }
        
        let object = object as! Service
        object.monitorId = Int16(id)
        try! dataManager.dataController.viewContext.save()
        setViewData()
        setSavingActivity(saving: false)
    }
    

    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func onServiceUpdate(_ notification: Notification) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        setStatusData()
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer) {
        if let responderView = view.currentFirstResponder() as? UIView {
            responderView.endEditing(false)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let responderView = view.currentFirstResponder() as! UIView
        let height: CGFloat = getKeyboardHeight(notification)
 

        if view.frame.maxY - responderView.frame.maxY < height {
            view.frame.origin.y = -height
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        if view.frame.minY < 0  {
            view.frame.origin.y = 0
        }
    }
}

extension ServiceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ServiceTypes(rawValue: row + 1)?.stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = row + 1
        typeTextField.text = ServiceTypes(rawValue: type)?.stringValue
        let object = object as! Service
        object.type = Int16(type)
        changeType(type: type)
    }
}

extension ServiceViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1: object.name = textField.text
        case 2: let object = object as! Service
            object.interval = Int16(textField.text ?? "") ?? 0
            textField.text = String(object.interval)
        case 3: let object = object as! Service
            object.address = textField.text
        default: return
        }
    }
}

extension ServiceViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        let object = object as! Service
        object.descr = textView.text
    }
}
