import UIKit
import CoreData

class MonitorObjectViewController: UIViewController {
    
    var dataManager: DataManager!
    var object: MonitorObject!
    var parentGroup: Group!
    var groupPicker: UIPickerView!
    var groupPickerDS: GroupPickerDataSource!
    var saveObserverToken: Any?
    
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var savingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
        
        if object.isInserted {
            dataManager.dataController.viewContext.delete(object)
            return
        }
        
        if object.hasChanges {
            dataManager.dataController.viewContext.rollback()
        }
    }
    
    func initGroupPicker() {
        groupPicker = UIPickerView()
        groupPickerDS = GroupPickerDataSource(dataController: dataManager.dataController, object: object, textView: groupTextField)
        groupPicker.dataSource = groupPickerDS
        groupPicker.delegate = groupPickerDS
        groupTextField.inputView = groupPicker
    }
    
    func setView() {
        initGroupPicker()
        if parentGroup != nil {
            setCurrentGroup()
        }
        removeSaveNotificationObserver()
        saveObserverToken =  NotificationCenter.default.addObserver(self, selector: #selector (handleDidChangeNotification(_ :)), name: .NSManagedObjectContextObjectsDidChange, object: dataManager.dataController.viewContext)
    }
    
    func setCurrentGroup() {
        var index = 0
        groupSelectLoop: for group in groupPickerDS.objects {
            if group == parentGroup {
                break groupSelectLoop
            }
            index+=1
        }
        
        groupPicker.selectRow(index, inComponent: 0, animated: false)
    }
    
    
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func handleUpdate(success: Bool, error: String?) {
        guard success else {
            self.showFailure(title: "Error", message: error ?? "Something goes wrong")
            setSavingActivity(saving: false)
            return
        }
        
        try! self.dataManager.dataController.viewContext.save()
        setSavingActivity(saving: false)
    }
    
    func setSavingActivity(saving: Bool) {
        groupTextField.isEnabled = !saving
        
        if saving {
            dataManager.stopAutoUpdate()
            saveButton.isHidden = true
            savingIndicator.startAnimating()
        } else {
            savingIndicator.stopAnimating()
            setSaveButton()
        }
    }
    
    func removeSaveNotificationObserver() {
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func setSaveButton() {
        saveButton.isHidden = !object.hasChanges
        deleteButton.isEnabled = !object.isInserted
        if object.hasChanges {
            dataManager.stopAutoUpdate()
        } else {
            dataManager.startAutoupdate()
        }
    }
    
    @objc func handleDidChangeNotification(_ notification: NSNotification) {
        if let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           updated.contains(object){
            setSaveButton()
        }
    }
}
