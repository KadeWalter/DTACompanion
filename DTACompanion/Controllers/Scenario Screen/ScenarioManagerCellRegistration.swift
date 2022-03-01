//
//  ScenarioManagerCellRegistration.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/27/22.
//

import UIKit

extension ScenarioManagerViewController {
    func configureScoreEntryCellRegistration() -> UICollectionView.CellRegistration<ScoreEntryCollectionViewCell, ScoreEntryCellInformation> {
        return UICollectionView.CellRegistration<ScoreEntryCollectionViewCell, ScoreEntryCellInformation> { cell, indexPath, data in
            var config = ScoreEntryContentConfiguration()
            config.title = data.title
            config.subtitle = data.subtitle
            config.tag = data.rowType.rawValue
            config.scoreUpdatedDelegate = self
            
            if let value = data.value as? Int64 {
                config.value = Int(value)
            } else if let value = data.value as? Int {
                config.value = value
            }
            
            cell.contentConfiguration = config
            
            // Should the cell have user interaction enabled?
            var interactionEnabled: Bool = false
            if data.sectionType == .addScenario && !(data.rowType == .totalScore || data.rowType == .scenarioScore) {
                interactionEnabled = true
            } else if data.sectionType == .existingScenarios && data.rowType == .delete {
                interactionEnabled = true
            }
            cell.isUserInteractionEnabled = interactionEnabled
        }
    }
    
    func configureSwitchListCellRegistration() -> UICollectionView.CellRegistration<SwitchListCollectionViewCell, ScoreEntryCellInformation> {
        return UICollectionView.CellRegistration<SwitchListCollectionViewCell, ScoreEntryCellInformation> { cell, indexPath, data in
            var config = SwitchListContentConfiguration()
            config.title = data.title
            config.switchListCellUpdatedDelegate = self
            
            var isOn = true
            if let enabled = data.value as? Bool {
                isOn = enabled
            }
            config.switchIsOn = isOn
            
            cell.contentConfiguration = config
            // If the switch is in a previously stored scenario,
            // Give the switch the faded view indicating they can't toggle the switch.
            for view in cell.contentView.subviews {
                if let sw = view as? UISwitch {
                    sw.isEnabled = data.sectionType == .addScenario
                }
            }
        }
    }
    
    func configureSaveListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.color = .systemBlue
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
        }
    }
    
    func configureDeleteListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.color = .systemRed
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
        }
    }
    
    func configureHeaderListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
}
