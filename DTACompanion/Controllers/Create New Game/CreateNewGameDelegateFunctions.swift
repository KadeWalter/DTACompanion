//
//  CreateNewGameDelegateFunctions.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/18/22.
//

import UIKit

// MARK: - TextEntryCellUpdatedDelegate Function
extension CreateNewGameViewController: TextEntryCellUpdatedDelegate {
    func textUpdated(withText text: String, cellTag: Int, parentId: Int?) {
        switch Row(rawValue: cellTag) {
        case .teamName:
            self.gameInfo.teamName = text
        case .name:
            guard let parentId = parentId else { return }
            self.updatePlayerData(forPlayerIndex: parentId, name: text.trimmingCharacters(in: .whitespacesAndNewlines))
        default:
            fatalError("Unknown text field cell text updated.")
        }
    }
}

// MARK: - SegmentedControlCellUpdatedDelegate Function
extension CreateNewGameViewController: SegmentedControlCellUpdatedDelegate {
    func segmentedControlIndexChanged(itemAtIndex item: String, cellTag: Int) {
        switch Row(rawValue: cellTag) {
        case .numberOfPlayers:
            guard let playerCount: Int = Int(item) else { return }
            self.gameInfo.numberOfPlayers = playerCount
            self.dataSource.updatePlayerRows(playerCount: playerCount)
            self.updateGameInfoPlayers()
        default:
            fatalError("Unknown segmented control cell updated.")
        }
    }
}

// MARK: - SwitchListCellUpdatedDelegate Function
extension CreateNewGameViewController: SwitchListCellUpdatedDelegate {
    func switchToggled(switchIsOn: Bool) {
        self.gameInfo.legacyMode = switchIsOn
        self.dataSource.updateUIForLegacyMode()
    }
}

// MARK: - CharacterSelectedDelegate Functions
extension CreateNewGameViewController: CharacterSelectedDelegate {
    func updateSelectedCharacter(withCharacter character: String, indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let charItem = self.dataSource.itemIdentifier(for: IndexPath(row: indexPath.row - 1, section: indexPath.section)), let parentId = charItem.parentId else { return }
            self.updatePlayerData(forPlayerIndex: parentId, character: character)
            var snap = self.dataSource.snapshot()
            snap.reloadItems([charItem])
            self.dataSource.apply(snap, animatingDifferences: false)
        }
    }
}

// MARK: - DifficultySelectedDelegate Functions
extension CreateNewGameViewController: DifficultySelectedDelegate {
    func updateSelectedDifficulty(withDifficulty difficulty: Difficulty, indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let diffItem = self.dataSource.itemIdentifier(for: IndexPath(row: indexPath.row - 1, section: indexPath.section)) else { return }
            self.gameInfo.difficulty = difficulty
            var snap = self.dataSource.snapshot()
            snap.reloadItems([diffItem])
            self.dataSource.apply(snap, animatingDifferences: false)
        }
    }
}

//MARK: - Keyboard Show/Hide Functions
extension CreateNewGameViewController {
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
