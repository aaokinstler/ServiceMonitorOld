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
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        }
    }
    
    func saveViewContext () {
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
