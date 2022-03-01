//
//  ScenarioManagerViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/20/22.
//

import UIKit

class ScenarioManagerViewController: UIViewController {
    
    let game: Game
    var dataSource: DataSource!
    var collectionView: UICollectionView!
    var scenarioInfo: NewScenarioInformation?
    var campaignScore: Int = 0
    
    init(withGame game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scenarios"
        
        registerKeyboardNotifications()
        calculateCampaignTotal()
        initialSetup()
    }
}

// MARK: - View Setup Functions
extension ScenarioManagerViewController {
    private func initialSetup() {
        configureCollectionView()
        configureDataSource()
        configureInitialSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return NSCollectionLayoutSection.list(using: .init(appearance: .insetGrouped), layoutEnvironment: layoutEnvironment)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureInitialSnapshot() {
        if let scenarios = self.game.scenariosAsArray(), !scenarios.isEmpty {
            // If they do have scenario data to display,
            // We don't need to start them off with a "Add scenario" section.
            setDataSourceInformation(isAdding: false, scenarios: scenarios)
        } else {
            setDataSourceInformation(isAdding: true, scenarios: [])
            
            // If they don't have an existing scenario for data to display,
            // then start them off with a "Add scenario" section.
            guard let diff = Difficulty(rawValue: self.game.difficulty) else { return }
            self.scenarioInfo = NewScenarioInformation(scenarioScore: diff.score(), wonScenario: true, totalScore: diff.score())
        }
        self.dataSource.configureSnapshot()
    }
    
    func setDataSourceInformation(isAdding: Bool, scenarios: [Scenario]) {
        self.dataSource.isAddingScenario = isAdding
        self.dataSource.scenarios = scenarios
        
        // Show the correct right bar button item.
        if isAdding {
            cancelRightBarButtonItem()
        } else {
            addRightBarButtonItem()
        }
    }
}

// MARK: - Right Bar Button Setup
extension ScenarioManagerViewController {
    private func addRightBarButtonItem() {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScenarioSection))
        self.navigationItem.rightBarButtonItem = button
    }
    
    private func cancelRightBarButtonItem() {
        if let scenarios = self.game.scenarios, !scenarios.isEmpty {
            let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(removeScenarioSection))
            self.navigationItem.rightBarButtonItem = button
        }
    }
    
    @objc private func addScenarioSection() {
        guard let diff = Difficulty(rawValue: self.game.difficulty) else { return }
        // If they are already in "adding mode", then don't do anything.
        if self.dataSource.isAddingScenario { return }
        
        self.scenarioInfo = NewScenarioInformation(scenarioScore: diff.score(), wonScenario: true, totalScore: diff.score())
        
        // Update to show the cancel button.
        cancelRightBarButtonItem()
        
        // Put them in editing mode and reload the data source to show the add new section.
        self.setDataSourceInformation(isAdding: true, scenarios: self.game.scenariosAsArray() ?? [])
        self.dataSource.configureSnapshot()
    }
    
    @objc private func removeScenarioSection() {
        // If they are already in "adding mode", then don't do anything.
        if !self.dataSource.isAddingScenario { return }
        
        self.scenarioInfo = nil
        
        // Update to show the add button.
        addRightBarButtonItem()
        
        // Put them in editing mode and reload the data source to show the add new section.
        self.setDataSourceInformation(isAdding: false, scenarios: self.game.scenariosAsArray() ?? [])
        self.dataSource.configureSnapshot()
    }
}

