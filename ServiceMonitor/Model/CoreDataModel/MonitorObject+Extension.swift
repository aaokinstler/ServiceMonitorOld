//
//  Service+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//

import CoreData

extension MonitorObject {
    // Changing parent group content if we changed parent
    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if self.isDeleted && !self.isInserted{ // skip this step on deleting. Core data will do it for us.
            return
        }
        if key == "group" {
            if let group = group {
                if self.entity.name == "Group" {
                    group.addToGroups(self as! Group)
                } else {
                    group.addToServices(self as! Service)
                }
            }
        }
    }
    
    public override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        if self.isDeleted && !self.isInserted {
            return
        }
        if key == "group" {
            if let group = group {
            
                if self.entity.name == "Group" {
                    group.removeFromGroups(self as! Group)
                } else {
                    group.removeFromServices(self as! Service)
                }
            }
        }
    }
}
