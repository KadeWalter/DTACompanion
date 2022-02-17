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
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save New Players
extension Player {
    class func savePlayer(withName name: String, character: String, index: Int) -> Player {
        return savePlayer(withName: name, character: character, index: index, context: self.GenericManagedObjectContext())
    }
    
    class func savePlayer(withName name: String, character: String, index: Int, context: NSManagedObjectContext) -> Player {
        let player = Player(context: context)
        player.name = name
        player.character = character
        player.index = Int64(index)
        
        do {
            try self.GenericManagedObjectContext().save()
        } catch {
            fatalError("Unexpected Error: \(error)")
        }
        return player
    }
}

//MARK: - Delete Players
extension Player {
    func deletePlayer() {
        return deletePlayer(context: Player.GenericManagedObjectContext())
    }
    
    func deletePlayer(context: NSManagedObjectContext) {
        context.delete(self)
        do {
            try context.save()
        } catch {
            fatalError("Unable to delete player.")
        }
    }
    
    class func deleteMultiplePlayers(players: Set<Player>) {
        deleteMultiplePlayers(players: players, context: self.GenericManagedObjectContext())
    }
    
    class func deleteMultiplePlayers(players: Set<Player>, context: NSManagedObjectContext) {
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
    func addLootCard(card: LootCard) {
        addLootCard(card: card, context: Player.GenericManagedObjectContext())
    }
    
    func addLootCard(card: LootCard, context: NSManagedObjectContext) {
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
