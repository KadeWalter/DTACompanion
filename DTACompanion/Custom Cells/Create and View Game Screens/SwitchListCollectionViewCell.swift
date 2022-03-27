//
//  SwitchListCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/14/22.
//

import UIKit

protocol SwitchListCellUpdatedDelegate: AnyObject {
    func switchToggled(switchIsOn: Bool)
}

class SwitchListCollectionViewCell: UICollectionViewListCell {
    static let identifier = String(describing: SwitchListCollectionViewCell.self)
}

struct SwitchListContentConfiguration: UIContentConfiguration, Equatable {
    var title: String?
    var switchIsOn: Bool?
    weak var switchListCellUpdatedDelegate: SwitchListCellUpdatedDelegate?
    
    func makeContentView() -> UIView & UIContentView {
        return SwitchListContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> SwitchListContentConfiguration {
        return self
    }
    
    static func == (lhs: SwitchListContentConfiguration, rhs: SwitchListContentConfiguration) -> Bool {
        return lhs.title == rhs.title && lhs.switchIsOn == rhs.switchIsOn
    }
}

class SwitchListContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? SwitchListContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: SwitchListContentConfiguration!
    
    lazy var titleLabel = createLabel()
    lazy var cellSwitch = createCellSwitch()
    
    init(config: SwitchListContentConfiguration) {
        super.init(frame: .zero)
        self.initializeViews()
        apply(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchToggled(_ sender: Any) {
        guard let isOn = (sender as? UISwitch)?.isOn else { return }
        currentConfig.switchListCellUpdatedDelegate?.switchToggled(switchIsOn: isOn)
    }
    
    private func apply(configuration: SwitchListContentConfiguration) {
        guard currentConfig != configuration else { return }
        
        currentConfig = configuration
        titleLabel.text = configuration.title
        cellSwitch.isOn = configuration.switchIsOn ?? false
    }
    
    private func initializeViews() {
        addSubview(titleLabel)
        addSubview(cellSwitch)
        
        preservesSuperviewLayoutMargins = true
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([
            // Top and Bottom anchor constraints.
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            cellSwitch.topAnchor.constraint(equalTo: guide.topAnchor),
            cellSwitch.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            // Leading and Trailing anchor constraints.
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            cellSwitch.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 5),
            // Give 5 spacing between the title and text field.
            titleLabel.trailingAnchor.constraint(equalTo: cellSwitch.leadingAnchor, constant: 5)
        ])
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createCellSwitch() -> UISwitch {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.addTarget(self, action: #selector(switchToggled(_:)), for: .touchUpInside)
        return sw
    }
}
