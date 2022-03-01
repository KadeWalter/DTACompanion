//
//  Scenario.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/16/22.
//

import Foundation
import CoreData

@objc(Scenario)
class Scenario: GenericNSManagedObject {
    @NSManaged public var dateCreated: Date
    @NSManaged public var fullExploration: Int64
    @NSManaged public var remainingSalves: Int64
    @NSManaged public var scenarioNumber: Int64
    @NSManaged public var scenarioScore: Int64
    @NSManaged public var totalScore: Int64
    @NSManaged public var unclaimedBossLoot: Int64
    @NSManaged public var unspentGold: Int64
    @NSManaged public var win: Bool
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save A New Scenario
extension Scenario {
    @discardableResult class func saveNewScenario(scenarioNumber: Int, remainingSalves: Int, unspentGold: Int, unclaimedBossLoot: Int, exploration: Int, scenarioScore: Int, win: Bool, totalScore: Int) -> Scenario {
        saveNewScenario(scenarioNumber: scenarioNumber, remainingSalves: remainingSalves, unspentGold: unspentGold, unclaimedBossLoot: unclaimedBossLoot, exploration: exploration, scenarioScore: scenarioScore, win: win, totalScore: totalScore, context: self.GenericManagedObjectContext())
    }
    
    @discardableResult class func saveNewScenario(scenarioNumber: Int, remainingSalves: Int, unspentGold: Int, unclaimedBossLoot: Int, exploration: Int, scenarioScore: Int, win: Bool, totalScore: Int, context: NSManagedObjectContext) -> Scenario {
        let scenario = Scenario(context: context)
        scenario.scenarioNumber = Int64(scenarioNumber)
        scenario.remainingSalves = Int64(remainingSalves)
        scenario.unspentGold = Int64(unspentGold)
        scenario.unclaimedBossLoot = Int64(unclaimedBossLoot)
        scenario.fullExploration = Int64(exploration)
        scenario.scenarioScore = Int64(scenarioScore)
        scenario.totalScore = Int64(totalScore)
        scenario.win = win
        scenario.dateCreated = Date()
        
        do {
            try context.save()
        } catch {
            fatalError("Error saving game: \(error)")
        }
        
        return scenario
    }
}

// MARK: - Fetch Scenarios
extension Scenario {
    class func findAll() -> [Scenario] {
        return findAll(withContext: self.GenericManagedObjectContext())
    }
    
    class func findAll(withContext context: NSManagedObjectContext) -> [Scenario] {
        do {
            let request = NSFetchRequest<Scenario>(entityName: self.identifier())
            let sortByDate = NSSortDescriptor(key: "dateCreated", ascending: true)
            request.sortDescriptors = [sortByDate]
            let scenarios = try context.fetch(request)
            return scenarios
        } catch {
            return []
        }
    }
}

// MARK: - Delete A Scenario
extension Scenario {
    @discardableResult func deleteScenario() -> Bool {
        return deleteScenario(context: Scenario.GenericManagedObjectContext())
    }
    
    @discardableResult func deleteScenario(context: NSManagedObjectContext) -> Bool {
        var scenarioDeleted: Bool = false
        context.delete(self)
        do {
            try context.save()
            scenarioDeleted = true
        } catch {
            fatalError("Unable to delete game.")
        }
        return scenarioDeleted
    }
    
    class func deleteMultipleScenarios(scenarios: Set<Scenario>) {
        deleteMultipleScenarios(scenarios: scenarios, context: self.GenericManagedObjectContext())
    }
    
    class func deleteMultipleScenarios(scenarios: Set<Scenario>, context: NSManagedObjectContext) {
        for scenario in scenarios {
            context.delete(scenario)
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Error deleting all players.")
        }
    }
}
