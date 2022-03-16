//
//  ViewExistingGameViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/18/22.
//

import UIKit

class ViewExistingGameViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, ExistingGameData>!
    
    private var game: Game

    init(withGame game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = game.teamName
        self.navigationItem.backButtonTitle = "Back"
        
        self.initializeViews()
    }
}

extension ViewExistingGameViewController {
    private func initializeViews() {
        configureCollectionView()
        configureDataSource()
        configureSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return NSCollectionLayoutSection.list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureDataSource() {
        // Any Cell Registration functions that are needed go here.
        let playerHeaderCell = createHeaderListCellRegistration()
        let disclosureCell = createDisclosureCellReigstriation()
        let dataDisplayCell = createDataDisplayCellRegistration()
        let switchCell = createSwitchListCellRegistration()
        
        // Configure the data source and return the UICollectionViewListCell.
        self.dataSource = UICollectionViewDiffableDataSource<Section, ExistingGameData>(collectionView: self.collectionView) { (collectionView, indexPath, gameData) -> UICollectionViewListCell in
            let title = gameData.rowType == .playerHeader ? self.titleForRow(row: gameData.rowType, playerId: gameData.playerParentId) : self.titleForRow(row: gameData.rowType)
            switch gameData.rowType {
            case .scoreCard, .lootCards:
                return collectionView.dequeueConfiguredReusableCell(using: disclosureCell, for: indexPath, item: title)
            case .playerHeader:
                return collectionView.dequeueConfiguredReusableCell(using: playerHeaderCell, for: indexPath, item: title)
            case .legacyMode:
                let switchData = SwitchCellInformation(title: title, enabled: self.game.legacyMode)
                return collectionView.dequeueConfiguredReusableCell(using: switchCell, for: indexPath, item: switchData)
            case .teamName:
                let cellInfo = CellInformation(title: title, value: self.game.teamName)
                return collectionView.dequeueConfiguredReusableCell(using: dataDisplayCell, for: indexPath, item: cellInfo)
            case .numberOfPlayers:
                let cellInfo = CellInformation(title: title, value: String(describing: self.game.numberOfPlayers))
                return collectionView.dequeueConfiguredReusableCell(using: dataDisplayCell, for: indexPath, item: cellInfo)
            case .difficulty:
                let cellInfo = CellInformation(title: title, value: self.game.difficulty)
                return collectionView.dequeueConfiguredReusableCell(using: dataDisplayCell, for: indexPath, item: cellInfo)
            case .playerName:
                guard let playerIndex = gameData.playerParentId, let player = self.game.player(forIndex: playerIndex) else { return UICollectionViewListCell() }
                let cellInfo = CellInformation(title: title, value: player.name)
                return collectionView.dequeueConfiguredReusableCell(using: dataDisplayCell, for: indexPath, item: cellInfo)
            case .playerCharacter:
                guard let playerIndex = gameData.playerParentId, let player = self.game.player(forIndex: playerIndex) else { return UICollectionViewListCell() }
                let cellInfo = CellInformation(title: title, value: player.character)
                return collectionView.dequeueConfiguredReusableCell(using: dataDisplayCell, for: indexPath, item: cellInfo)
            }
        }
    }
    
    private func configureSnapshot() {
        // Overall snapshot:
        var snapshot = NSDiffableDataSourceSnapshot<Section, ExistingGameData>()
        // Append all of the sections to the snapshot:
        let sections: [Section] = [
            .basicInfo,
            .players,
            .editLootAndScore
        ]
        snapshot.appendSections(sections)
        
        // Basic Info section snapshot:
        var basicInfoSnapshot = NSDiffableDataSourceSectionSnapshot<ExistingGameData>()
        let basicInfoRows = [
            ExistingGameData(rowType: .teamName),
            ExistingGameData(rowType: .numberOfPlayers),
            ExistingGameData(rowType: .legacyMode),
            ExistingGameData(rowType: .difficulty)
        ]
        basicInfoSnapshot.append(basicInfoRows)
        
        // Players section snapshot:
        var playerSnapshot = NSDiffableDataSourceSectionSnapshot<ExistingGameData>()
        // For every player in the game, add them to the snapshot:
        for i in 0..<Int(self.game.numberOfPlayers) {
            // Create the player header row:
            var playerHeader = ExistingGameData(rowType: .playerHeader, hasChildren: true)
            playerHeader.playerParentId = i
            // Append the player header to the player snapshot:
            playerSnapshot.append([playerHeader])
            
            // Create the player data rows:
            var name = ExistingGameData(rowType: .playerName)
            name.playerParentId = i
            var character = ExistingGameData(rowType: .playerCharacter)
            character.playerParentId = i
            
            // Append the player data rows to the player header:
            playerSnapshot.append([name, character], to: playerHeader)
        }
        
        // Scorecard section snapshot:
        var scorecardSnapshot = NSDiffableDataSourceSectionSnapshot<ExistingGameData>()
        scorecardSnapshot.append([
                                    ExistingGameData(rowType: .lootCards),
                                    ExistingGameData(rowType: .scoreCard)
                                 ])
        
        // Apply the snapshot to the datasource and apply all of the section snapshots to the overall snapshot:
        self.dataSource.apply(snapshot)
        self.dataSource.apply(basicInfoSnapshot, to: .basicInfo, animatingDifferences: false)
        self.dataSource.apply(playerSnapshot, to: .players, animatingDifferences: false)
        self.dataSource.apply(scorecardSnapshot, to: .editLootAndScore, animatingDifferences: false)
    }
}

extension ViewExistingGameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        switch item.rowType {
        case .scoreCard:
            let vc = ScenarioManagerViewController(withGame: game)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        // Only allow the player loot cards and scorecard rows to be selectable.
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item.rowType {
        case .lootCards, .scoreCard:
            return true
        default:
            return false
        }
    }
}

