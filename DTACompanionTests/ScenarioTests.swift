//
//  ScenarioTests.swift
//  DTACompanionTests
//
//  Created by Kade Walter on 3/1/22.
//

import XCTest
import CoreData
@testable import DTACompanion

class ScenarioTests: XCTestCase {
    
    func testSaveScenario() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        let scen1 = Scenario.saveNewScenario(scenarioNumber: 0, remainingSalves: 1, unspentGold: 1, unclaimedBossLoot: 1, exploration: 1, scenarioScore: 1, win: true, totalScore: 6, context: context)
        let scen2 = Scenario.saveNewScenario(scenarioNumber: 1, remainingSalves: 2, unspentGold: 2, unclaimedBossLoot: 2, exploration: 2, scenarioScore: 2, win: true, totalScore: 2, context: context)
        
        let scenarios = Scenario.findAll(withContext: context)
        XCTAssertEqual(scenarios.count, 2)
        XCTAssertEqual(scenarios[0], scen1)
        XCTAssertEqual(scenarios[1], scen2)
    }
    
    func testDeletePlayer() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        let scen1 = Scenario.saveNewScenario(scenarioNumber: 0, remainingSalves: 1, unspentGold: 1, unclaimedBossLoot: 1, exploration: 1, scenarioScore: 1, win: true, totalScore: 6, context: context)
        let scen2 = Scenario.saveNewScenario(scenarioNumber: 1, remainingSalves: 2, unspentGold: 2, unclaimedBossLoot: 2, exploration: 2, scenarioScore: 2, win: true, totalScore: 2, context: context)
        
        var scenarios = Scenario.findAll(withContext: context)
        XCTAssertEqual(scenarios.count, 2)
        XCTAssertEqual(scenarios[0], scen1)
        XCTAssertEqual(scenarios[1], scen2)
        
        scenarios[0].deleteScenario(context: context)
        scenarios = Scenario.findAll(withContext: context)
        XCTAssertEqual(scenarios.count, 1)
        XCTAssertEqual(scenarios[0], scen2)
    }
    
    func testDeleteMultiplePlayers() {
        let context = CoreDataTestStack().persistentContainer.viewContext
        
        let scen1 = Scenario.saveNewScenario(scenarioNumber: 0, remainingSalves: 1, unspentGold: 1, unclaimedBossLoot: 1, exploration: 1, scenarioScore: 1, win: true, totalScore: 6, context: context)
        let scen2 = Scenario.saveNewScenario(scenarioNumber: 1, remainingSalves: 2, unspentGold: 2, unclaimedBossLoot: 2, exploration: 2, scenarioScore: 2, win: true, totalScore: 2, context: context)
        
        var scenarios = Scenario.findAll(withContext: context)
        XCTAssertEqual(scenarios.count, 2)
        XCTAssertEqual(scenarios[0], scen1)
        XCTAssertEqual(scenarios[1], scen2)
        
        scenarios[0].deleteScenario(context: context)
        scenarios = Scenario.findAll(withContext: context)
        XCTAssertEqual(scenarios.count, 1)
        XCTAssertEqual(scenarios[0], scen2)
        
        Scenario.deleteMultipleScenarios(scenarios: Set(scenarios), context: context)
        
        scenarios = Scenario.findAll(withContext: context)
        XCTAssertEqual(scenarios.count, 0)
    }
}

