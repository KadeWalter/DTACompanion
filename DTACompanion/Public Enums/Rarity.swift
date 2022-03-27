//
//  Rarity.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation

public enum Rarity: String {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case unknown = "Unknown"
    
    func getRarityFromShorthand(shorthand: String) -> Rarity {
        if shorthand == "C" {
            return Rarity.common
        } else if shorthand == "R" {
            return Rarity.rare
        } else if shorthand == "E" {
            return Rarity.epic
        } else if shorthand == "L" {
            return Rarity.legendary
        }
        return Rarity.unknown
    }
}
