//
//  CreateNewGameViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/9/22.
//

import UIKit

class CreateNewGameViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var gameInfo = GameInformation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create A New Game"
        
        self.initializeViews()
    }
    
    private func updatePlayerData(forPlayerIndex index: Int, name: String? = nil, character: String? = nil, lootCards: String? = nil) {
        guard var player = gameInfo.playerData[index] else { return }
        if let name = name {
            player.name = name
        }
        if let character = character {
            player.character = character
        }
        if let lootCards = lootCards {
            player.lootCards = lootCards
        }
        gameInfo.playerData[index] = player
    }
    
    private func updateGameInfoPlayers() {
        let sectionSnap = self.dataSource.snapshot(for: .playerInfo)
        let visiblePlayers = sectionSnap.rootItems
        for i in 0..<visiblePlayers.count {
            // Check if the gameInfo contains this characters information.
            // If it doesn't, then add blank data.
            if gameInfo.playerData[i] == nil {
                gameInfo.playerData[i] = PlayerInformation(playerId: i, name: "", character: "", lootCards: "")
            }
        }
        
        // Next remove any characters from gameInfo that are no longer shown.
        for i in visiblePlayers.count..<4 {
            gameInfo.playerData[i] = nil
        }
    }
    
    @objc private func switchToggled(_ sender: Any) {
        guard let uiSwitch = sender as? UISwitch else { return }
        self.gameInfo.legacyMode = uiSwitch.isOn
        self.dataSource.updateUIForLegacyMode()
    }
}

// MARK: - UICollectionView Delegate Functions
extension CreateNewGameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.resignFirstResponder()
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch item.rowType {
        case .name, .teamName:
            if let cell = collectionView.cellForItem(at: indexPath) as? TextEntryCollectionViewCell, let contentView = cell.contentView as? TextEntryContentView, item.rowType != .character {
                contentView.textField.becomeFirstResponder()
            }
        case .character:
            if let item = self.dataSource.itemIdentifier(for: IndexPath(row: indexPath.row + 1, section: indexPath.section)),
               item.rowType == .characterPicker {
                self.dataSource.removeCharacterSelectionPicker(withIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section))
            } else {
                self.dataSource.showCharacterSelectionPicker(withIndexPath: indexPath)
            }
        case .difficulty:
            if let item = self.dataSource.itemIdentifier(for: IndexPath(row: indexPath.row + 1, section: indexPath.section)),
               item.rowType == .difficultyPicker {
                self.dataSource.removeDifficultySelectionPicker(withIndexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section))
            } else {
                self.dataSource.showDifficultySelectionPicker(withIndexPath: indexPath)
            }
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item.rowType {
        case .characterPicker, .difficultyPicker, .numberOfPlayers, .name, .teamName, .legacyMode:
            return false
        default:
            return true
        }
    }
}

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
            self.dataSource.updatePlayerRows(playerCount: playerCount)
            self.updateGameInfoPlayers()
            self.gameInfo.numberOfPlayers = playerCount
        default:
            fatalError("Unknown segmented control cell updated.")
        }
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
            self.dataSource.apply(snap)
        }
    }
}

// MARK: - DifficultySelectedDelegate Functions
extension CreateNewGameViewController: DifficultySelectedDelegate {
    func updateSelectedDifficulty(withDifficulty difficulty: String, indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let diffItem = self.dataSource.itemIdentifier(for: IndexPath(row: indexPath.row - 1, section: indexPath.section)) else { return }
            self.gameInfo.difficulty = difficulty
            var snap = self.dataSource.snapshot()
            snap.reloadItems([diffItem])
            self.dataSource.apply(snap)
        }
    }
}

