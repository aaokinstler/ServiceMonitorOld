//
//  Status+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//
import CoreData
import UIKit

extension Status {
    class func createEntityObject(data: ServiceStatus, context: NSManagedObjectContext) -> Status {
        let newStatus = NSEntityDescription.insertNewObject(forEntityName: "Status", into: context) as! Status
        newStatus.setValue(data.id, forKey: "id")
        newStatus.setValue(data.name, forKey: "name")
        newStatus.setValue(data.description, forKey: "descr")
        return newStatus
    }
    
    func getStatusColor() -> UIColor {
        switch id {
        case 1:
            return .customGreen
        case 2:
            return .customRed
        case 3:
            return .customYellow
        default:
            return .gray
        }
    }
}
