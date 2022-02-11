//
//  AvailableCharacters.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/10/22.
//

import Foundation

public enum AvailableCharacters: String {
    case Barbarian
    case MoonElf
    case Monk
    case Paladin
    case ShadowThief
    case Pyromancer
    case Ninja
    case Treant
    
    public var rawValue: String {
        switch self {
        case .Barbarian:
            return "Barbarian"
        case .MoonElf:
            return "Moon Elf"
        case .Monk:
            return "Monk"
        case .Paladin:
            return "Paladin"
        case .ShadowThief:
            return "Shadow Thief"
        case .Pyromancer:
            return "Pyromancer"
        case .Ninja:
            return "Ninja"
        case .Treant:
            return "Treant"
        }
    }
}
