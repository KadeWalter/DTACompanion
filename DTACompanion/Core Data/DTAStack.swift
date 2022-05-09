//
//  DTAStack.swift
//  DTACompanion
//
//  Created by Kade Walter on 4/25/22.
//

import Foundation
import CoreData

final class DTAStack {
    
    static let modelName = "DTACompanion"
    static let model: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: modelURL) else { return NSManagedObjectModel() }
        return model
    }()
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: DTAStack.modelName, managedObjectModel: DTAStack.model)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    @discardableResult static func saveContext() -> Bool {
        saveContext(context)
    }
    
    @discardableResult static func saveContext(_ contextToSave: NSManagedObjectContext) -> Bool {
        if contextToSave != context {
            return false
        }
        
        context.perform {
            do {
                try contextToSave.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return true
    }
}
