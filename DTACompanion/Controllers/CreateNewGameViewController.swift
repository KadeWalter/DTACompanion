//
//  CreateNewGameViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/9/22.
//

import UIKit

class CreateNewGameViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Info>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create A New Game"
        
        self.initializeViews()
    }
}

// MARK: - UICollectionView Delegate Functions
extension CreateNewGameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - View Initialization Functions
extension CreateNewGameViewController {
    private func initializeViews() {
        configureCollectionView()
        configureDataSource()
        applyInitialSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            let section: NSCollectionLayoutSection
            
            switch sectionType {
            case .basicInfo, .scorecard, .save:
                let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            case .playerInfo:
                section = NSCollectionLayoutSection.list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func configureDataSource() {
        // Register dequeuable cells.
        let basicInfoCell = createBasicInfoListCellRegistration()
        let playerHeaderCell = createPlayerHeaderListCellRegistration()
        let playerInfoCell = createPlayerInfoListCellRegistration()
        let scorecardCell = createScorecardListCellRegistration()
        let saveCell = createSaveListCellRegistration()
        
        // Configure data source
        self.dataSource = UICollectionViewDiffableDataSource<Section, Info>(collectionView: collectionView) { collectionView, indexPath, info in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown Section Type") }
            
            switch section {
            case .basicInfo:
                return collectionView.dequeueConfiguredReusableCell(using: basicInfoCell, for: indexPath, item: info.title)
            case .playerInfo:
                if info.hasChildren {
                    return collectionView.dequeueConfiguredReusableCell(using: playerHeaderCell, for: indexPath, item: info.title)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: playerInfoCell, for: indexPath, item: info.title)
                }
            case .scorecard:
                return collectionView.dequeueConfiguredReusableCell(using: scorecardCell, for: indexPath, item: info.title)
            case .save:
                return collectionView.dequeueConfiguredReusableCell(using: saveCell, for: indexPath, item: info.title)
            }
            
        }
    }
    
    private func applyInitialSnapshot() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Info>()
        snapshot.appendSections(sections)
        
        // Apply the basic info row item to the section in the snapshot
        var basicInfoSnapshot = NSDiffableDataSourceSectionSnapshot<Info>()
        let basicInfoRows = [
            Info(title: "Team Name:", row: .teamName),
            Info(title: "Difficulty:", row: .difficulty),
            Info(title: "Number of Players:", row: .numberOfPlayers)
        ]
        basicInfoSnapshot.append(basicInfoRows)
        
        // Apply the section for number of players.
        // Because the min is 1, in the initial setup, just show 1 section.
        var player1Snapshot = NSDiffableDataSourceSectionSnapshot<Info>()
        let player1root = Info(title: "Player 1", row: .unspecified, hasChildren: true)
        player1Snapshot.append([player1root])
        let player1InformationRows = [
            Info(title: "Name:", row: .name),
            Info(title: "Character:", row: .character),
            Info(title: "Loot Cards", row: .lootCards)
        ]
        player1Snapshot.append(player1InformationRows, to: player1root)
        
        // Apply the scorecard section
        var scorecardSnapshot = NSDiffableDataSourceSectionSnapshot<Info>()
        scorecardSnapshot.append([Info(title: "Edit Scorecard", row: .scorecard)])
        
        // Finally, apply the save button section
        var saveSnapshot = NSDiffableDataSourceSectionSnapshot<Info>()
        saveSnapshot.append([Info(title: "Save", row: .save)])

        // Apply all of the snapshots to the data source.
        dataSource.apply(snapshot)
        dataSource.apply(basicInfoSnapshot, to: .basicInfo, animatingDifferences: false)
        dataSource.apply(player1Snapshot, to: .playerInfo, animatingDifferences: false)
        dataSource.apply(scorecardSnapshot, to: .scorecard, animatingDifferences: false)
        dataSource.apply(saveSnapshot, to: .save, animatingDifferences: false)
    }
}

// MARK: - CollectionView Cell Registration Functions
extension CreateNewGameViewController {
    private func createBasicInfoListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = UIListContentConfiguration.valueCell()
            content.text = title
            cell.contentConfiguration = content
        }
    }
    
    private func createPlayerHeaderListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    private func createPlayerInfoListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
        }
    }
    
    private func createScorecardListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    private func createSaveListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.color = .systemBlue
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
        }
    }
}

// MARK: - CollectionView Modeling Data
extension CreateNewGameViewController {
    enum Section: Int, CaseIterable {
        case basicInfo
        case playerInfo
        case scorecard
        case save
    }
    
    enum Row {
        case teamName
        case difficulty
        case numberOfPlayers
        case name
        case character
        case lootCards
        case scorecard
        case save
        case unspecified
    }
    
    enum Difficulty {
        case normal
        case veteran
    }
    
    struct Info: Hashable {
        let title: String
        let rowType: Row
        let hasChildren: Bool
        
        init(title: String, row: Row, hasChildren: Bool = false) {
            self.title = title
            self.rowType = row
            self.hasChildren = hasChildren
        }
        
        private let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
    }
}