// MARK: - View Initialization and Configuration Functions
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
            return NSCollectionLayoutSection.list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func applyInitialSnapshot() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItemInformation>()
        snapshot.appendSections(sections)
        
        // Apply the basic info row item to the section in the snapshot
        var basicInfoSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItemInformation>()
        let basicInfoRows = [
            DataSourceItemInformation(row: .teamName),
            DataSourceItemInformation(row: .numberOfPlayers),
            DataSourceItemInformation(row: .legacyMode),
            DataSourceItemInformation(row: .difficulty)
        ]
        basicInfoSnapshot.append(basicInfoRows)
        
        // Apply the section for number of players.
        // Because the min is 1, in the initial setup, just show 1 section.
        var playerSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItemInformation>()
        let playerRoot = DataSourceItemInformation(row: .player, hasChildren: true)
        playerSnapshot.append([playerRoot])
        let playerId = 0
        var name = DataSourceItemInformation(row: .name)
        var character = DataSourceItemInformation(row: .character)
        var lootCards = DataSourceItemInformation(row: .lootCards)
        // Assign the parent id's
        name.parentId = playerId
        character.parentId = playerId
        lootCards.parentId = playerId
        let playerInformationRows = [name, character, lootCards]
        playerSnapshot.append(playerInformationRows, to: playerRoot)
        self.gameInfo.playerData[playerId] = PlayerInformation(playerId: playerId, name: "", character: "", lootCards: "")
        
        // Apply the scorecard section
        var scorecardSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItemInformation>()
        scorecardSnapshot.append([DataSourceItemInformation(row: .scorecard)])
        
        // Finally, apply the save button section
        var saveSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItemInformation>()
        saveSnapshot.append([DataSourceItemInformation(row: .save)])
        
        // Apply all of the snapshots to the data source.
        self.dataSource.apply(snapshot)
        self.dataSource.apply(basicInfoSnapshot, to: .basicInfo, animatingDifferences: false)
        self.dataSource.apply(playerSnapshot, to: .playerInfo, animatingDifferences: false)
        self.dataSource.apply(scorecardSnapshot, to: .scorecard, animatingDifferences: false)
        self.dataSource.apply(saveSnapshot, to: .save, animatingDifferences: false)
    }
}

