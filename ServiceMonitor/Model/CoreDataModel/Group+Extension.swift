//
//  Group+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//
import CoreData

extension Group {
    
    class func instance(id: Int, context: NSManagedObjectContext) -> Group? {
        
        let request:NSFetchRequest<Group> = Group.fetchRequest()
        let predicate = NSPredicate(format: "monitorId == %ld", id)
        request.predicate = predicate

        do {
            let objects = try context.fetch(request)
            return objects.first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    class func createEntityObject(data: MonitorGroup, parentGroup: Group?, context: NSManagedObjectContext) -> Group {
        let newGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
        newGroup.setValue(data.id, forKey: "monitorId")
        newGroup.setValue(data.name, forKey: "name")
        newGroup.setValue(parentGroup, forKey: "group")
        
        data.sevicesWithStatus.forEach { service in
            newGroup.addToServices(Service.createEntityObject(data: service, parentGroup: newGroup, context: context))
        }
        
        data.gruops.forEach { group in
            newGroup.addToGroups(Group.createEntityObject(data: group, parentGroup: newGroup, context: context))
        }
        
        return newGroup
    }
    
    class func createEntityObject(context: NSManagedObjectContext) -> Group {
        let newGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context) as! Group
        return newGroup
    }
    
    func updateGroupStatus(data: MonitorGroup, parentGroup: Group?, context: NSManagedObjectContext) {
        var ids: [Int] = []
        
        if self.name != data.name {
            self.name = data.name
        }
        
        if self.group != parentGroup {
            self.group = parentGroup
        }
        
        data.sevicesWithStatus.forEach { service in
            if let serviceObject = Service.instance(id: service.id!, context: context) {
                serviceObject.updateStatus(data: service, context: context)
            } else {
                self.addToServices(Service.createEntityObject(data: service, parentGroup: self, context: context))
            }
            ids.append(service.id!)
        }
        
        deleteSubServices(ids: ids, context: context)
        ids.removeAll()
        
        data.gruops.forEach { group in
            if let groupObject = Group.instance(id: group.id, context: context) {
                groupObject.updateGroupStatus(data: group, parentGroup: self ,context: context)
            } else {
                self.addToGroups(Group.createEntityObject(data: group, parentGroup: self, context: context))
            }
            ids.append(group.id)
        }
        
        deleteSubGroups(ids: ids, context: context)
    }
    
    func deleteSubGroups(ids: [Int], context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "NOT (monitorId IN %@)", ids)
        
        let groupsToDelete = self.groups?.filtered(using: predicate)
        groupsToDelete?.forEach() { group in
            context.delete(group as! NSManagedObject)
        }
    }
    
    func deleteSubServices(ids: [Int], context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "NOT (monitorId IN %@)", ids)
        
        let groupsToDelete = self.services?.filtered(using: predicate)
        groupsToDelete?.forEach() { group in
            context.delete(group as! NSManagedObject)
        }
    }
    
    func deleteSubObjects(ids: [Int], entityName: String, context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "NOT (monitorId IN %@)",  ids)
        fetchRequest.predicate = predicate

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext?.execute(batchDeleteRequest)
        } catch {
            print(error)
        }
        
    }

    
    
    func getMonitorGroup() -> MonitorGroup {
        var parentGroupId: Int? = nil
        if let group = group  {
            parentGroupId = Int(group.monitorId)
        }
        
        let object = MonitorGroup(id: self.isInserted ? nil : Int(self.monitorId), name: self.name!, parent: parentGroupId, sevicesWithStatus: nil, gruops: nil)
        return object
    }
    
    func getServicesOk() -> Int {
        guard let services = services else {
            return 0
        }
        
        var servicesOk = 0
        services.forEach { service in
            if (service as AnyObject).status!.id == 1 {
                servicesOk += 1
            }
        }
        
        return servicesOk
    }
}
