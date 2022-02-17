//
//  LootCard.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/16/22.
//

import Foundation
import CoreData

@objc(LootCard)
class LootCard: GenericNSManagedObject {
    @NSManaged public var message: String
    @NSManaged public var title: String
    @NSManaged public var rarity: String
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}