// MARK: - DataSource Configuration and Cell Registration
extension CreateNewGameViewController {
    private func configureDataSource() {
        // Register dequeuable cells.
        let textEntryCell = createTextEntryListCellRegistration()
        let segmentedControlCell = createSegmentedControlListCellRegistration()
        let charPickerViewCell = createCharacterPickerViewListCellRegistration()
        let diffPickerViewCell = createDifficultyPickerViewListCellRegistration()
        let listHeaderCell = createHeaderListCellRegistration()
        let disclosureItemCell = createDisclosureItemListCellRegistration()
        let saveCell = createSaveListCellRegistration()
        let switchCell = createSwitchListCellRegistration()
        
        // Configure data source
        self.dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, info in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown Section Type") }
            let rowTitle = info.rowType == .player ? self.getTitleForRow(rowType: info.rowType, playerId: indexPath.row + 1) : self.getTitleForRow(rowType: info.rowType)
            
            switch section {
            case .basicInfo:
                switch info.rowType {
                case .teamName:
                    var obj = TextEntryCellInformation(title: rowTitle, rowType: info.rowType)
                    obj.value = self.gameInfo.teamName
                    return collectionView.dequeueConfiguredReusableCell(using: textEntryCell, for: indexPath, item: obj)
                case .legacyMode:
                    let data: (String, Bool) = (rowTitle, self.gameInfo.legacyMode ?? false)
                    return collectionView.dequeueConfiguredReusableCell(using: switchCell, for: indexPath, item: data)
                case .difficulty:
                    var cellInfo = TextEntryCellInformation(title: rowTitle, rowType: info.rowType)
                    cellInfo.value = self.gameInfo.difficulty
                    cellInfo.isSelectable = false
                    return collectionView.dequeueConfiguredReusableCell(using: textEntryCell, for: indexPath, item: cellInfo)
                case .difficultyPicker:
                    return collectionView.dequeueConfiguredReusableCell(using: diffPickerViewCell, for: indexPath, item: "")
                case .numberOfPlayers:
                    let items = [1, 2, 3, 4]
                    var cellInfo = SegmentedControlCellInformation(title: rowTitle, rowType: info.rowType, items: items)
                    if var playerIndex = self.gameInfo.numberOfPlayers {
                        playerIndex = playerIndex - 1
                        cellInfo.selectedIndex = playerIndex
                    }
                    return collectionView.dequeueConfiguredReusableCell(using: segmentedControlCell, for: indexPath, item: cellInfo)
                default:
                    break
                }
            case .playerInfo:
                if info.hasChildren {
                    return collectionView.dequeueConfiguredReusableCell(using: listHeaderCell, for: indexPath, item: rowTitle)
                } else {
                    switch info.rowType {
                    case .name:
                        guard let parentId = info.parentId else { return UICollectionViewListCell() }
                        var obj = TextEntryCellInformation(title: rowTitle, rowType: info.rowType)
                        obj.parentId = parentId
                        obj.value = self.gameInfo.playerData[parentId]?.name
                        return collectionView.dequeueConfiguredReusableCell(using: textEntryCell, for: indexPath, item: obj)
                    case .character:
                        guard let parentId = info.parentId else { return UICollectionViewListCell() }
                        let playerData = self.gameInfo.playerData[parentId]
                        var obj = TextEntryCellInformation(title: rowTitle, rowType: info.rowType)
                        obj.value = playerData?.character
                        obj.isSelectable = false
                        obj.parentId = parentId
                        return collectionView.dequeueConfiguredReusableCell(using: textEntryCell, for: indexPath, item: obj)
                    case .characterPicker:
                        guard let parentId = info.parentId else { return UICollectionViewListCell() }
                        let characterSelection = self.gameInfo.playerData[parentId]?.character
                        return collectionView.dequeueConfiguredReusableCell(using: charPickerViewCell, for: indexPath, item: characterSelection)
                    case .lootCards:
                        return collectionView.dequeueConfiguredReusableCell(using: disclosureItemCell, for: indexPath, item: rowTitle)
                    default:
                        break
                    }
                }
            case .scorecard:
                return collectionView.dequeueConfiguredReusableCell(using: disclosureItemCell, for: indexPath, item: rowTitle)
            case .save:
                return collectionView.dequeueConfiguredReusableCell(using: saveCell, for: indexPath, item: rowTitle)
            }
            return UICollectionViewListCell()
        }
    }
    
    private class DataSource: UICollectionViewDiffableDataSource<Section, DataSourceItemInformation> {
        func updatePlayerRows(playerCount: Int) {
            var playerSnapshot = NSDiffableDataSourceSectionSnapshot<DataSourceItemInformation>()
            for i in 0..<playerCount {
                let playerRoot = DataSourceItemInformation(row: .player, hasChildren: true)
                playerSnapshot.append([playerRoot])
                var name = DataSourceItemInformation(row: .name)
                var character = DataSourceItemInformation(row: .character)
                var lootCards = DataSourceItemInformation(row: .lootCards)
                // Assign the parent id's
                name.parentId = i
                character.parentId = i
                lootCards.parentId = i
                let playerInformationRows = [name, character, lootCards]
                playerSnapshot.append(playerInformationRows, to: playerRoot)
            }
            self.apply(playerSnapshot, to: .playerInfo, animatingDifferences: true)
        }
        
        func showCharacterSelectionPicker(withIndexPath indexPath: IndexPath) {
            if let idOfSelection = self.itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                var info = DataSourceItemInformation(row: .characterPicker)
                info.parentId = idOfSelection.parentId
                snapshot.insertItems([info], afterItem: idOfSelection)
                self.apply(snapshot, animatingDifferences: false)
            }
        }
        
        func removeCharacterSelectionPicker(withIndexPath indexPath: IndexPath) {
            if let idToDelete = self.itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                snapshot.deleteItems([idToDelete])
                self.apply(snapshot)
            }
        }
        
        func showDifficultySelectionPicker(withIndexPath indexPath: IndexPath) {
            if let idOfSelection = self.itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                let pickerView = DataSourceItemInformation(row: .difficultyPicker)
                snapshot.insertItems([pickerView], afterItem: idOfSelection)
                self.apply(snapshot, animatingDifferences: false)
            }
        }
        
        func removeDifficultySelectionPicker(withIndexPath indexPath: IndexPath) {
            if let idToDelete = self.itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                snapshot.deleteItems([idToDelete])
                self.apply(snapshot)
            }
        }
        
        func updateUIForLegacyMode() {
            var newSnapshot = self.snapshot()
            guard let item = newSnapshot.itemIdentifiers.filter({ $0.rowType == .difficultyPicker }).first else { return }
            newSnapshot.reloadItems([item])
            self.apply(newSnapshot, animatingDifferences: true)
        }
    }
}

// MARK: - CollectionView Modeling Structs and Enums
extension CreateNewGameViewController {
    enum Section: Int, CaseIterable {
        case basicInfo
        case playerInfo
        case scorecard
        case save
    }
    
    enum Row: Int {
        case unspecified
        case teamName
        case numberOfPlayers
        case legacyMode
        case difficulty
        case difficultyPicker
        case player
        case name
        case character
        case characterPicker
        case lootCards
        case scorecard
        case save
    }
    
