//
//  MonitorGroup.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 01.09.2021.
//

import Foundation

// Server object that contains services combined on a logical basis.
struct MonitorGroup : Codable {
    let id: Int! // Unique ID
    let name: String // Name
    let parent: Int! // Parent group upnique ID
    let sevicesWithStatus: [MonitorService]! // Subservices
    let gruops : [MonitorGroup]! // Subgroups
}
