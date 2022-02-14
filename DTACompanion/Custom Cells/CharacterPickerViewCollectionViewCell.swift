//
//  CharacterPickerViewCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/11/22.
//

import UIKit

protocol CharacterSelectedDelegate: AnyObject {
    func updateSelectedCharacter(withCharacter character: String, indexPath: IndexPath)
}

class CharacterPickerViewCollectionViewCell: UICollectionViewListCell {
    static let identifier = String(describing: self)
}

struct CharacterPickerViewContentConfiguration: UIContentConfiguration, Equatable {
    var indexPath: IndexPath?
    var currentSelection: String?
    weak var delegate: CharacterSelectedDelegate?
    
    func makeContentView() -> UIView & UIContentView {
        return CharacterPickerViewContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> CharacterPickerViewContentConfiguration {
        return self
    }
    
    static func == (lhs: CharacterPickerViewContentConfiguration, rhs: CharacterPickerViewContentConfiguration) -> Bool {
        return lhs.indexPath == rhs.indexPath && lhs.currentSelection == rhs.currentSelection
    }
}

class CharacterPickerViewContentView: UIView, UIContentView, UIPickerViewDelegate, UIPickerViewDataSource {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? CharacterPickerViewContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: CharacterPickerViewContentConfiguration!
    
    lazy var pickerView = createPickerView()
    private var characters: [[String]] = []
    private var selectedSeason: Seasons = .seasonOne
    
    init(config: CharacterPickerViewContentConfiguration) {
        super.init(frame: .zero)
        self.initializeViews()
        apply(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func apply(configuration: CharacterPickerViewContentConfiguration) {
        guard currentConfig != configuration else { return }
        
        currentConfig = configuration
        selectedSeason = .seasonOne
        characters = setCharacters()
        if let character = currentConfig.currentSelection {
            let indexPath = self.getCharacterIndex(character: character)
            manuallySelectRow(seasonRow: indexPath.section, charRow: indexPath.row)
        } else {
            manuallySelectRow(seasonRow: 0, charRow: 0)
        }
    }
    
    private func initializeViews() {
        addSubview(pickerView)
        
        preservesSuperviewLayoutMargins = true
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            pickerView.heightAnchor.constraint(equalTo: guide.heightAnchor),
            pickerView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: guide.widthAnchor),
            pickerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        ])
    }
    
    private func createPickerView() -> UIPickerView {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return characters.count
        } else {
            return characters[component].count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return PickerComponents.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Seasons.allCases[row].description()
        } else {
            return characters[selectedSeason.rawValue][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            // Change seasons
            selectedSeason = Seasons.allCases[row]
            pickerView.reloadComponent(PickerComponents.character.rawValue)
            manuallySelectFirstCharacterRowOnSeasonChange()
        } else {
            // Change characters
            guard let indexPath = currentConfig.indexPath else { return }
            self.currentConfig.delegate?.updateSelectedCharacter(withCharacter: characters[selectedSeason.rawValue][row], indexPath: indexPath)
        }
    }
    
    private func manuallySelectRow(seasonRow: Int, charRow: Int) {
        guard seasonRow < pickerView.numberOfComponents, charRow < pickerView.numberOfRows(inComponent: seasonRow) else { return }
        pickerView.selectRow(seasonRow, inComponent: PickerComponents.season.rawValue, animated: false)
        pickerView(self.pickerView, didSelectRow: seasonRow, inComponent: PickerComponents.season.rawValue)
        pickerView.selectRow(charRow, inComponent: PickerComponents.character.rawValue, animated: false)
        pickerView(self.pickerView, didSelectRow: charRow, inComponent: PickerComponents.character.rawValue)
    }
    
    private func manuallySelectFirstCharacterRowOnSeasonChange() {
        pickerView.selectRow(0, inComponent: PickerComponents.character.rawValue, animated: false)
        pickerView(self.pickerView, didSelectRow: 0, inComponent: PickerComponents.character.rawValue)
    }
    
    private func setCharacters() -> [[String]] {
        var characterMatrix: [[String]] = []
        for season in Seasons.allCases {
            switch season {
            case .seasonOne:
                characterMatrix.append(["Barb", "Shadow Thief"])
            case .seasonTwo:
                characterMatrix.append(["Artificer", "Huntress"])
            }
        }
        return characterMatrix
    }
    
    private func getCharacterIndex(character: String) -> IndexPath {
        for i in 0..<characters.count {
            for x in 0 ..< characters[i].count {
                if characters[i][x] == character {
                    return IndexPath(row: x, section: i)
                }
            }
        }
        return IndexPath(row: 0, section: 0)
    }
    
    enum Seasons: Int, CaseIterable {
        case seasonOne = 0
        case seasonTwo
        
        func description() -> String {
            switch self {
            case .seasonOne:
                return "Season One"
            case .seasonTwo:
                return "Season Two"
            }
        }
    }
    
    enum PickerComponents: Int, CaseIterable {
        case season = 0
        case character
    }
}
