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
    
    private lazy var teams: [Game] = [Game(name: "Team 1", difficulty: .normal, players: 2, position: 0),
                                      Game(name: "Team 2", difficulty: .veteran, players: 4, position: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DTA Helper"
        setupTableView()
        configureDataSource()
        configureInitialSnapshot(false)
        configureEditingButton()
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

// MARK: - UI Setup Functions
extension HomeScreenViewController {
    private func configureInitialSnapshot(_ animated: Bool = true) {
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Game>()
        initialSnapshot.appendSections([.createNewTeam, .existingTeams])
        
        // Create an empty item to give the create new section a row.
        initialSnapshot.appendItems([Game()], toSection: .createNewTeam)
        
        if !self.teams.isEmpty {
            // Assign any existing teams to a cell.
            initialSnapshot.appendItems(teams, toSection: .existingTeams)
        }

        self.dataSource.apply(initialSnapshot, animatingDifferences: animated)
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
            (tableView: UITableView, indexPath: IndexPath, team: Game) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenViewController.reuseIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            if indexPath.section == 0 {
                content.text = "Create a new team"
                cell.accessoryType = .disclosureIndicator
            } else if indexPath.section == 1 {
                content.text = team.teamName
                content.secondaryText = "\(team.difficulty) \(team.players)"
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
    class DataSource: UITableViewDiffableDataSource<Section, Game> {
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

// MARK: UITableView Delegate Functions
extension HomeScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - Send this to a screen
        let alert = UIAlertController(title: "hello", message: "world", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        self.navigationController?.present(alert, animated: true)
    }
}

// MARK: - Table Modeling Data
extension HomeScreenViewController {
    enum Section {
        case createNewTeam
        case existingTeams
    }
    
    enum Difficulties {
        case normal
        case veteran
    }
    
    struct Game: Hashable {
        let teamName: String
        let difficulty: Difficulties
        let players: Int
        let listPosition: Int
        
        // Init to make an empty object.
        init() {
            self.teamName = ""
            self.difficulty = .normal
            self.players = 0
            self.listPosition = 0
            self.identifier = UUID()
        }
        
        // Init to make an object with some data passed in.
        init(name: String, difficulty: Difficulties, players: Int, position: Int) {
            self.teamName = name
            self.difficulty = difficulty
            self.players = players
            self.listPosition = position
            self.identifier = UUID()
        }
        
        // UUID and hash function
        private let identifier: UUID
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
        
    }
}
