//
//  MonitorService.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 01.09.2021.
//

import Foundation

struct MonitorService: Codable {
    let id: Int?
    let name: String
    let type: Int
    let description: String?
    let address: String?
    let interval: Int
    let parent: Int?
    let status: ServiceStatus?
    let timeStamp: Double?
    let diff: Int?
}

struct ServiceStatus: Codable {
    let id: Int?
    let name: String?
    let description: String?
}
