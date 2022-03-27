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
    case insane = "Insane"
    case hardcore = "Hardcore"
    
    func score() -> Int {
        // TODO: - Update these to the correct values:
        switch self {
        case .normal:
            return 20
        case .veteran:
            return 30
        case .insane:
            return 40
        case .hardcore:
            return 50
        }
    }
}
