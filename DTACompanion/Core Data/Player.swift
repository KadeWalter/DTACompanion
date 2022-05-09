//
//  Player.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation
import CoreData

@objc(Player)
class Player: NSManagedObject {
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
        DTAStack.saveContext()
        
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
        DTAStack.saveContext()
    }
    
    class func deleteMultiplePlayers(players: Set<Player>, inContext context: NSManagedObjectContext) {
        for player in players {
            context.delete(player)
        }
        DTAStack.saveContext()
    }
}

// MARK: - Add Loot Cards To A Player
extension Player {
    func addLootCard(card: LootCard, inContext context: NSManagedObjectContext) {
        if self.lootCards == nil {
            self.lootCards = Set<LootCard>()
        }
        self.lootCards?.insert(card)
        DTAStack.saveContext()
    }
}
