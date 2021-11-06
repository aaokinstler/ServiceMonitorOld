//
//  ServiceTypes.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 19.09.2021.
//

enum ServiceTypes: Int {
     case executable = 1, webService
     
     var stringValue: String {
         switch self {
         case .executable:
             return "Executable"
         case .webService:
             return "Web service"
         }
     }
 }
