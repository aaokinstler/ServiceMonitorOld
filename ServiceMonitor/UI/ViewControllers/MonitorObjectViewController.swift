import UIKit
import CoreData

class MonitorObjectViewController: UIViewController {
    
    var object: MonitorObject!
    var parentGroup: Group!
    var groupPicker: UIPickerView!
    var groupPickerDS: GroupPickerDataSource!
    var saveObserverToken: Any?
    
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var savingIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTextField.text = parentGroup?.name
        setSaveButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeSaveNotificationObserver()
        
        guard let object = object else {
            return
        }
        
        // roll back unsaved changes
        if object.isInserted {
            DataManager.shared.viewContext.delete(object)
            DataManager.shared.saveViewContext()
            return
        }
        
        if object.hasChanges {
            DataManager.shared.viewContext.rollback()
            DataManager.shared.saveViewContext()
        }
    }
    
    // show or hide save button
    func setSaveButton() {
        saveButton.isHidden = !object.hasChanges
        deleteButton.isEnabled = !object.isInserted
        if object.hasChanges {
            DataManager.shared.stopAutoUpdate()
        } else {
            DataManager.shared.startAutoupdate()
        }
    }
    
    // setting up view controller
    func setView() {
        initGroupPicker()
        if parentGroup != nil {
            setCurrentGroup()
        }
        removeSaveNotificationObserver()
        saveObserverToken =  NotificationCenter.default.addObserver(self, selector: #selector (handleDidChangeNotification(_ :)), name: .NSManagedObjectContextObjectsDidChange, object: DataManager.shared.viewContext)
    }
    
    func removeSaveNotificationObserver() {
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func initGroupPicker() {
        groupPicker = UIPickerView()
        groupPickerDS = GroupPickerDataSource(dataController: DataManager.shared.dataController, object: object, textView: groupTextField)
        groupPicker.dataSource = groupPickerDS
        groupPicker.delegate = groupPickerDS
        groupTextField.inputView = groupPicker
    }
        
    func setCurrentGroup() {
        // Setting right group to group picker
        var index = 0
        groupSelectLoop: for group in groupPickerDS.objects {
            if group == parentGroup {
                break groupSelectLoop
            }
            index+=1
        }
        
        groupPicker.selectRow(index, inComponent: 0, animated: false)
    }
    
    // handle errors
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

    // set view for server exchange
    func setSavingActivity(saving: Bool) {
        groupTextField.isEnabled = !saving
        
        if saving {
            DataManager.shared.stopAutoUpdate()
            saveButton.isHidden = true
            savingIndicator.startAnimating()
        } else {
            savingIndicator.stopAnimating()
            setSaveButton()
        }
    }
    
    // set save button after object changes
    @objc func handleDidChangeNotification(_ notification: NSNotification) {
        if let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           updated.contains(object){
            setSaveButton()
        }
    }
    
    // handle server responce after insert or update operation
    func handleUpdate(success: Bool, error: String?) {
        guard success else {
            self.showFailure(title: "Error", message: error ?? "Something goes wrong")
            setSavingActivity(saving: false)
            return
        }
        
        DataManager.shared.saveViewContext()
        setSavingActivity(saving: false)
    }
}
