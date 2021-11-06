//
//  Service+Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.09.2021.
//

import CoreData

extension MonitorObject {
    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == "group" {
            if self.group != nil {
                if self.entity.name == "Group" {
                    self.group?.addToGroups(self as! Group)
                } else {
                    self.group?.addToServices(self as! Service)
                }
            }
        }
    }
    
    public override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        if key == "group" {
            if self.group != nil {
                if self.entity.name == "Group" {
                    group?.removeFromGroups(self as! Group)
                } else {
                    group?.removeFromServices(self as! Service)
                }
            }
        }
    }
}
