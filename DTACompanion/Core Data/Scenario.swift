//
//  Scenario.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/16/22.
//

import Foundation
import CoreData

@objc(Scenario)
class Scenario: NSManagedObject {
    @NSManaged public var dateCreated: Date
    @NSManaged public var fullExploration: Int64
    @NSManaged public var remainingSalves: Int64
    @NSManaged public var scenarioNumber: Int64
    @NSManaged public var scenarioScore: Int64
    @NSManaged public var totalScore: Int64
    @NSManaged public var unclaimedBossLoot: Int64
    @NSManaged public var unspentGold: Int64
    @NSManaged public var win: Bool
    
    class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Save A New Scenario
extension Scenario {
    @discardableResult class func saveNewScenario(scenarioNumber: Int, remainingSalves: Int, unspentGold: Int, unclaimedBossLoot: Int, exploration: Int, scenarioScore: Int, win: Bool, totalScore: Int, inContext context: NSManagedObjectContext) -> Scenario {
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
        DTAStack.saveContext()
        
        return scenario
    }
}

// MARK: - Fetch Scenarios
extension Scenario {
    class func findAll(inContext context: NSManagedObjectContext) -> [Scenario] {
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
    @discardableResult func deleteScenario(inContext context: NSManagedObjectContext) -> Bool {
        context.delete(self)
        return DTAStack.saveContext()
    }
    
    class func deleteMultipleScenarios(scenarios: Set<Scenario>, inContext context: NSManagedObjectContext) {
        for scenario in scenarios {
            context.delete(scenario)
        }
        DTAStack.saveContext()
    }
}
