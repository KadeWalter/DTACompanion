//
//  LootPlayerSelectionTableViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 3/26/22.
//

import UIKit

class LootPlayerSelectionTableViewController: UITableViewController {
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    private let cellIdentifier = "PlayerSelectionTableViewCell"
    private let players: [Player]
    
    init(withPlayers players: [Player]) {
        self.players = players
        super.init(style: .insetGrouped)
        self.title = "Loot Cards"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureInitialSnapshot()
    }
    
    private func configureDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: self.tableView) {
            (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else { return UITableViewCell() }
            
            // Show the title for the row in the cell.
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    private func configureInitialSnapshot() {
        var snapShot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapShot.appendSections(Section.allCases)
        
        // Create the rows for the individual players in the game.
        var playerRows: [Item] = []
        for player in self.players {
            let newItem = Item(title: "Player \(player.index) - \(player.name)")
            playerRows.append(newItem)
        }
        snapShot.appendItems(playerRows, toSection: .players)
        
        // Create the overall loot row.
        snapShot.appendItems([Item(title: "All Player Loot")], toSection: .overallLoot)
        
        self.dataSource.apply(snapShot, animatingDifferences: false)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - Finish this function.
        self.tableView.deselectRow(at: indexPath, animated: true)
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        if let index = item.playerIndex {
            print("Index: \(index)")
            print("Go to specific player loot screen. Grab player with index.")
        } else {
            print("Go to overall loot screen.")
        }
    }
}

// MARK: - Table Modeling Data
extension LootPlayerSelectionTableViewController {
    enum Section: CaseIterable {
        case players
        case overallLoot
    }
    
    struct Item: Hashable {
        var title: String
        var playerIndex: Int?
        
        let identifier: UUID = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
    }
}
