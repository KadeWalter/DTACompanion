//
//  PlayerTests.swift
//  DTACompanionTests
//
//  Created by Kade Walter on 2/18/22.
//

import XCTest
import CoreData
@testable import DTACompanion

class PlayerTests: XCTestCase {
    
    func testSavePlayer() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        let player1 = Player.savePlayer(withName: "Tester 2", character: "Character 1", index: 1, context: context)
        let player2 = Player.savePlayer(withName: "Tester 1", character: "Character 2", index: 0, context: context)
        
        let players = Player.findAll(withContext: context)
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0], player2)
        XCTAssertEqual(players[1], player1)
    }
    
    func testDeletePlayer() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        let player1 = Player.savePlayer(withName: "Tester 2", character: "Character 1", index: 1, context: context)
        let player2 = Player.savePlayer(withName: "Tester 1", character: "Character 2", index: 0, context: context)
        
        var players = Player.findAll(withContext: context)
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0], player2)
        XCTAssertEqual(players[1], player1)
        
        players[0].deletePlayer(context: context)
        players = Player.findAll(withContext: context)
        XCTAssertEqual(players.count, 1)
        XCTAssertEqual(players[0], player1)
    }
    
    func testDeleteMultiplePlayers() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        let player1 = Player.savePlayer(withName: "Tester 2", character: "Character 1", index: 1, context: context)
        let player2 = Player.savePlayer(withName: "Tester 1", character: "Character 2", index: 0, context: context)
        
        var players = Player.findAll(withContext: context)
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0], player2)
        XCTAssertEqual(players[1], player1)
        
        Player.deleteMultiplePlayers(players: Set(players), context: context)
        
        players = Player.findAll(withContext: context)
        XCTAssertEqual(players.count, 0)
    }
}
