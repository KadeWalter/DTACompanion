//
//  CreateNewGameCellRegistrations.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/18/22.
//

import UIKit

// MARK: - Cell Registration Functions
extension CreateNewGameViewController {
    func createTextEntryListCellRegistration() -> UICollectionView.CellRegistration<TextEntryCollectionViewCell, TextEntryCellInformation> {
        return UICollectionView.CellRegistration<TextEntryCollectionViewCell, TextEntryCellInformation> { cell, indexPath, data in
            var config = TextEntryContentConfiguration()
            config.title = data.title
            config.tag = data.rowType.rawValue
            config.textChangedDelegate = self
            config.isSelectable = data.isSelectable
            if let val = data.value {
                config.textValue = val
            }
            if let parentId = data.parentId {
                config.parentId = parentId
            }
            cell.contentConfiguration = config
        }
    }
    
    func createSegmentedControlListCellRegistration() -> UICollectionView.CellRegistration<SegmentedControlCollectionViewCell, SegmentedControlCellInformation> {
        return UICollectionView.CellRegistration<SegmentedControlCollectionViewCell, SegmentedControlCellInformation> { cell, indexPath, data in
            var config = SegmentedControlContentConfiguration()
            config.title = data.title
            config.tag = data.rowType.rawValue
            config.selectedIndex = data.selectedIndex
            // Convert the int array in the SegmentedControlCellInformation object into an appropriate string.
            var segmentItems: [String] = []
            for item in data.items {
                segmentItems.append("\(item)")
            }
            // Assign the items for the segmented control.
            config.items = segmentItems
            
            config.segmentedControlUpdateDelegate = self
            cell.contentConfiguration = config
        }
    }
    
    func createCharacterPickerViewListCellRegistration() -> UICollectionView.CellRegistration<CharacterPickerViewCollectionViewCell, String> {
        UICollectionView.CellRegistration<CharacterPickerViewCollectionViewCell, String> { cell, indexPath, data in
            var config = CharacterPickerViewContentConfiguration()
            config.indexPath = indexPath
            config.delegate = self
            config.currentSelection = data
            cell.contentConfiguration = config
        }
    }
    
    func createDifficultyPickerViewListCellRegistration() -> UICollectionView.CellRegistration<DifficultyPickerViewCollectionViewCell, String> {
        UICollectionView.CellRegistration<DifficultyPickerViewCollectionViewCell, String> { cell, indexPath, data in
            var config = DifficultyPickerViewContentConfiguration()
            config.indexPath = indexPath
            config.delegate = self
            config.currentSelection = self.gameInfo.difficulty
            config.legacyMode = self.gameInfo.legacyMode
            cell.contentConfiguration = config
        }
    }
    
    func createHeaderListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    func createDisclosureItemListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    func createSwitchListCellRegistration() -> UICollectionView.CellRegistration<SwitchListCollectionViewCell, SwitchCellInformation> {
        return UICollectionView.CellRegistration<SwitchListCollectionViewCell, SwitchCellInformation> { cell, indexPath, data in
            var config = SwitchListContentConfiguration()
            config.title = data.title
            config.switchIsOn = data.switchIsOn
            config.switchListCellUpdatedDelegate = self
            cell.contentConfiguration = config
        }
    }
    
    func createSaveListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.color = .systemBlue
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
        }
    }
}
