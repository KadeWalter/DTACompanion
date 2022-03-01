//
//  ScenarioManagerHelperFunctions.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/27/22.
//

import Foundation
import UIKit

extension ScenarioManagerViewController {
    
    // Update total for new scenario info object.
    func updateTotalScenarioScore() {
        getTotalScenarioScore()
        
        // Update the total score cell:
        let lastSection = self.collectionView.numberOfSections - 1
        let lastRow = self.collectionView.numberOfItems(inSection: lastSection) - 2
        guard let id = self.dataSource.itemIdentifier(for: IndexPath(row: lastRow, section: lastSection)) else { return }
        DispatchQueue.main.async {
            var snap = self.dataSource.snapshot()
            snap.reloadItems([id])
            self.dataSource.apply(snap, animatingDifferences: false)
        }
    }
    
    func getTotalScenarioScore() {
        guard var scenarioInfo = scenarioInfo else { return }
        if !scenarioInfo.wonScenario {
            // If the scenario is a loss, then the score is -10.
            scenarioInfo.totalScore = -10
            self.scenarioInfo = scenarioInfo
        } else {
            // Otherwise, calculate the total.
            let salveCount = scenarioInfo.remainingSalves ?? 0
            let goldCount = scenarioInfo.unspentGold ?? 0
            let bossLootCount = scenarioInfo.unclaimedBossLoot ?? 0
            let explorationCount = scenarioInfo.exploration ?? 0
            let scenarioScore = scenarioInfo.scenarioScore
            scenarioInfo.totalScore = salveCount + goldCount + bossLootCount + explorationCount + scenarioScore
            self.scenarioInfo = scenarioInfo
        }
    }
    
    // Save the new scenario to core data.
    func saveScenario() {
        guard let scenarioInfo = scenarioInfo else { return }
        // Verify the scenario number is entered:
        guard let number = scenarioInfo.scenarioNumber else {
            let alert = UIAlertController(title: "Error", message: "Scenario number is required.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { _ in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true)
                }
            }
            alert.addAction(action)
            DispatchQueue.main.async {
                self.navigationController?.present(alert, animated: true)
            }
            return
        }
        
        // The remaining 4 optional values don't have to be accounted for
        let salves = scenarioInfo.remainingSalves ?? 0
        let gold = scenarioInfo.unspentGold ?? 0
        let bossLoot = scenarioInfo.unclaimedBossLoot ?? 0
        let expl = scenarioInfo.exploration ?? 0
        let scenScore = scenarioInfo.scenarioScore
        let win = scenarioInfo.wonScenario
        let total = scenarioInfo.totalScore
        
        let scenario = Scenario.saveNewScenario(scenarioNumber: number, remainingSalves: salves, unspentGold: gold, unclaimedBossLoot: bossLoot, exploration: expl, scenarioScore: scenScore, win: win, totalScore: total)
        self.game.addScenario(scenario: scenario)
        
        // Recalculate the total campaign score:
        calculateCampaignTotal()
        
        // Reload the snapshot:
        self.scenarioInfo = nil
        self.setDataSourceInformation(isAdding: false, scenarios: self.game.scenariosAsArray() ?? [])
        self.dataSource.configureSnapshot()
    }
    
    // Delete an existing scenario from core data.
    func deleteScenario(scenarioToDelete scenario: Scenario, rootId: Int) {
        let alert = UIAlertController(title: "Are You Sure?", message: "Are you sure you want to delete this scenario?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .default) { _ in
            DispatchQueue.main.async {
                alert.dismiss(animated: true)
            }
        }
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            
            scenario.deleteScenario()
            
            // Recalculate the total campaign score:
            self.calculateCampaignTotal()
            
            DispatchQueue.main.async {
                alert.dismiss(animated: true)
                var newSnapshot = self.dataSource.snapshot(for: .existingScenarios)
                let itemsToDelete = newSnapshot.items.filter({ $0.headerScenarioIndex == rootId })
                newSnapshot.delete(itemsToDelete)
                self.dataSource.apply(newSnapshot, to:.existingScenarios, animatingDifferences: true)
                
                // Reload the snapshot:
                self.scenarioInfo = nil
                self.setDataSourceInformation(isAdding: false, scenarios: self.game.scenariosAsArray() ?? [])
                self.dataSource.configureSnapshot()
            }
        }
        DispatchQueue.main.async {
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.navigationController?.present(alert, animated: true)
        }
    }
    
    // Calculate the total score for the campaign from the existing scenarios.
    func calculateCampaignTotal() {
        var total = 0
        if let scenarios = self.game.scenariosAsArray() {
            for scenario in scenarios {
                total += Int(scenario.totalScore)
            }
        }
        self.campaignScore = total
    }
    
    // Get the value shown in a cells row.
    func valueForRow(row: Row, section: Section, scenarioIndex: Int?) -> Any? {
        var scenario: Scenario?
        if section == .existingScenarios {
            guard let scenarioIndex = scenarioIndex, let scenarios = self.game.scenariosAsArray(), scenarioIndex < scenarios.count else { return nil }
            scenario = scenarios[scenarioIndex]
        }
        
        switch (section, row) {
        case (.addScenario, .scenarioScore):
            return self.scenarioInfo?.scenarioScore
        case (.addScenario, .totalScore):
            return self.scenarioInfo?.totalScore
        case (.addScenario, .winLoss):
            return self.scenarioInfo?.wonScenario
        case (.existingScenarios, .scenarioNumber):
            return scenario?.scenarioNumber
        case (.existingScenarios, .remainingSalves):
            return scenario?.remainingSalves
        case (.existingScenarios, .unspentGold):
            return scenario?.unspentGold
        case (.existingScenarios, .unclaimedBossLoot):
            return scenario?.unclaimedBossLoot
        case (.existingScenarios, .fullExploration):
            return scenario?.fullExploration
        case (.existingScenarios, .scenarioScore):
            return scenario?.scenarioScore
        case (.existingScenarios, .winLoss):
            return scenario?.win
        case (.existingScenarios, .totalScore):
            return scenario?.totalScore
        default:
            return nil
        }
    }
}
