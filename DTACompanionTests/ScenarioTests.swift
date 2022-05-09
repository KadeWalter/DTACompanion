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
    
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        self.context = CoreDataTestStack().context
    }
    
    override func tearDown() {
        self.context = nil
        super.tearDown()
    }
    
    func testSaveScenario() {
        let scen1 = Scenario.saveNewScenario(scenarioNumber: 0, remainingSalves: 1, unspentGold: 1, unclaimedBossLoot: 1, exploration: 1, scenarioScore: 1, win: true, totalScore: 6, inContext: context!)
        let scen2 = Scenario.saveNewScenario(scenarioNumber: 1, remainingSalves: 2, unspentGold: 2, unclaimedBossLoot: 2, exploration: 2, scenarioScore: 2, win: true, totalScore: 2, inContext: context!)
        
        let scenarios = Scenario.findAll(inContext: context!)
        XCTAssertEqual(scenarios.count, 2)
        XCTAssertEqual(scenarios[0], scen1)
        XCTAssertEqual(scenarios[1], scen2)
    }
    
    func testDeletePlayer() {
        let scen1 = Scenario.saveNewScenario(scenarioNumber: 0, remainingSalves: 1, unspentGold: 1, unclaimedBossLoot: 1, exploration: 1, scenarioScore: 1, win: true, totalScore: 6, inContext: context!)
        let scen2 = Scenario.saveNewScenario(scenarioNumber: 1, remainingSalves: 2, unspentGold: 2, unclaimedBossLoot: 2, exploration: 2, scenarioScore: 2, win: true, totalScore: 2, inContext: context!)
        
        var scenarios = Scenario.findAll(inContext: context!)
        XCTAssertEqual(scenarios.count, 2)
        XCTAssertEqual(scenarios[0], scen1)
        XCTAssertEqual(scenarios[1], scen2)
        
        scenarios[0].deleteScenario(inContext: context!)
        scenarios = Scenario.findAll(inContext: context!)
        XCTAssertEqual(scenarios.count, 1)
        XCTAssertEqual(scenarios[0], scen2)
    }
    
    func testDeleteMultiplePlayers() {
        let scen1 = Scenario.saveNewScenario(scenarioNumber: 0, remainingSalves: 1, unspentGold: 1, unclaimedBossLoot: 1, exploration: 1, scenarioScore: 1, win: true, totalScore: 6, inContext: context!)
        let scen2 = Scenario.saveNewScenario(scenarioNumber: 1, remainingSalves: 2, unspentGold: 2, unclaimedBossLoot: 2, exploration: 2, scenarioScore: 2, win: true, totalScore: 2, inContext: context!)
        
        var scenarios = Scenario.findAll(inContext: context!)
        XCTAssertEqual(scenarios.count, 2)
        XCTAssertEqual(scenarios[0], scen1)
        XCTAssertEqual(scenarios[1], scen2)
        
        scenarios[0].deleteScenario(inContext: context!)
        scenarios = Scenario.findAll(inContext: context!)
        XCTAssertEqual(scenarios.count, 1)
        XCTAssertEqual(scenarios[0], scen2)
        
        Scenario.deleteMultipleScenarios(scenarios: Set(scenarios), inContext: context!)
        
        scenarios = Scenario.findAll(inContext: context!)
        XCTAssertEqual(scenarios.count, 0)
    }
}

