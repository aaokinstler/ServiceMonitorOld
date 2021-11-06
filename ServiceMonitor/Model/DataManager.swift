//
//  DataManager.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 02.09.2021.
//
import CoreData

class DataManager {
    
    var dataController: DataController
    var backgroundContext: NSManagedObjectContext
    var updatingTimeInterval: TimeInterval
    var autoUpdateIsOn: Bool
    
    var object: MonitorObject?
    
    init() {
        dataController = DataController()
        dataController.load()
        backgroundContext = dataController.backgroundContext
        updatingTimeInterval = 0
        autoUpdateIsOn = false
    }
    
    // MARK: Auto-update
    func startAutoupdate() {
        if updatingTimeInterval == 0 {
            updatingTimeInterval = 15
            if !autoUpdateIsOn {
                autoUpdateIsOn = true
                autoupdateData()
            }
        }
    }
    
    func stopAutoUpdate() {
        updatingTimeInterval = 0
    }
    
    // MARK: Update monitor
    func updateMonitorData() {
        backgroundContext.perform {
            ServiceClient.getMonitorStatus(completion: self.handleMonitorStatus(monitorGroups:error:))
        }
    }
    
    private func handleMonitorStatus(monitorGroups: [MonitorGroup]?, error: String?) {
        guard error == nil else {
            let errorDataDict:[String: String] = ["error": error!]
            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
            return
        }
        
        var ids: [Int] = []
        
        monitorGroups?.forEach{ group in
            if let groupObject = Group.instance(id: group.id, context: backgroundContext) {
                groupObject.updateGroupStatus(data: group, parentGroup: nil, context: backgroundContext)
            } else {
                _ = Group.createEntityObject(data: group, parentGroup: nil, context: backgroundContext)
            }
            
            ids.append(group.id)
        }
        
        deleteRootGroups(ids: ids)
        

        try! backgroundContext.save()
        NotificationCenter.default.post(name: .didUpdateGroup, object: nil)
    }
    
    private func deleteRootGroups(ids: [Int]) {
        let request:NSFetchRequest<Group> = Group.fetchRequest()
        let predicate = NSPredicate(format: "group == nil && NOT (monitorId IN %@)", ids)
        request.predicate = predicate
        
        let groupsToDelete =  try! backgroundContext.fetch(request)
        groupsToDelete.forEach() { groupToDelete in
            backgroundContext.delete(groupToDelete)
        }

    }
    
    // MARK: Update group
    func updateGroupData(id: Int) {
        backgroundContext.perform {
            ServiceClient.getGroupStatus(id: id, completion: self.handleGroupStatus(monitorGroup:error:))
        }
    }
    
    private func handleGroupStatus(monitorGroup: MonitorGroup?, error: String?) {
        guard error == nil else {
            let errorDataDict:[String: String] = ["error": error!]
            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
            return
        }

        guard let groupObject = Group.instance(id: monitorGroup!.id, context: backgroundContext) else {
            let errorDataDict:[String: String] = ["error": "Parent group for group currently being updated was not found."]
            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
            return
        }
        
        var parentGroup: Group? = nil
        
        if let parentGroupId = monitorGroup?.parent {
            parentGroup = Group.instance(id: parentGroupId, context: backgroundContext)
        }
        
        groupObject.updateGroupStatus(data: monitorGroup!, parentGroup: parentGroup, context: backgroundContext)
        
        try! backgroundContext.save()
        NotificationCenter.default.post(name: .didUpdateGroup, object: nil)
    }
    
    // MARK: Update service
    func updateServiceData(id: Int) {
        backgroundContext.perform {
            ServiceClient.getServiceStatus(id: id, completion: self.handleServiceUpdate(monitorService:error:))
        }
    }
    
    private func handleServiceUpdate(monitorService: MonitorService?, error: String?) {
        guard error == nil else {
            let errorDataDict:[String: String] = ["error": error!]
            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
            return
        }
        
        guard let serviceObject = Service.instance(id: monitorService!.id!, context: backgroundContext)  else {
            let errorDataDict:[String: String] = ["error": "Service currently being updated was not found."]
            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
            
            return
        }
        
        guard let parentGroup = Group.instance(id: (monitorService?.parent)!, context: backgroundContext) else {
            let errorDataDict:[String: String] = ["error": "Parent group for service currently being updated was not found."]
            NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: errorDataDict)
            return
        }
        
        serviceObject.updateService(data: monitorService!, parentGroup: parentGroup, context: backgroundContext)
        
        try! backgroundContext.save()
        NotificationCenter.default.post(name: .didUpdateService, object: nil)
        
    }
}

extension DataManager {
    
    func autoupdateData() {

        guard updatingTimeInterval > 0 else {
            autoUpdateIsOn = false
            return
        }
        
        if let object = object {
            if object.entity.name == "Group" {
                let groupObject = object as! Group
                self.updateGroupData(id: Int(groupObject.monitorId))
            } else {
                let serviceObject = object as! Service
                self.updateServiceData(id: Int(serviceObject.monitorId))
            }
            
        } else {
            self.updateMonitorData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + updatingTimeInterval) {
            self.autoupdateData()
        }
    }
}
