//
//  LootCard.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/16/22.
//

import Foundation
import CoreData

@objc(LootCard)
class LootCard: GenericNSManagedObject {
    @NSManaged public var desc: String
    @NSManaged public var title: String
    @NSManaged public var rarity: String
    @NSManaged public var game: Game
    
    class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save Loot Card Functions
extension LootCard {
    // Save a fresh set of loot cards when creating a game.
    static func saveLootCardsJSON(toGame game: Game, inContext context: NSManagedObjectContext) {
        guard
            let jsonPathUrl = Bundle.main.url(forResource: "LootCardsData", withExtension: "json"),
            let data = try? Data(contentsOf: jsonPathUrl),
            let cardData = try? JSONDecoder().decode(LootCardData.self, from: data)
        else { return }
        
        for card in cardData.lootCards {
            let lootCard = LootCard(context: context)
            lootCard.title = card.title
            lootCard.desc = card.desc
            lootCard.rarity = card.rarity
            lootCard.game = game
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save loot cards.")
        }
    }
}
 
// MARK: - Delete Loot Card Function
extension LootCard {
    static func deleteLootCards(fromGame game: Game, inContext context: NSManagedObjectContext) {
        for lootCard in game.lootCards {
            context.delete(lootCard)
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to delete loot cards.")
        }
    }
}

// MARK: - Loot Card Decodable Object Information
extension LootCard {
    struct LootCardData: Decodable {
        var lootCards: [CardInformation]
    }
    
    struct CardInformation: Decodable {
        var title: String
        var desc: String
        var rarity: String
    }
}
