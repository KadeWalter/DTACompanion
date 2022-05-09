//
//  Game.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation
import CoreData

@objc(Game)
class Game: NSManagedObject {
    @NSManaged public var teamName: String
    @NSManaged public var numberOfPlayers: Int64
    @NSManaged public var legacyMode: Bool
    @NSManaged public var latestUpdate: Date
    @NSManaged public var difficulty: String
    @NSManaged public var players: Set<Player>
    @NSManaged public var lootCards: Set<LootCard>
    @NSManaged public var scenarios: Set<Scenario>?
    
    class func identifier() -> String {
        return String(describing: self)
    }
    
    func playersAsArray() -> [Player] {
        return Array(self.players).sorted(by: { $0.index < $1.index })
    }
    
    func player(forIndex index: Int) -> Player? {
        return self.players.filter({ $0.index == index}).first
    }
    
    func scenariosAsArray() -> [Scenario]? {
        if let scenarios = self.scenarios {
            return Array(scenarios).sorted(by: { $0.dateCreated < $1.dateCreated })
        }
        return nil
    }
    
    func addScenario(scenario: Scenario) {
        if self.scenarios == nil {
            self.scenarios = Set<Scenario>()
        }
        self.scenarios?.insert(scenario)
        DTAStack.saveContext()
    }
}

// MARK: - Save Games
extension Game {
    class func saveNewGame(teamName: String, numberOfPlayers: Int, legacyMode: Bool, difficulty: Difficulty, players: Set<Player>, dateCreated: Date, inContext context: NSManagedObjectContext) {
        let game = Game(context: context)
        game.teamName = teamName
        game.numberOfPlayers = Int64(numberOfPlayers)
        game.legacyMode = legacyMode
        game.latestUpdate = dateCreated
        game.difficulty = difficulty.rawValue
        game.players = players
        
        LootCard.saveLootCardsJSON(toGame: game, inContext: context)
        DTAStack.saveContext()
    }
}

// MARK: - Fetch Games
extension Game {
    class func findAll(inContext context: NSManagedObjectContext) -> [Game] {
        do {
            let request = NSFetchRequest<Game>(entityName: self.identifier())
            let sortByCreationDate = NSSortDescriptor(key: "latestUpdate", ascending: false)
            request.sortDescriptors = [sortByCreationDate]
            let games = try context.fetch(request)
            return games
        } catch {
            return []
        }
    }
}

// MARK: - Delete A Game
extension Game {
    @discardableResult func deleteGame(inContext context: NSManagedObjectContext) -> Bool {
        // Delete any players and scenarios tied to the game.
        Player.deleteMultiplePlayers(players: self.players, inContext: context)
        Scenario.deleteMultipleScenarios(scenarios: self.scenarios ?? [], inContext: context)
        LootCard.deleteLootCards(fromGame: self, inContext: context)
        
        context.delete(self)
        return DTAStack.saveContext()
    }
}
