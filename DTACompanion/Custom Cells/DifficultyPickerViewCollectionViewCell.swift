//
//  DifficultyPickerViewCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/13/22.
//

import UIKit

protocol DifficultySelectedDelegate: AnyObject {
    func updateSelectedDifficulty(withDifficulty difficulty: String, indexPath: IndexPath)
}

class DifficultyPickerViewCollectionViewCell: UICollectionViewListCell {
    static let identifier = String(describing: self)
}

struct DifficultyPickerViewContentConfiguration: UIContentConfiguration, Equatable {
    var indexPath: IndexPath?
    var currentSelection: String?
    var legacyMode: Bool?
    weak var delegate: DifficultySelectedDelegate?
    
    func makeContentView() -> UIView & UIContentView {
        return DifficultyPickerViewContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> DifficultyPickerViewContentConfiguration {
        return self
    }
    
    static func == (lhs: DifficultyPickerViewContentConfiguration, rhs: DifficultyPickerViewContentConfiguration) -> Bool {
        return lhs.indexPath == rhs.indexPath && lhs.currentSelection == rhs.currentSelection && lhs.legacyMode == rhs.legacyMode
    }
}

class DifficultyPickerViewContentView: UIView, UIContentView, UIPickerViewDelegate, UIPickerViewDataSource {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? DifficultyPickerViewContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: DifficultyPickerViewContentConfiguration!
    
    lazy var pickerView = createPickerView()
    private var difficulties: [String] = []
    private var legacyEnabled: Bool?
    
    init(config: DifficultyPickerViewContentConfiguration) {
        super.init(frame: .zero)
        self.initializeViews()
        apply(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func apply(configuration: DifficultyPickerViewContentConfiguration) {
        guard currentConfig != configuration else { return }
        
        currentConfig = configuration
        legacyEnabled = currentConfig.legacyMode
        difficulties = setDifficulties()
        self.pickerView.reloadComponent(0)
        
        if let diff = currentConfig.currentSelection {
            var index = self.getDiffIndex(difficulty: diff)
            index = index < pickerView(self.pickerView, numberOfRowsInComponent: 0) ? index : 0
            manuallySelectRow(row: index)
        } else {
            manuallySelectRow(row: 0)
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
        return difficulties.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return difficulties[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let indexPath = self.currentConfig.indexPath else { return }
        self.currentConfig.delegate?.updateSelectedDifficulty(withDifficulty: difficulties[row], indexPath: indexPath)
    }
    
    private func manuallySelectRow(row: Int) {
        guard row < pickerView.numberOfRows(inComponent: 0) else { return }
        pickerView.selectRow(row, inComponent: 0, animated: false)
        pickerView(self.pickerView, didSelectRow: row, inComponent: 0)
    }
    
    private func setDifficulties() -> [String] {
        var diffs = ["Normal", "Veteran"]
        if self.legacyEnabled ?? false {
            diffs.append("Hardcore")
            diffs.append("Insane")
        }
        return diffs
    }
    
    private func getDiffIndex(difficulty: String) -> Int {
        for i in 0..<difficulties.count {
            if difficulties[i] == difficulty { return i }
        }
        return 0
    }
}