// MARK: - CollectionView DataSource Setup and Functions
extension ScenarioManagerViewController {
    private func configureDataSource() {
        // Register collectionview list cells here
        let scoreEntryCell = configureScoreEntryCellRegistration()
        let switchCell = configureSwitchListCellRegistration()
        let saveCell = configureSaveListCellRegistration()
        let deleteCell = configureDeleteListCellRegistration()
        let listHeaderCell = configureHeaderListCellRegistration()
        
        // Set the data source and return the appropriate cell:
        self.dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, scenarioData in
            let value = self.valueForRow(row: scenarioData.rowType, section: scenarioData.sectionType, scenarioIndex: scenarioData.headerScenarioIndex)
            
            // Build the cell based on the row type.
            switch scenarioData.rowType {
            case .campaignScore:
                var cellInfo = ScoreEntryCellInformation(title: scenarioData.title, subtitle: "", sectionType: .campaignOverview, rowType: .campaignScore)
                cellInfo.value = self.campaignScore
                return collectionView.dequeueConfiguredReusableCell(using: scoreEntryCell, for: indexPath, item: cellInfo)
            case .winLoss:
                var cellInfo = ScoreEntryCellInformation(title: scenarioData.title, subtitle: scenarioData.subtitle, sectionType: scenarioData.sectionType, rowType: .winLoss)
                cellInfo.value = value
                return collectionView.dequeueConfiguredReusableCell(using: switchCell, for: indexPath, item: cellInfo)
            case .save:
                return collectionView.dequeueConfiguredReusableCell(using: saveCell, for: indexPath, item: scenarioData.title)
            case .delete:
                return collectionView.dequeueConfiguredReusableCell(using: deleteCell, for: indexPath, item: scenarioData.title)
            case .scenarioHeader:
                return collectionView.dequeueConfiguredReusableCell(using: listHeaderCell, for: indexPath, item: scenarioData.title)
            default:
                var cellInfo = ScoreEntryCellInformation(title: scenarioData.title, subtitle: scenarioData.subtitle, sectionType: scenarioData.sectionType, rowType: scenarioData.rowType)
                cellInfo.value = value
                return collectionView.dequeueConfiguredReusableCell(using: scoreEntryCell, for: indexPath, item: cellInfo)
            }
        }
    }
    
    class DataSource: UICollectionViewDiffableDataSource<Section, ScenarioData> {
        var isAddingScenario: Bool = false
        var scenarios: [Scenario] = []
        
        // Apply the snapshot to showcase all scenarios in the game.
        func configureSnapshot() {
            DispatchQueue.main.async {
                // Setup the new snapshot:
                var newSnapshot = self.snapshot()
                newSnapshot.deleteAllItems()
                self.apply(newSnapshot, animatingDifferences: false)
                
                // Add the campaign overview section:
                newSnapshot.appendSections([.campaignOverview])
                var campaignSnapshot = NSDiffableDataSourceSectionSnapshot<ScenarioData>()
                campaignSnapshot.append([ScenarioData(title: "Campaign Score", subtitle: "", sectionType: .campaignOverview, rowType: .campaignScore)])
                self.apply(campaignSnapshot, to: .campaignOverview, animatingDifferences: false)
                
                // If we have existing scenario data from core data to show, show it:
                if !self.scenarios.isEmpty {
                    newSnapshot.appendSections([.existingScenarios])
                    var existingSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ScenarioData>()
                    
                    // For every scenario in the existing scenarios list,
                    // we need to add it to the existing scenarios section.
                    var i = 0
                    for scenario in self.scenarios {
                        // Create the header for this scenario
                        var scenarioRoot = ScenarioData(title: "Scenario \(Int(scenario.scenarioNumber))", subtitle: "", sectionType: .existingScenarios, rowType: .scenarioHeader, hasChildren: true)
                        scenarioRoot.headerScenarioIndex = i
                        existingSectionSnapshot.append([scenarioRoot])
                        
                        // Create and add the rows:
                        var remainingSalves = ScenarioData(title: "Remaining Salves", subtitle: "+1 for every unspent salve.", sectionType: .existingScenarios, rowType: .remainingSalves)
                        remainingSalves.headerScenarioIndex = i
                        var unspentGold = ScenarioData(title: "Unspent Gold", subtitle: "+1 for every 5 gold your team didn't spend.", sectionType: .existingScenarios, rowType: .unspentGold)
                        unspentGold.headerScenarioIndex = i
                        var unclaimedBossLoot = ScenarioData(title: "Unclaimed Boss Loot", subtitle: "+1 for every unclaimed boss loot.", sectionType: .existingScenarios, rowType: .unclaimedBossLoot)
                        unclaimedBossLoot.headerScenarioIndex = i
                        var fullExploration = ScenarioData(title: "Explored All Tiles", subtitle: "+5 if you explored all environment tiles.", sectionType: .existingScenarios, rowType: .fullExploration)
                        fullExploration.headerScenarioIndex = i
                        var scenarioScore = ScenarioData(title: "Scenario Score", subtitle: "Difficulty of the campaign.", sectionType: .existingScenarios, rowType: .scenarioScore)
                        scenarioScore.headerScenarioIndex = i
                        var winLoss = ScenarioData(title: "Won Scenario", subtitle: "", sectionType: .existingScenarios, rowType: .winLoss)
                        winLoss.headerScenarioIndex = i
                        var totalScore = ScenarioData(title: "Total Score", subtitle: "", sectionType: .existingScenarios, rowType: .totalScore)
                        totalScore.headerScenarioIndex = i
                        var delete = ScenarioData(title: "Delete", subtitle: "", sectionType: .existingScenarios, rowType: .delete)
                        delete.headerScenarioIndex = i
                        
                        // Append the child rows to the root.
                        existingSectionSnapshot.append([
                            remainingSalves,
                            unspentGold,
                            unclaimedBossLoot,
                            fullExploration,
                            scenarioScore,
                            winLoss,
                            totalScore,
                            delete
                        ], to: scenarioRoot)
                        
                        i += 1
                    }
                    self.apply(existingSectionSnapshot, to: .existingScenarios, animatingDifferences: false)
                }
                
                
                // Then if we are adding a scenario,
                // We need to show the add scenario section.
                if self.isAddingScenario {
                    newSnapshot.appendSections([.addScenario])
                    var addingSnapshot = NSDiffableDataSourceSectionSnapshot<ScenarioData>()
                    
                    // Create and add the rows:
                    let scenarioNumber = ScenarioData(title: "Scenario Number", subtitle: "", sectionType: .addScenario, rowType: .scenarioNumber)
                    let remainingSalves = ScenarioData(title: "Remaining Salves", subtitle: "+1 for every unspent salve.", sectionType: .addScenario, rowType: .remainingSalves)
                    let unspentGold = ScenarioData(title: "Unspent Gold", subtitle: "+1 for every 5 gold your team didn't spend.", sectionType: .addScenario, rowType: .unspentGold)
                    let unclaimedBossLoot = ScenarioData(title: "Unclaimed Boss Loot", subtitle: "+1 for every unclaimed boss loot.", sectionType: .addScenario, rowType: .unclaimedBossLoot)
                    let fullExploration = ScenarioData(title: "Explored All Tiles", subtitle: "+5 if you explored all environment tiles.", sectionType: .addScenario, rowType: .fullExploration)
                    let scenarioScore = ScenarioData(title: "Scenario Score", subtitle: "Difficulty of the campaign.", sectionType: .addScenario, rowType: .scenarioScore)
                    let winLoss = ScenarioData(title: "Won Scenario", subtitle: "", sectionType: .addScenario, rowType: .winLoss)
                    let totalScore = ScenarioData(title: "Total Score", subtitle: "", sectionType: .addScenario, rowType: .totalScore)
                    let save = ScenarioData(title: "Save", subtitle: "", sectionType: .addScenario, rowType: .save)
                    
                    // Add the rows to the snapshot:
                    addingSnapshot.append([
                        scenarioNumber,
                        remainingSalves,
                        unspentGold,
                        unclaimedBossLoot,
                        fullExploration,
                        scenarioScore,
                        winLoss,
                        totalScore,
                        save
                    ])
                    
                    // Apply the section to the datasource snapshot:
                    self.apply(addingSnapshot, to: .addScenario, animatingDifferences: true)
                }
            }
        }
    }
}

