//
//  GameOverviewTableViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/16/22.
//

import UIKit

class GameOverviewTableViewCell: UITableViewCell {

    static let identifier = String(describing: GameOverviewTableViewCell.self)
    
    private var gameData: Game?
    
    lazy private var teamLabel: UILabel = createStandardLabel()
    lazy private var diffLabel: UILabel = createStandardLabel()
    lazy private var playerNames: [UILabel] = createPlayerLabels()
    lazy private var playerChars: [UILabel] = createPlayerLabels()
    lazy private var playerNamesStackView: UIStackView = createPlayerNamesStackView()
    lazy private var playerCharactersStackView: UIStackView = createPlayerCharactersStackView()
    lazy private var leftStackView: UIStackView = createLeftStackView()
    lazy private var rightStackView: UIStackView = createRightStackView()
    lazy private var overallStackView: UIStackView = createOverallStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(forGame game: Game) {
        self.gameData = game
        reloadPlayerLabels()
        
        self.teamLabel.text = game.teamName
        self.diffLabel.text = game.difficulty
        
        let players: [Player] = game.playersAsArray()
        for i in 0..<Int(game.numberOfPlayers) {
            playerNames[i].text = players[i].name
            playerChars[i].text = players[i].character
        }
    }
    
    override func prepareForReuse() {
        self.teamLabel.text = ""
        self.diffLabel.text = ""
        self.playerChars.removeAll()
        self.playerNames.removeAll()
        
        // Empty the subviews in the stackviews.
        self.playerNamesStackView.subviews.forEach({ $0.removeFromSuperview() })
        self.playerCharactersStackView.subviews.forEach({ $0.removeFromSuperview() })
        self.leftStackView.subviews.forEach({ $0.removeFromSuperview() })
        self.rightStackView.subviews.forEach({ $0.removeFromSuperview() })
        self.overallStackView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    private func reloadPlayerLabels() {
        self.playerNames.removeAll()
        self.playerChars.removeAll()
        
        self.playerNames = createPlayerLabels()
        self.playerChars = createPlayerLabels()
        
        self.initializeViews()
    }
}

extension GameOverviewTableViewCell {
    private func initializeViews() {
        for label in self.playerNames {
            playerNamesStackView.addArrangedSubview(label)
        }
        leftStackView.addArrangedSubview(teamLabel)
        leftStackView.addArrangedSubview(playerNamesStackView)
        
        for label in self.playerChars {
            playerCharactersStackView.addArrangedSubview(label)
        }
        rightStackView.addArrangedSubview(diffLabel)
        rightStackView.addArrangedSubview(playerCharactersStackView)
        
        overallStackView.addArrangedSubview(leftStackView)
        overallStackView.addArrangedSubview(rightStackView)
        
        self.contentView.addSubview(overallStackView)
        
        let guide = self.contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            overallStackView.topAnchor.constraint(equalTo: guide.topAnchor),
            overallStackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            overallStackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            overallStackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            // Make the right stack view 40% of the cell for truncating long game team names.
            rightStackView.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.40)
        ])
    }
    
    private func createStandardLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(20)
        return label
    }
    
    private func createPlayerLabels() -> [UILabel] {
        guard let numberOfPlayers = self.gameData?.numberOfPlayers else { return [] }
        var labels: [UILabel] = []
        for _ in 0..<numberOfPlayers {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = label.font.withSize(14)
            labels.append(label)
        }
        return labels
    }
    
    private func createPlayerNamesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.spacing = 3
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private func createPlayerCharactersStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .trailing
        stackView.spacing = 3
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private func createLeftStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.spacing = 7
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    private func createRightStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .trailing
        stackView.spacing = 7
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    private func createOverallStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 1
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
    }
}
