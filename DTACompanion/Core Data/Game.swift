//
//  Game.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation
import CoreData

@objc(Game)
class Game: GenericNSManagedObject {
    @NSManaged public var teamName: String
    @NSManaged public var numberOfPlayers: Int64
    @NSManaged public var legacyMode: Bool
    @NSManaged public var latestUpdate: Date
    @NSManaged public var difficulty: String
    @NSManaged public var players: Set<Player>
    @NSManaged public var sessions: Set<Scenario>?
    
    override class func identifier() -> String {
        return String(describing: self)
    }
    
    func playersAsArray() -> [Player] {
        return Array(self.players).sorted(by: { $0.index < $1.index })
    }
    
    func player(forIndex index: Int) -> Player? {
        return self.players.filter({ $0.index == index}).first
    }
}

// MARK: - Save Games
extension Game {
    class func saveNewGame(teamName: String, numberOfPlayers: Int, legacyMode: Bool, difficulty: Difficulty, players: Set<Player>, dateCreated: Date) {
        saveNewGame(teamName: teamName, numberOfPlayers: numberOfPlayers, legacyMode: legacyMode, difficulty: difficulty, players: players, dateCreated: dateCreated, context: self.GenericManagedObjectContext())
    }
    
    class func saveNewGame(teamName: String, numberOfPlayers: Int, legacyMode: Bool, difficulty: Difficulty, players: Set<Player>, dateCreated: Date, context: NSManagedObjectContext) {
        let game = Game(context: context)
        game.teamName = teamName
        game.numberOfPlayers = Int64(numberOfPlayers)
        game.legacyMode = legacyMode
        game.latestUpdate = dateCreated
        game.difficulty = difficulty.rawValue
        game.players = players
        
        do {
            try context.save()
        } catch {
            fatalError("Error saving game: \(error)")
        }
    }
}

// MARK: - Fetch Games
extension Game {
    class func findAll() -> [Game] {
        return findAll(withContext: self.GenericManagedObjectContext())
    }
    
    class func findAll(withContext context: NSManagedObjectContext) -> [Game] {
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
    @discardableResult func deleteGame() -> Bool {
        return deleteGame(context: Game.GenericManagedObjectContext())
    }
    
    @discardableResult func deleteGame(context: NSManagedObjectContext) -> Bool {
        var gameDeleted: Bool = false
        Player.deleteMultiplePlayers(players: self.players)
        context.delete(self)
        do {
            try context.save()
            gameDeleted = true
        } catch {
            fatalError("Unable to delete game.")
        }
        return gameDeleted
    }
}
