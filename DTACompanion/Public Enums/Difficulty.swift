//
//  Difficulty.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation

public enum Difficulty: String {
    case normal = "Normal"
    case veteran = "Veteran"
    case hardcore = "Hardcore"
    case insane = "Insane"
    
    func score() -> Int {
        // TODO: - Update these to the correct values:
        switch self {
        case .normal:
            return 20
        case .veteran:
            return 30
        case .hardcore:
            return 40
        case .insane:
            return 50
        }
    }
}
