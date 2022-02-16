//
//  HomeScreenViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/6/22.
//

import UIKit

protocol DeleteGameProtocol: AnyObject {
    func deleteGame(forIndexPath indexPath: IndexPath)
}

class HomeScreenViewController: UIViewController {
    
    static let reuseIdentifier = String(describing: self)
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var dataSource: DataSource!
    private var allGames: [Game] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.allGames = Game.findAll()
        DispatchQueue.main.async {
            self.reloadGameData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DTA Companion"
        self.navigationItem.backButtonTitle = "Back"
        
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
            alert.dismiss(animated: true)
            self.dataSource.deleteGameFromSnapshot(atIndexPath: indexPath)
        }
        let noButton = UIAlertAction(title: "No", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.navigationController?.present(alert, animated: true)
    }
}

// MARK: UITableView Delegate Functions
extension HomeScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        guard let section = self.dataSource.sectionIdentifier(for: indexPath.section), indexPath.row < self.allGames.count else { return }
        switch section {
        case .createNewGame:
            let vc = CreateNewGameViewController()
            self.show(vc, sender: nil)
        case .existingGame:
            let game = self.allGames[indexPath.row]
            print(game.teamName)
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
        initialSnapshot.appendSections([.createNewGame, .existingGame])
        
        // Create an empty item to give the create new section a row.
        initialSnapshot.appendItems([RowData(rowType: .createNewGame)], toSection: .createNewGame)
        
        if !self.allGames.isEmpty {
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
        self.dataSource = DataSource(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, data: RowData) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenViewController.reuseIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            if indexPath.section == Section.createNewGame.rawValue {
                content.text = "Create A New Game"
                cell.accessoryType = .disclosureIndicator
            } else if indexPath.section == Section.existingGame.rawValue {
                guard indexPath.row < self.allGames.count else { return UITableViewCell() }
                let gameData: Game = self.allGames[indexPath.row]
                content.text = gameData.teamName
                content.secondaryText = "\(gameData.difficulty) \(gameData.numberOfPlayers)"
                cell.accessoryType = .disclosureIndicator
            } else {
                fatalError("Unknown section found!")
            }
            cell.contentConfiguration = content
            return cell
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
            if let idToDelete = self.itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                snapshot.deleteItems([idToDelete])
                self.apply(snapshot)
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
        
        // Moving functionality:
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return indexPath.section != 0
        }
        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            guard sourceIndexPath != destinationIndexPath else { return }
            guard let sourceID = itemIdentifier(for: sourceIndexPath), let destID = itemIdentifier(for: destinationIndexPath) else { return }
            
            var snapshot = self.snapshot()
            
            if let sourceIndex = snapshot.indexOfItem(sourceID), let destIndex = snapshot.indexOfItem(destID) {
                let isAfter = destIndex > sourceIndex
                snapshot.deleteItems([sourceID])
                if isAfter {
                    snapshot.insertItems([sourceID], afterItem: destID)
                } else {
                    snapshot.insertItems([sourceID], beforeItem: destID)
                }
            }
            apply(snapshot, animatingDifferences: false)
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
    }
    
    struct RowData: Hashable {
        var rowType: Row
        
        private let identifier: UUID = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
    }
}
