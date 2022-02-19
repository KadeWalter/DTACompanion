//
//  HomeScreenViewControllerTests.swift
//  DTACompanionTests
//
//  Created by Kade Walter on 2/17/22.
//

import XCTest
import CoreData
@testable import DTACompanion

class GameTests: XCTestCase {
    
    func testDeleteExistingGame() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        // Create 2 games and save them.
        Game.saveNewGame(teamName: "team 1", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: Date(), context: context)
        Game.saveNewGame(teamName: "team 2", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: Date(), context: context)
        var games = Game.findAll(withContext: context)
        // Verify the 2 were saved.
        XCTAssertEqual(games.count, 2)
        
        // Add a new one to core data.
        Game.saveNewGame(teamName: "team 3", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: Date(), context: context)
        games = Game.findAll(withContext: context)
        // Verify it was saved.
        XCTAssertEqual(games.count, 3)
    }
    
    func testFindAllGamesSorted() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        // Dates newest to oldest.
        let date1 = Date(timeIntervalSince1970: 1658984400) // Jul 28 2022
        let date2 = Date(timeIntervalSince1970: 1627448400) // JUl 28 2021
        let date3 = Date(timeIntervalSince1970: 838530000) // Jul 28 1996
        
        // Create 2 games and save them.
        // Save date3 first, then date1.
        Game.saveNewGame(teamName: "team 1", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date3, context: context)
        Game.saveNewGame(teamName: "team 2", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date2, context: context)
        var games = Game.findAll(withContext: context)
        // Verify the 2 were saved.
        XCTAssertEqual(games.count, 2)
        // Verify team 2 was returned first. Then team 1.
        XCTAssertEqual(games[0].teamName, "team 2")
        XCTAssertEqual(games[1].teamName, "team 1")
        
        // Add a new one to core data.
        Game.saveNewGame(teamName: "team 3", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date1, context: context)
        games = Game.findAll(withContext: context)
        // Verify it was saved.
        XCTAssertEqual(games.count, 3)
        // Verify team 3 was returned first. Then team 2. Then team 1.
        XCTAssertEqual(games[0].teamName, "team 3")
        XCTAssertEqual(games[1].teamName, "team 2")
        XCTAssertEqual(games[2].teamName, "team 1")
    }
    
    func testDeleteGame() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        // Dates newest to oldest.
        let date1 = Date(timeIntervalSince1970: 1627448400) // JUl 28 2021
        let date2 = Date(timeIntervalSince1970: 838530000) // Jul 28 1996
        
        // Create 2 games and save them.
        // Save date3 first, then date1.
        Game.saveNewGame(teamName: "team 1", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date1, context: context)
        Game.saveNewGame(teamName: "team 2", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date2, context: context)
        var games = Game.findAll(withContext: context)
        // Verify the 2 were saved.
        XCTAssertEqual(games.count, 2)
        // Verify team 2 was returned first. Then team 1.
        XCTAssertEqual(games[0].teamName, "team 1")
        XCTAssertEqual(games[1].teamName, "team 2")
        
        // Add a new one to core data.
        games[1].deleteGame(context: context)
        games = Game.findAll(withContext: context)
        // Verify it was deleted.
        XCTAssertEqual(games.count, 1)
        // Verify only team 1 was returned first.
        XCTAssertEqual(games.first!.teamName, "team 1")
    }
    
    func testPlayersAsArray() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        // Create players to be used.
        let player1 = Player.savePlayer(withName: "A", character: "AC", index: 0, context: context)
        let player2 = Player.savePlayer(withName: "B", character: "BC", index: 1, context: context)
        let player3 = Player.savePlayer(withName: "C", character: "CC", index: 2, context: context)
        let player4 = Player.savePlayer(withName: "D", character: "DC", index: 3, context: context)
        
        // Insert the characters randomly.
        var setOfPlayers = Set<Player>()
        setOfPlayers.insert(player2)
        setOfPlayers.insert(player4)
        setOfPlayers.insert(player1)
        setOfPlayers.insert(player3)
        
        // Create the game with the characters
        Game.saveNewGame(teamName: "test team", numberOfPlayers: 4, legacyMode: false, difficulty: Difficulty.normal, players: setOfPlayers, dateCreated: Date(), context: context)
        
        let game = Game.findAll(withContext: context).first!
        // Get the players that were saved to the game.
        let playersInOrderedArray = game.playersAsArray()
        // Verify all 4 were returned.
        XCTAssertEqual(playersInOrderedArray.count, 4)
        // Verify they were in order.
        XCTAssertEqual(playersInOrderedArray[0], player1)
        XCTAssertEqual(playersInOrderedArray[1], player2)
        XCTAssertEqual(playersInOrderedArray[2], player3)
        XCTAssertEqual(playersInOrderedArray[3], player4)
    }
}
