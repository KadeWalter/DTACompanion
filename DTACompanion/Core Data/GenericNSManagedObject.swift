//
//  GenericNSManagedObject.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation
import CoreData

class GenericNSManagedObject: NSManagedObject {
    
    // Identifier used for generics when getting entity names
    class func identifier() -> String {
        return ""
    }
    
    // Function for getting managed object context
    class func GenericManagedObjectContext() -> NSManagedObjectContext {
        guard let appDel = AppDelegate.sharedAppDelegate else {
            fatalError("Could not get AppDelegate.sharedAppDelegate.")
        }
        return appDel.persistentContainer.viewContext
    }
    
}
