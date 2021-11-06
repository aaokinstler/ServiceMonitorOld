//
//  MonitorGroup.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 01.09.2021.
//

import Foundation

struct MonitorGroup : Codable {
    let id: Int!
    let name: String
    let parent: Int!
    let sevicesWithStatus: [MonitorService]!
    let gruops : [MonitorGroup]!
}
