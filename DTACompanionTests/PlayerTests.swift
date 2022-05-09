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
    
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        self.context = CoreDataTestStack().context
    }
    
    override func tearDown() {
        self.context = nil
        super.tearDown()
    }
    
    func testSavePlayer() {
        let player1 = Player.savePlayer(withName: "Tester 2", character: "Character 1", index: 1, inContext: context!)
        let player2 = Player.savePlayer(withName: "Tester 1", character: "Character 2", index: 0, inContext: context!)
        
        let players = Player.findAll(inContext: context!)
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0], player2)
        XCTAssertEqual(players[1], player1)
    }
    
    func testDeletePlayer() {
        let player1 = Player.savePlayer(withName: "Tester 2", character: "Character 1", index: 1, inContext: context!)
        let player2 = Player.savePlayer(withName: "Tester 1", character: "Character 2", index: 0, inContext: context!)
        
        var players = Player.findAll(inContext: context!)
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0], player2)
        XCTAssertEqual(players[1], player1)
        
        players[0].deletePlayer(inContext: context!)
        players = Player.findAll(inContext: context!)
        XCTAssertEqual(players.count, 1)
        XCTAssertEqual(players[0], player1)
    }
    
    func testDeleteMultiplePlayers() {
        let player1 = Player.savePlayer(withName: "Tester 2", character: "Character 1", index: 1, inContext: context!)
        let player2 = Player.savePlayer(withName: "Tester 1", character: "Character 2", index: 0, inContext: context!)
        
        var players = Player.findAll(inContext: context!)
        XCTAssertEqual(players.count, 2)
        XCTAssertEqual(players[0], player2)
        XCTAssertEqual(players[1], player1)
        
        Player.deleteMultiplePlayers(players: Set(players), inContext: context!)
        
        players = Player.findAll(inContext: context!)
        XCTAssertEqual(players.count, 0)
    }
}
