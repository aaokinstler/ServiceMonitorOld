//
//  DataController.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 02.09.2021.
//

import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "MonitorData")
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
   
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.configureContexts()
            completion?()
        }
    }
}
