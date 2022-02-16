//
//  Player.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation
import CoreData

@objc(Player)
class Player: GenericNSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var character: String
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save New Players
extension Player {
    class func savePlayer(withName name: String, character: String) -> Player {
        return savePlayer(withName: name, character: character, context: self.GenericManagedObjectContext())
    }
    
    class func savePlayer(withName name: String, character: String, context: NSManagedObjectContext) -> Player {
        let player = Player(context: context)
        player.name = name
        player.character = character
        
        do {
            try self.GenericManagedObjectContext().save()
        } catch {
            fatalError("Unexpected Error: \(error)")
        }
        return player
    }
}
