//
//  Notification_Extension.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 26.10.2021.
//
import Foundation

extension Notification.Name {
    static let didUpdateGroup = Notification.Name("didUpdateGroup")
    static let didUpdateService = Notification.Name("didUpdateService")
    static let didReceiveError = Notification.Name("didReceiveError")
}