    enum Difficulty: Int {
        case normal
        case veteran
        case hardcore
        case insane

        func description() -> String {
            switch self {
            case .normal:
                return "Normal"
            case .veteran:
                return "Veteran"
            case .hardcore:
                return "Hardcore"
            case .insane:
                return "Insane"
            }
        }
    }
    
    private struct DataSourceItemInformation: Hashable {
        let rowType: Row
        let hasChildren: Bool
        var value: String?
        var parentId: Int?
        var isSelected: Bool?
        
        init(row: Row, hasChildren: Bool = false) {
            self.rowType = row
            self.hasChildren = hasChildren
        }
        
        private let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
    }
    
    private struct GameInformation {
        var teamName: String?
        var difficulty: String?
        var numberOfPlayers: Int?
        var playerData: [PlayerInformation?] = Array(repeating: nil, count: 4)
        var scorecard: String?
        var legacyMode: Bool?
    }
    
    private struct PlayerInformation {
        var playerId: Int
        var name: String
        var character: String
        var lootCards: String
    }
    
    private struct TextEntryCellInformation {
        var title: String
        var rowType: Row
        var value: String?
        var isSelectable: Bool = true
        var parentId: Int?
        
        init(title: String, rowType: Row) {
            self.title = title
            self.rowType = rowType
        }
    }
    
    private struct SegmentedControlCellInformation {
        var title: String
        var rowType: Row
        var items: [Int]
        var selectedIndex: Int = 0
    }
    
    private func getTitleForRow(rowType: Row, playerId: Int? = nil) -> String {
        switch rowType {
        case .unspecified:
            return ""
        case .teamName:
            return "Team Name"
        case .numberOfPlayers:
            return "Number of Players"
        case .legacyMode:
            return "Legacy Mode"
        case .difficulty:
            return "Difficulty"
        case .difficultyPicker:
            return ""
        case .player:
            guard let playerId = playerId else { return "" }
            let playerNum = playerId.description
            return "Player \(playerNum)"
        case .name:
            return "Name"
        case .character:
            return "Character"
        case .characterPicker:
            return ""
        case .lootCards:
            return "Loot Cards"
        case .scorecard:
            return "Edit Scorecard"
        case .save:
            return "Save"
        }
    }
}

// MARK: - Cell Registration Functions
extension CreateNewGameViewController {
    private func createTextEntryListCellRegistration() -> UICollectionView.CellRegistration<TextEntryCollectionViewCell, TextEntryCellInformation> {
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
    
    private func createSegmentedControlListCellRegistration() -> UICollectionView.CellRegistration<SegmentedControlCollectionViewCell, SegmentedControlCellInformation> {
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
    
    private func createCharacterPickerViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, data in
            var config = CharacterPickerViewContentConfiguration()
            config.indexPath = indexPath
            config.delegate = self
            config.currentSelection = data
            cell.contentConfiguration = config
        }
    }
    
    private func createDifficultyPickerViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, data in
            var config = DifficultyPickerViewContentConfiguration()
            config.indexPath = indexPath
            config.delegate = self
            config.currentSelection = self.gameInfo.difficulty
            config.legacyMode = self.gameInfo.legacyMode
            cell.contentConfiguration = config
        }
    }
    
    private func createHeaderListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    private func createDisclosureItemListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    private func createSwitchListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, (String, Bool)> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, (String, Bool)> { cell, indexPath, data in
            var config = cell.defaultContentConfiguration()
            config.text = data.0
            cell.contentConfiguration = config
            let enabledSwitch = UISwitch()
            enabledSwitch.translatesAutoresizingMaskIntoConstraints = false
            enabledSwitch.isOn = data.1
            enabledSwitch.addTarget(self, action: #selector(self.switchToggled(_:)), for: .touchUpInside)
            cell.contentView.addSubview(enabledSwitch)
            let guide = cell.contentView.layoutMarginsGuide
            NSLayoutConstraint.activate([
                enabledSwitch.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
                enabledSwitch.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
            ])
        }
    }
    
    private func createCheckmarkListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, (String, Bool)> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, (String, Bool)> { cell, indexPath, data in
            var content = cell.defaultContentConfiguration()
            content.text = data.0
            cell.contentConfiguration = content
            cell.accessories = data.1 ? [.checkmark()] : []
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
