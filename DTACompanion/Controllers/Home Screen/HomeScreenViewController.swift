//
//  HomeScreenViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/6/22.
//

import UIKit
import CoreData

protocol DeleteGameProtocol: AnyObject {
    func deleteGame(forIndexPath indexPath: IndexPath)
}

class HomeScreenViewController: UIViewController {
    
    static let reuseIdentifier = String(describing: HomeScreenViewController.self)
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var dataSource: DataSource!
    private var allGames: [Game] = []
    private let context = DTAStack.context
    
    override func viewWillAppear(_ animated: Bool) {
        self.allGames = Game.findAll(inContext: self.context)
        DispatchQueue.main.async {
            self.reloadGameData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DTA Companion"
        self.navigationItem.backButtonTitle = "Back"
        self.tableView.register(GameOverviewTableViewCell.self, forCellReuseIdentifier: GameOverviewTableViewCell.identifier)
        
        self.initializeViews()
    }
    
    private func reloadGameData() {
        self.configureInitialSnapshot()
    }
}

// MARK: - Delete Game Delegate
extension HomeScreenViewController: DeleteGameProtocol {
    func deleteGame(forIndexPath indexPath: IndexPath) {
        let alert = UIAlertController(title: "Are You Sure?", message: "Are you sure you want to delete this game?", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .destructive) { _ in
            DispatchQueue.main.async {
                alert.dismiss(animated: true)
                guard indexPath.row < self.allGames.count else { return }
                
                // Get the Game object to delete.
                let gameToDelete = self.allGames[indexPath.row]
                
                // Delete the game from Core Data.
                if gameToDelete.deleteGame(inContext: self.context) {
                    // If the game was deleted from Core Data, remove it from the allGames array.
                    self.allGames.remove(at: indexPath.row)
                    
                    // Update the snapshot to remove the cell for the game that was deleted.
                    self.dataSource.deleteGameFromSnapshot(atIndexPath: indexPath)
                }
            }
        }
        let noButton = UIAlertAction(title: "No", style: .cancel) { _ in
            DispatchQueue.main.async {
                // User reconsidered their choices, so lets not do anything :)
                alert.dismiss(animated: true)
            }
        }
        DispatchQueue.main.async {
            alert.addAction(yesButton)
            alert.addAction(noButton)
            self.navigationController?.present(alert, animated: true)
        }
    }
}

// MARK: - View Initialization Functions
extension HomeScreenViewController {
    private func initializeViews() {
        setupTableView()
        configureDataSource()
        configureInitialSnapshot(false)
        configureEditingButton()
    }
    
    private func configureInitialSnapshot(_ animated: Bool = true) {
        var initialSnapshot = self.dataSource.snapshot()
        initialSnapshot.deleteAllItems()
        initialSnapshot = NSDiffableDataSourceSnapshot<Section, RowData>()
        initialSnapshot.appendSections([.createNewGame])
        
        // Create an empty item to give the create new section a row.
        initialSnapshot.appendItems([RowData(rowType: .createNewGame)], toSection: .createNewGame)
        
        if !self.allGames.isEmpty {
            // Add the existing games section to the snapshot.
            initialSnapshot.appendSections([.existingGame])
            
            // Assign any existing teams to a cell.
            var existingGamesRows: [RowData] = []
            
            for _ in self.allGames {
                existingGamesRows.append(RowData(rowType: .existingGame))
            }
            initialSnapshot.appendItems(existingGamesRows, toSection: .existingGame)
        }
        
        self.dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    private func configureEditingButton() {
        let editingButton = UIBarButtonItem(title: self.tableView.isEditing ? "Done" : "Edit", style: .plain, target: self, action: #selector(toggleEditingMode))
        self.navigationItem.rightBarButtonItem = editingButton
    }
    
    @objc private func toggleEditingMode() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        self.configureEditingButton()
    }
    
    private func configureDataSource() {
        self.dataSource = DataSource(tableView: tableView) { [weak self]
            (tableView: UITableView, indexPath: IndexPath, data: RowData) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            if indexPath.section == Section.createNewGame.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenViewController.reuseIdentifier, for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "Create A New Game"
                cell.accessoryType = .disclosureIndicator
                cell.contentConfiguration = content
                return cell
            } else if indexPath.section == Section.existingGame.rawValue {
                guard indexPath.row < self.allGames.count else { return UITableViewCell() }
                let gameData: Game = self.allGames[indexPath.row]
                guard let cell = tableView.dequeueReusableCell(withIdentifier: GameOverviewTableViewCell.identifier) as? GameOverviewTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupCell(forGame: gameData)
                cell.accessoryType = .disclosureIndicator
                return cell
            } else {
                fatalError("Unknown section found!")
            }
        }
        self.dataSource.deleteDelegate = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HomeScreenViewController.reuseIdentifier)
    }
}

// MARK: Additional UITableViewDiffableDataSourceFunctions
extension HomeScreenViewController {
    class DataSource: UITableViewDiffableDataSource<Section, RowData> {
        weak var deleteDelegate: DeleteGameProtocol?
        
        func deleteGameFromSnapshot(atIndexPath indexPath: IndexPath) {
            DispatchQueue.main.async {
                if let idToDelete = self.itemIdentifier(for: indexPath) {
                    var snapshot = self.snapshot()
                    snapshot.deleteItems([idToDelete])
                    if snapshot.numberOfItems(inSection: .existingGame) == 0, let sectionToRemove = snapshot.sectionIdentifiers.filter({ $0 == .existingGame }).first {
                        snapshot.deleteSections([sectionToRemove])
                    }
                    self.apply(snapshot, animatingDifferences: false)
                }
            }
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return section == 1 ? "Existing Games" : ""
        }
        
        // Editing/Deleting functionality
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return indexPath.section != 0
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                deleteDelegate?.deleteGame(forIndexPath: indexPath)
            }
        }
    }
}

// MARK: UITableView Delegate Functions
extension HomeScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        guard let section = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }
        switch section {
        case .createNewGame:
            let vc = CreateNewGameViewController()
            self.show(vc, sender: nil)
        case .existingGame:
            guard indexPath.row < self.allGames.count else { return }
            let game = self.allGames[indexPath.row]
            let vc = ViewExistingGameViewController(withGame: game)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Table Modeling Data
extension HomeScreenViewController {
    enum Section: Int {
        case createNewGame
        case existingGame
    }
    
    enum Row {
        case createNewGame
        case existingGame
        case noExistingGames
    }
    
    struct RowData: Hashable {
        var rowType: Row
        
        private let identifier: UUID = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
    }
}
