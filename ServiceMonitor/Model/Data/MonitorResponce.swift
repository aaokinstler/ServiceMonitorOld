//
//  MonitorResponce.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 03.10.2021.
//

struct MonitorResponce: Decodable {
    let success: Bool
    let id: Int?
    let description: String?
}
