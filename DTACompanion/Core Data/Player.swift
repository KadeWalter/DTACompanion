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
    @NSManaged public var index: Int64
    @NSManaged public var lootCards: Set<LootCard>?
    
    class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save New Players
extension Player {
    class func savePlayer(withName name: String, character: String, index: Int, inContext context: NSManagedObjectContext) -> Player {
        let player = Player(context: context)
        player.name = name
        player.character = character
        player.index = Int64(index)
        
        do {
            try context.save()
        } catch {
            fatalError("Unexpected Error: \(error)")
        }
        return player
    }
}

// MARK: - Fetch Players
extension Player {
    class func findAll(inContext context: NSManagedObjectContext) -> [Player] {
        do {
            let request = NSFetchRequest<Player>(entityName: self.identifier())
            let sortByIndex = NSSortDescriptor(key: "index", ascending: true)
            request.sortDescriptors = [sortByIndex]
            let players = try context.fetch(request)
            return players
        } catch {
            return []
        }
    }
}

//MARK: - Delete Players
extension Player {
    func deletePlayer(inContext context: NSManagedObjectContext) {
        context.delete(self)
        do {
            try context.save()
        } catch {
            fatalError("Unable to delete player.")
        }
    }
    
    class func deleteMultiplePlayers(players: Set<Player>, inContext context: NSManagedObjectContext) {
        for player in players {
            context.delete(player)
        }
        do {
            try context.save()
        } catch {
            fatalError("Error deleting all players.")
        }
    }
}

// MARK: - Add Loot Cards To A Player
extension Player {
    func addLootCard(card: LootCard, inContext context: NSManagedObjectContext) {
        if self.lootCards == nil {
            self.lootCards = Set<LootCard>()
        }
        self.lootCards?.insert(card)
        
        do {
            try context.save()
        } catch {
            fatalError("Error saving loot cards")
        }
    }
}
