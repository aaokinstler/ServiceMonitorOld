//
//  GroupViewController.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 27.09.2021.
//

import UIKit
import CoreData

class GroupViewController: MonitorObjectViewController {
    
//    var groupObject:Group!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        if object == nil {
            object = Group.createEntityObject(context: dataManager.dataController.viewContext)
        }
        super.viewDidLoad()
        setView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func setView() {
        super.setView()
        nameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer) {
        if let responderView = view.currentFirstResponder() as? UIView {
            responderView.endEditing(false)
        }
    }
    
    func setViewData() {
        let obj = object as! Group
        idLabel.text = String(obj.monitorId)
        nameTextField.text = obj.name
    }
    
    override func setSavingActivity(saving: Bool) {
        nameTextField.isEnabled = !saving
        super.setSavingActivity(saving: saving)
    }


    
    // MARK: 
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertVC = UIAlertController(title: "Warning!", message: "Group will be deleted! Are you shure?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteButton(_:)))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func handleDeleteButton(_ sender: Any) {
        let object  = object as! Group
        ServiceClient.deleteOnMonitor(id: Int(object.monitorId), url: Endpoints.deleteGroup(id: Int(object.monitorId)).url) { success, error in
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
        let groupObject = object as! Group
        let monitorGroup = groupObject.getMonitorGroup()
        if monitorGroup.id != nil {
            ServiceClient.updateOnMonitor(serviceObject: monitorGroup, url: Endpoints.updateGroup.url, completion: handleUpdate(success:error:))
        } else {
            ServiceClient.addToMonitor(serviceObject: monitorGroup, url: Endpoints.addGroup.url, completion: handleSaving(id:error:))
        }
    }
    
    // MARK: CRUD operations handling
    
    func handleSaving(id: Int?, error: String?) {
        guard let id = id else {
            showFailure(title: "Error", message: error ?? "Something go wrong!")
            setSavingActivity(saving: false)
            return
        }
        
        let object = object as! Group
        object.monitorId = Int16(id)
        try! dataManager.dataController.viewContext.save()
        setViewData()
        setSavingActivity(saving: false)
    }
    

}

extension GroupViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        object.name = textField.text
    }
}
