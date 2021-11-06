//
//  GroupPickerDataSource.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 26.09.2021.
//

import UIKit
import CoreData

class GroupPickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate, NSFetchRequestResult {
     
    var dataController: DataController!
    var objects: [Group]  = []
    var textView: UITextField
    var object: MonitorObject
    
    init(dataController: DataController, object: MonitorObject, textView:UITextField) {
        self.textView = textView
        self.object = object
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        
        if object.entity.name == "Group" {
            let predicate = NSPredicate(format: "self != %@", object.objectID)
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor = NSSortDescriptor(key: "monitorId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = dataController.viewContext
        do {
            try objects = context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return objects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return objects[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let groupObject = objects[row]
        textView.text = groupObject.name
        object.group = groupObject
    }
}