// MARK: - CollectionView Modelling Informaion
extension ScenarioManagerViewController {
    enum Section {
        case campaignOverview
        case addScenario
        case existingScenarios
    }
    
    enum Row: Int {
        case campaignScore
        case scenarioHeader
        case scenarioNumber
        case remainingSalves
        case unspentGold
        case unclaimedBossLoot
        case fullExploration
        case scenarioScore
        case winLoss
        case totalScore
        case save
        case delete
    }
    
    struct ScenarioData: Hashable {
        var sectionType: Section
        var rowType: Row
        var title: String
        var subtitle: String
        var hasChildren: Bool
        var headerScenarioIndex: Int?
        
        init(title: String, subtitle: String, sectionType: Section, rowType: Row, hasChildren: Bool = false) {
            self.title = title
            self.subtitle = subtitle
            self.sectionType = sectionType
            self.rowType = rowType
            self.hasChildren = hasChildren
        }
        
        private let identifier: UUID = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    struct ScoreEntryCellInformation {
        var title: String
        var value: Any?
        var subtitle: String
        var sectionType: Section
        var rowType: Row
    }
    
    struct NewScenarioInformation {
        var scenarioNumber: Int?
        var remainingSalves: Int?
        var unspentGold: Int?
        var unclaimedBossLoot: Int?
        var exploration: Int?
        var scenarioScore: Int
        var wonScenario: Bool
        var totalScore: Int
    }
}
