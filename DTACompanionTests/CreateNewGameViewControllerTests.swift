//
//  CreateNewGameViewControllerTests.swift
//  DTACompanionTests
//
//  Created by Kade Walter on 2/18/22.
//

import XCTest
@testable import DTACompanion

class CreateNewGameViewControllerTests: XCTestCase {

    func testUpdatePlayerData() {
        let vc = CreateNewGameViewController()
        vc.gameInfo.numberOfPlayers = 2
        // Set the initial data.
        vc.gameInfo.playerData[0] = CreateNewGameViewController.PlayerInformation(playerId: 0, name: "", character: "", lootCards: "")
        vc.gameInfo.playerData[1] = CreateNewGameViewController.PlayerInformation(playerId: 0, name: "", character: "", lootCards: "")
        
        // Update the data for each player.
        vc.updatePlayerData(forPlayerIndex: 0, name: "Tester 1", character: "Test Char 1", lootCards: "")
        vc.updatePlayerData(forPlayerIndex: 1, name: "Tester 2", character: "Test Char 2", lootCards: "")
        
        // Check data.
        XCTAssertNotNil(vc.gameInfo.playerData[0])
        XCTAssertNotNil(vc.gameInfo.playerData[1])
        XCTAssertEqual(vc.gameInfo.playerData[0]!.name, "Tester 1")
        XCTAssertEqual(vc.gameInfo.playerData[0]!.character, "Test Char 1")
        XCTAssertEqual(vc.gameInfo.playerData[1]!.name, "Tester 2")
        XCTAssertEqual(vc.gameInfo.playerData[1]!.character, "Test Char 2")
    }
    
    func testUpdateGameInfoPlayers() {
        let vc = CreateNewGameViewController()
        // Update game to have 2 players.
        vc.gameInfo.numberOfPlayers = 2
        vc.updateGameInfoPlayers()
        // Verify data.
        XCTAssertNotNil(vc.gameInfo.playerData[0])
        XCTAssertNotNil(vc.gameInfo.playerData[1])
        XCTAssertNil(vc.gameInfo.playerData[2])
        XCTAssertNil(vc.gameInfo.playerData[3])
        
        // Update game to have 3 players.
        vc.gameInfo.numberOfPlayers = 3
        vc.updateGameInfoPlayers()
        // Verify data.
        XCTAssertNotNil(vc.gameInfo.playerData[0])
        XCTAssertNotNil(vc.gameInfo.playerData[1])
        XCTAssertNotNil(vc.gameInfo.playerData[2])
        XCTAssertNil(vc.gameInfo.playerData[3])
        
        // Update game to have 4 players.
        vc.gameInfo.numberOfPlayers = 4
        vc.updateGameInfoPlayers()
        // Verify data.
        XCTAssertNotNil(vc.gameInfo.playerData[0])
        XCTAssertNotNil(vc.gameInfo.playerData[1])
        XCTAssertNotNil(vc.gameInfo.playerData[2])
        XCTAssertNotNil(vc.gameInfo.playerData[3])
        
        // Update game to have 1 player.
        vc.gameInfo.numberOfPlayers = 1
        vc.updateGameInfoPlayers()
        // Verify data.
        XCTAssertNotNil(vc.gameInfo.playerData[0])
        XCTAssertNil(vc.gameInfo.playerData[1])
        XCTAssertNil(vc.gameInfo.playerData[2])
        XCTAssertNil(vc.gameInfo.playerData[3])
    }

}
