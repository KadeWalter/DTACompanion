//
//  ScenarioManagerDelegateFunctions.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/27/22.
//

import UIKit

// MARK: - SwitchListCellUpdatedDelegate Function
extension ScenarioManagerViewController: SwitchListCellUpdatedDelegate {
    func switchToggled(switchIsOn: Bool) {
        self.collectionView.endEditing(true)
        self.scenarioInfo?.wonScenario.toggle()
        updateTotalScenarioScore()
    }
}

// MARK: - Score Entry Updated Delegate Function
extension ScenarioManagerViewController: ScoreEntryUpdatedDelegate {
    func scoreUpdated(withScore score: Int, cellTag: Int) {
        guard let row = Row(rawValue: cellTag), var scenarioData = self.scenarioInfo else { return }
        switch row {
        case .scenarioNumber:
            scenarioData.scenarioNumber = score
        case .remainingSalves:
            scenarioData.remainingSalves = score
        case .unspentGold:
            scenarioData.unspentGold = score
        case .unclaimedBossLoot:
            scenarioData.unclaimedBossLoot = score
        case .fullExploration:
            scenarioData.exploration = score
        default:
            return
        }
        self.scenarioInfo = scenarioData
        updateTotalScenarioScore()
    }
}

// MARK: - CollectionView Delegate Functions
extension ScenarioManagerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.endEditing(true)
        self.collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        switch item.rowType {
        case .save:
            self.saveScenario()
        case .delete:
            guard let scenarios = self.game.scenariosAsArray(), let headerIndex = item.headerScenarioIndex else { return }
            self.deleteScenario(scenarioToDelete: scenarios[headerIndex], rootId: headerIndex)
        default:
            // Get the text field in the cell and make it the first responder.
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ScoreEntryCollectionViewCell, let contentView = cell.contentView as? ScoreEntryContentView {
                contentView.textField.becomeFirstResponder()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return true }
        if item.sectionType == .addScenario {
            switch item.rowType {
            case .scenarioNumber, .remainingSalves, .unspentGold, .unclaimedBossLoot, .fullExploration, .save:
                return true
            default:
                return false
            }
            
        } else if item.sectionType == .existingScenarios && item.rowType == .delete {
            return true
        }
        return false
    }
}

//MARK: - Keyboard Show/Hide Functions
extension ScenarioManagerViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        self.collectionView.contentInset.bottom = keyboardSize
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.collectionView.contentInset.bottom = 0
    }
}
