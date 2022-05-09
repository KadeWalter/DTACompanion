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
    
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        self.context = CoreDataTestStack().context
    }
    
    override func tearDown() {
        self.context = nil
        super.tearDown()
    }
    
    func testDeleteExistingGame() {
        // Create 2 games and save them.
        Game.saveNewGame(teamName: "team 1", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: Date(), inContext: context!)
        Game.saveNewGame(teamName: "team 2", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: Date(), inContext: context!)
        var games = Game.findAll(inContext: context!)
        // Verify the 2 were saved.
        XCTAssertEqual(games.count, 2)
        
        // Add a new one to core data.
        Game.saveNewGame(teamName: "team 3", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: Date(), inContext: context!)
        games = Game.findAll(inContext: context!)
        // Verify it was saved.
        XCTAssertEqual(games.count, 3)
    }
    
    func testFindAllGamesSorted() {
        // Dates newest to oldest.
        let date1 = Date(timeIntervalSince1970: 1658984400) // Jul 28 2022
        let date2 = Date(timeIntervalSince1970: 1627448400) // JUl 28 2021
        let date3 = Date(timeIntervalSince1970: 838530000) // Jul 28 1996
        
        // Create 2 games and save them.
        // Save date3 first, then date1.
        Game.saveNewGame(teamName: "team 1", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date3, inContext: context!)
        Game.saveNewGame(teamName: "team 2", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date2, inContext: context!)
        var games = Game.findAll(inContext: context!)
        // Verify the 2 were saved.
        XCTAssertEqual(games.count, 2)
        // Verify team 2 was returned first. Then team 1.
        XCTAssertEqual(games[0].teamName, "team 2")
        XCTAssertEqual(games[1].teamName, "team 1")
        
        // Add a new one to core data.
        Game.saveNewGame(teamName: "team 3", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date1, inContext: context!)
        games = Game.findAll(inContext: context!)
        // Verify it was saved.
        XCTAssertEqual(games.count, 3)
        // Verify team 3 was returned first. Then team 2. Then team 1.
        XCTAssertEqual(games[0].teamName, "team 3")
        XCTAssertEqual(games[1].teamName, "team 2")
        XCTAssertEqual(games[2].teamName, "team 1")
    }
    
    func testDeleteGame() {
        // Dates newest to oldest.
        let date1 = Date(timeIntervalSince1970: 1627448400) // JUl 28 2021
        let date2 = Date(timeIntervalSince1970: 838530000) // Jul 28 1996
        
        // Create 2 games and save them.
        // Save date3 first, then date1.
        Game.saveNewGame(teamName: "team 1", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date1, inContext: context!)
        Game.saveNewGame(teamName: "team 2", numberOfPlayers: 1, legacyMode: false, difficulty: Difficulty.normal, players: [], dateCreated: date2, inContext: context!)
        var games = Game.findAll(inContext: context!)
        // Verify the 2 were saved.
        XCTAssertEqual(games.count, 2)
        // Verify team 2 was returned first. Then team 1.
        XCTAssertEqual(games[0].teamName, "team 1")
        XCTAssertEqual(games[1].teamName, "team 2")
        
        // Add a new one to core data.
        games[1].deleteGame(inContext: context!)
        games = Game.findAll(inContext: context!)
        // Verify it was deleted.
        XCTAssertEqual(games.count, 1)
        // Verify only team 1 was returned first.
        XCTAssertEqual(games.first!.teamName, "team 1")
    }
    
    func testPlayersAsArray() {
        // Create players to be used.
        let player1 = Player.savePlayer(withName: "A", character: "AC", index: 0, inContext: context!)
        let player2 = Player.savePlayer(withName: "B", character: "BC", index: 1, inContext: context!)
        let player3 = Player.savePlayer(withName: "C", character: "CC", index: 2, inContext: context!)
        let player4 = Player.savePlayer(withName: "D", character: "DC", index: 3, inContext: context!)
        
        // Insert the characters randomly.
        var setOfPlayers = Set<Player>()
        setOfPlayers.insert(player2)
        setOfPlayers.insert(player4)
        setOfPlayers.insert(player1)
        setOfPlayers.insert(player3)
        
        // Create the game with the characters
        Game.saveNewGame(teamName: "test team", numberOfPlayers: 4, legacyMode: false, difficulty: Difficulty.normal, players: setOfPlayers, dateCreated: Date(), inContext: context!)
        
        let game = Game.findAll(inContext: context!).first!
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
    
    func testPlayersForIndex() {
        // Create players to be used.
        // Player 1 is actually index 2
        let player1 = Player.savePlayer(withName: "A", character: "AC", index: 2, inContext: context!)
        // Player 1 is actually index 3
        let player2 = Player.savePlayer(withName: "B", character: "BC", index: 3, inContext: context!)
        // Player 1 is actually index 0
        let player3 = Player.savePlayer(withName: "C", character: "CC", index: 0, inContext: context!)
        // Player 1 is actually index 1
        let player4 = Player.savePlayer(withName: "D", character: "DC", index: 1, inContext: context!)
        
        // Insert the characters randomly.
        var setOfPlayers = Set<Player>()
        setOfPlayers.insert(player2)
        setOfPlayers.insert(player4)
        setOfPlayers.insert(player1)
        setOfPlayers.insert(player3)
        
        // Create the game with the characters
        Game.saveNewGame(teamName: "test team", numberOfPlayers: 4, legacyMode: false, difficulty: Difficulty.normal, players: setOfPlayers, dateCreated: Date(), inContext: context!)
        
        let game = Game.findAll(inContext: context!).first!
        // Get the players that were saved to the game.
        let playerAtIndex0 = game.player(forIndex: 0)
        let playerAtIndex1 = game.player(forIndex: 1)
        let playerAtIndex2 = game.player(forIndex: 2)
        let playerAtIndex3 = game.player(forIndex: 3)
        // Verify they were in order.
        XCTAssertEqual(playerAtIndex0, player3)
        XCTAssertEqual(playerAtIndex1, player4)
        XCTAssertEqual(playerAtIndex2, player1)
        XCTAssertEqual(playerAtIndex3, player2)
    }
}
