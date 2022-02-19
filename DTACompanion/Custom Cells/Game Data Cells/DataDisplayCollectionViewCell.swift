//
//  DataDisplayCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/19/22.
//

import UIKit

class DataDisplayCollectionViewCell: UICollectionViewListCell {
    static let identifier = String(describing: TextEntryCollectionViewCell.self)
}

struct DataDisplayContentConfiguration: UIContentConfiguration, Equatable {
    var title: String?
    var value: String?

    func makeContentView() -> UIView & UIContentView {
        return DataDisplayContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> DataDisplayContentConfiguration {
        return self
    }
    
    static func == (lhs: DataDisplayContentConfiguration, rhs: DataDisplayContentConfiguration) -> Bool {
        return lhs.title == rhs.title && lhs.value == rhs.value
    }
}

class DataDisplayContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? DataDisplayContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: DataDisplayContentConfiguration!
    
    private lazy var titleLabel = createTitleLabel()
    private lazy var valueLabel = createValueLabel()
    
    init(config: DataDisplayContentConfiguration) {
        super.init(frame: .zero)
        self.initializeViews()
        apply(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func apply(configuration: DataDisplayContentConfiguration) {
            guard currentConfig != configuration else { return }
            
            currentConfig = configuration
            titleLabel.text = configuration.title ?? ""
            valueLabel.text = configuration.value ?? ""
    }
    
    private func initializeViews() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        preservesSuperviewLayoutMargins = true
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([
            // Top/Bottom constraints for the labels.
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            valueLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            // Value trailing is cell trailing.
            valueLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            // Title leading is cell leading.
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            // Value label has a max width of 45% of the cell.
            valueLabel.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.45),
            // Align the titles trailing to the values leading.
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor)
        ])
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }
    
    private func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }
}
