//
//  MonitorResponce.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 03.10.2021.
//

// Server responce for create/update operations.
struct MonitorResponce: Decodable {
    let success: Bool
    let id: Int? // Unique ID for created objects (Contains nil for update operations).
    let description: String? // String description of error (contains nil for success operations)
}
