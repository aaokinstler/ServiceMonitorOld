//
//  MonitorService.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 01.09.2021.
//

import Foundation

// Server object that contains information about specific service
struct MonitorService: Codable {
    let id: Int? // Unique ID
    let name: String // Service name
    let type: Int // Service type 1 - executable,  2 - web service
    let description: String? //  Short description of the service
    let address: String? // URL of web service
    let interval: Int // The execution interval for the service. (For executable services)
    let parent: Int? // Unique ID of parent group
    let status: ServiceStatus? // Service status information.
    let timeStamp: Double? // Time stamp of last execution/check.
    let diff: Int? // Amount of seconds since last execution.
}

struct ServiceStatus: Codable {
    let id: Int?
    let name: String?
    let description: String?
}
