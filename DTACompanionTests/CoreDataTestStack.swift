//
//  CoreDataTestStack.swift
//  DTACompanionTests
//
//  Created by Kade Walter on 2/17/22.
//

import CoreData
import DTACompanion

class CoreDataTestStack: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        // Due to this being a unit test stack,
        // give it a description url path of /dev/null
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        
        // Assign that description to the container
        let container = NSPersistentContainer(name: "DTACompanion")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
}