extension ViewExistingGameViewController {
    private func createHeaderListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    private func createDisclosureCellReigstriation() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> {
            cell, indexPath, title in
            var config = cell.defaultContentConfiguration()
            config.text = title
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    private func createDataDisplayCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, CellInformation> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, CellInformation> {
            cell, indexPath, data in
            var config = DataDisplayContentConfiguration()
            config.title = data.title
            config.value = data.value
            cell.contentConfiguration = config
        }
    }
    
    private func createSwitchListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SwitchCellInformation> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, SwitchCellInformation> { cell, indexPath, data in
            var config = SwitchListContentConfiguration()
            config.title = data.title
            config.switchIsOn = data.enabled
            cell.contentConfiguration = config
            cell.isUserInteractionEnabled = false
            // Give the switch the faded view indicating they can't toggle the switch.
            for view in cell.contentView.subviews {
                if let sw = view as? UISwitch {
                    sw.isEnabled = false
                }
            }
        }
    }
}

extension ViewExistingGameViewController {
    private enum Section {
        case basicInfo
        case players
        case editLootAndScore
    }
    
    private enum Row {
        case teamName
        case numberOfPlayers
        case legacyMode
        case difficulty
        case playerHeader
        case playerName
        case playerCharacter
        case lootCards
        case scoreCard
    }
    
    private struct ExistingGameData: Hashable {
        var rowType: Row
        var hasChildren: Bool
        var playerParentId: Int?
        
        init(rowType: Row, hasChildren: Bool = false) {
            self.rowType = rowType
            self.hasChildren = hasChildren
        }
        
        private let identifier: UUID = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    private struct CellInformation {
        var title: String
        var value: String
    }
    
    private struct SwitchCellInformation {
        var title: String
        var enabled: Bool
    }
    
    private func titleForRow(row: Row, playerId: Int? = nil) -> String {
        switch row {
        case .teamName:
            return "Team Name"
        case .numberOfPlayers:
            return "Number of Players"
        case .legacyMode:
            return "Legacy Mode"
        case .difficulty:
            return "Difficulty"
        case .playerHeader:
            guard let playerId = playerId else { return "" }
            let playerNum = playerId.description
            return "Player \(playerNum)"
        case .playerName:
            return "Name"
        case .playerCharacter:
            return "Character"
        case .lootCards:
            return "Edit Loot Cards"
        case .scoreCard:
            return "Edit Scorecard"
        }
    }
}
