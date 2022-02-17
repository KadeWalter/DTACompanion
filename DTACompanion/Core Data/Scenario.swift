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
    @NSManaged public var fullExploration: Bool
    @NSManaged public var remainingSalves: Int64
    @NSManaged public var scenarioNumbers: Int64
    @NSManaged public var secnarioScore: Int64
    @NSManaged public var totalScore: Int64
    @NSManaged public var unclaimedBossLoot: Int64
    @NSManaged public var unspentGold: Int64
    @NSManaged public var dateCreated: Date
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}
