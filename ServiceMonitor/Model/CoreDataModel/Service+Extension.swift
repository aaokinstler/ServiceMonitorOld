//
//  Service+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//
import CoreData

extension Service {
    
    // Get core data instance
    class func instance(id: Int, context: NSManagedObjectContext) -> Service? {
        
        let request:NSFetchRequest<Service> = Service.fetchRequest()
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
    
    // Create object from server
    class func createEntityObject(data: MonitorService, parentGroup: Group,context: NSManagedObjectContext) -> Service {
        let newService = NSEntityDescription.insertNewObject(forEntityName: "Service", into: context) as! Service
        newService.setValue(data.id, forKey: "monitorId")
        newService.setValue(data.name, forKey: "name")
        newService.setValue(data.description, forKey: "descr")
        newService.setValue(data.interval, forKey: "interval")
        newService.setValue(data.address, forKey: "address")
        newService.setValue(parentGroup, forKey: "group")
        newService.setValue(data.type, forKey: "type")
        if let status = data.status {
            newService.setValue(Status.createEntityObject(data: status, context: context), forKey: "status")
        }
        if let ts = data.timeStamp {
            newService.setValue(NSDate(timeIntervalSince1970: ts/1000), forKey: "lastExecutionTime")
        }
        
        return newService
    }
    
    // Create empty object to fill it on client side.
    class func createEntityObject(parentGroup: Group, context: NSManagedObjectContext) -> Service {
        let newService = NSEntityDescription.insertNewObject(forEntityName: "Service", into: context) as! Service
        newService.group = parentGroup
        newService.type = 1
        return newService
    }
    
    // Update core data object from server
    func updateService(data: MonitorService, parentGroup: Group, context: NSManagedObjectContext) {
        name = data.name
        descr = data.description
        interval = Int32(data.interval)
        address = data.address
        if group != parentGroup {
            group = parentGroup
        }
        
        type = Int16(data.type)
        updateStatus(data: data, context: context)
    }
    
    func updateStatus(data: MonitorService, context: NSManagedObjectContext) {
        guard let monitorStatus = data.status ,let statusID = monitorStatus.id else {
            return
        }
        
        if let status = status {
            status.id = Int16(statusID)
            status.name = monitorStatus.name
            status.descr = monitorStatus.description
        } else {
            status = Status.createEntityObject(data: monitorStatus, context: context)
        }
        
        if let ts = data.timeStamp {
            lastExecutionTime = Date(timeIntervalSince1970: ts/1000)
        }
    }
    
    // Get object for server exchange
    func getMonitorService() throws -> MonitorService {
        
        guard let name = self.name else {
            throw ServiceFillingError.emptyName
        }
        
        guard self.type > 0 else {
            throw ServiceFillingError.emptyType
        }
        
        
        if self.type == 1 && self.interval == 0 {
            throw ServiceFillingError.emptyInterval
        }
        
        
        if self.type == 2 {
            if let address = address {
                if let _ = URL(string: address) {
                } else {
                    throw ServiceFillingError.emptyAddress
                }
            } else {
                throw ServiceFillingError.emptyAddress
            }
        }
        
        var parentGroupId: Int? = nil
        if let group = group  {
            parentGroupId = Int(group.monitorId)
        }
        
        let object = MonitorService(id: self.isInserted ? nil : Int(self.monitorId), name: name, type: Int(self.type), description: self.descr, address: address, interval: Int(self.interval), parent: parentGroupId, status: nil, timeStamp: nil, diff: nil)
        
        return object
    }
    
    // Get amount of time since last execution
    func getTimeFromLastExecution() -> String {
        guard let lastExecutionTime = lastExecutionTime else {
            return "Never"
        }
        
        let cal = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: lastExecutionTime, to: Date())
        var timerString = ""
        if cal.day ?? 0 > 0 {
            timerString.append("\(cal.day ?? 0)d ")
        }
        
        timerString.append(String(format: "%02d:%02d:%02d", cal.hour ?? 0, cal.minute ?? 0, cal.second ?? 0))
        return timerString;
    }
}

enum ServiceFillingError: Error {
    case emptyName
    case emptyType
    case emptyInterval
    case emptyAddress
}

extension ServiceFillingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyName:
                return NSLocalizedString("Service Name is emtpy! Please fill the name.", comment: "Empty Name")
        case .emptyType:
                return NSLocalizedString("Service type is epty! Please fill service type.", comment: "Empty Type")
        case .emptyInterval:
                return NSLocalizedString("Execution interval is empty! Please fill execution intarval.", comment: "Empty Interval")
        case .emptyAddress:
                return NSLocalizedString("Service address is empty or not valid! Please fill the address right.", comment: "Empty Address")
        }
    }
}
