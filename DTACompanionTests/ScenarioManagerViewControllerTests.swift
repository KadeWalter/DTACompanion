//
//  ScenarioManagerViewControllerTests.swift
//  DTACompanionTests
//
//  Created by Kade Walter on 3/1/22.
//

import XCTest
@testable import DTACompanion
import CoreData

class ScenarioManagerViewControllerTests: XCTestCase {
    
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        self.context = CoreDataTestStack().context
    }
    
    override func tearDown() {
        self.context = nil
        super.tearDown()
    }

    func testGetTotalScenarioScore() {
        let game = Game(context: context!)
        
        // Score with win enabled. Total = 50.
        let vc = ScenarioManagerViewController(withGame: game)
        vc.scenarioInfo = ScenarioManagerViewController.NewScenarioInformation(scenarioNumber: 1, remainingSalves: 2, unspentGold: 3, unclaimedBossLoot: nil, exploration: 5, scenarioScore: 40, wonScenario: true, totalScore: 0)
        vc.getTotalScenarioScore()
        XCTAssertEqual(vc.scenarioInfo!.totalScore, 50)
        
        // Change win to loss. Total = -10
        vc.scenarioInfo!.wonScenario = false
        vc.getTotalScenarioScore()
        XCTAssertEqual(vc.scenarioInfo!.totalScore, -10)
    }

    func testCalculateCampaignScore() {
        let game = createGame(context: context!)
        let scen1 = createScenario(withTotal: 20, context: context!)
        let scen2 = createScenario(withTotal: 30, context: context!)
        game.scenarios = [scen1, scen2]
        try! context!.save()
        
        let vc = ScenarioManagerViewController(withGame: game)
        vc.calculateCampaignTotal()
        XCTAssertEqual(vc.campaignScore, 50)
        
        scen1.deleteScenario(inContext: context!)
        try! context!.save()
        vc.calculateCampaignTotal()
        XCTAssertEqual(vc.campaignScore, 30)
    }
    
    func testValueForRow() {
        let game = createGame(context: context!)
        let scen = createScenario(withTotal: 20, context: context!)
        scen.scenarioNumber = 10
        scen.remainingSalves = 11
        scen.unspentGold = 12
        scen.unclaimedBossLoot = 13
        scen.fullExploration = 14
        scen.scenarioScore = 15
        game.scenarios = [scen]
        try! context!.save()
        
        let vc = ScenarioManagerViewController(withGame: game)
        vc.scenarioInfo = ScenarioManagerViewController.NewScenarioInformation(scenarioNumber: 1, remainingSalves: 2, unspentGold: 3, unclaimedBossLoot: 4, exploration: 5, scenarioScore: 6, wonScenario: true, totalScore: 7)
        
        XCTAssertEqual(vc.valueForRow(row: .scenarioScore, section: .addScenario, scenarioIndex: nil) as! Int, 6)
        XCTAssertEqual(vc.valueForRow(row: .totalScore, section: .addScenario, scenarioIndex: nil) as! Int, 7)
        XCTAssertEqual(vc.valueForRow(row: .winLoss, section: .addScenario, scenarioIndex: nil) as! Bool, true)
        
        XCTAssertEqual(vc.valueForRow(row: .scenarioNumber, section: .existingScenarios, scenarioIndex: 0) as! Int64, 10)
        XCTAssertEqual(vc.valueForRow(row: .remainingSalves, section: .existingScenarios, scenarioIndex: 0) as! Int64, 11)
        XCTAssertEqual(vc.valueForRow(row: .unspentGold, section: .existingScenarios, scenarioIndex: 0) as! Int64, 12)
        XCTAssertEqual(vc.valueForRow(row: .unclaimedBossLoot, section: .existingScenarios, scenarioIndex: 0) as! Int64, 13)
        XCTAssertEqual(vc.valueForRow(row: .fullExploration, section: .existingScenarios, scenarioIndex: 0) as! Int64, 14)
        XCTAssertEqual(vc.valueForRow(row: .scenarioScore, section: .existingScenarios, scenarioIndex: 0) as! Int64, 15)
        XCTAssertEqual(vc.valueForRow(row: .winLoss, section: .existingScenarios, scenarioIndex: 0) as! Bool, true)
        XCTAssertEqual(vc.valueForRow(row: .totalScore, section: .existingScenarios, scenarioIndex: 0) as! Int64, 20)
    }
}

extension ScenarioManagerViewControllerTests {
    private func createGame(context: NSManagedObjectContext) -> Game {
        let game = Game(context: context)
        game.latestUpdate = Date()
        game.difficulty = "Normal"
        game.numberOfPlayers = 1
        game.legacyMode = false
        game.teamName = "Test Team"
        game.players = []
        return game
    }
    
    private func createScenario(withTotal total: Int, context: NSManagedObjectContext) -> Scenario {
        let scenario = Scenario(context: context)
        scenario.dateCreated = Date()
        scenario.scenarioNumber = 1
        scenario.remainingSalves = 0
        scenario.unspentGold = 0
        scenario.unclaimedBossLoot = 0
        scenario.fullExploration = 0
        scenario.win = true
        scenario.scenarioScore = 0
        scenario.totalScore = Int64(total)
        return scenario
    }
}
