//
//  AvailableCharacters.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/10/22.
//

import Foundation

public enum SeasonOneCharacters: Int, CaseIterable {
    case Barbarian
    case MoonElf
    case Monk
    case Paladin
    case ShadowThief
    case Pyromancer
    case Ninja
    case Treant
    
    public var description: String {
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

public enum SeasonTwoCharacters: Int, CaseIterable {
    case Gunslinger
    case Samurai
    case Tactician
    case Huntress
    case CursedPirate
    case Artificer
    case Seraph
    case VampireLord
    
    public var description: String {
        switch self {
        case .Gunslinger:
            return "Gunslinger"
        case .Samurai:
            return "Samurai"
        case .Tactician:
            return "Tactician"
        case .Huntress:
            return "Huntress"
        case .CursedPirate:
            return "Cursed Pirate"
        case .Artificer:
            return "Artificer"
        case .Seraph:
            return "Seraph"
        case .VampireLord:
            return "Vampire Lord"
        }
    }
}
