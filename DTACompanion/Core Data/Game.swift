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
    @NSManaged public var dateCreated: Date
    @NSManaged public var difficulty: String
    @NSManaged public var players: Set<Player>
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save Games
extension Game {
    class func saveNewGame(teamName: String, numberOfPlayers: Int, legacyMode: Bool, difficulty: Difficulty, players: Set<Player>, dateCreated: Date) {
        let game = Game(context: self.GenericManagedObjectContext())
        game.teamName = teamName
        game.numberOfPlayers = Int64(numberOfPlayers)
        game.legacyMode = legacyMode
        game.dateCreated = dateCreated
        game.difficulty = difficulty.rawValue
        game.players = players
        
        do {
            try self.GenericManagedObjectContext().save()
        } catch {
            fatalError("Error saving game.")
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
            let sortByCreationDate = NSSortDescriptor(key: "dateCreated", ascending: false)
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
    class func deleteGame(game: Game) {
        return deleteGame(game: game, context: self.GenericManagedObjectContext())
    }
    
    class func deleteGame(game: Game, context: NSManagedObjectContext) {
        return 
    }
}
