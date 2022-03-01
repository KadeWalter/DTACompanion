//
//  ScoreEntryCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/20/22.
//

import UIKit

protocol ScoreEntryUpdatedDelegate: AnyObject {
    func scoreUpdated(withScore score: Int, cellTag: Int)
}

class ScoreEntryCollectionViewCell: UICollectionViewListCell {
    static let identifier = String(describing: ScoreEntryCollectionViewCell.self)
}

struct ScoreEntryContentConfiguration: UIContentConfiguration {
    var title: String?
    var tag: Int?
    var subtitle: String?
    var value: Int?
    
    weak var scoreUpdatedDelegate: ScoreEntryUpdatedDelegate?
    
    func makeContentView() -> UIView & UIContentView {
        return ScoreEntryContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> ScoreEntryContentConfiguration {
        return self
    }
}


class ScoreEntryContentView: UIView, UIContentView, UITextFieldDelegate {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? ScoreEntryContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: ScoreEntryContentConfiguration!
    
    lazy var titleLabel = createLabel()
    lazy var subtitleLabel = createSubtitleLabel()
    lazy var labelsStackView = createLabelsStackView()
    lazy var textField = createTextField()
    
    init(config: ScoreEntryContentConfiguration) {
        super.init(frame: .zero)
        apply(configuration: config)
        self.initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 5
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let score = Int(text) else { return }
        currentConfig.scoreUpdatedDelegate?.scoreUpdated(withScore: score, cellTag: currentConfig.tag!)
    }
    
    private func apply(configuration: ScoreEntryContentConfiguration) {
        currentConfig = configuration
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        
        if let value = configuration.value {
            textField.text = String(describing: value)
        } else {
            textField.text = ""
        }
    }
    
    private func initializeViews() {
        
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        addSubview(labelsStackView)
        addSubview(textField)
        
        preservesSuperviewLayoutMargins = true
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([
            // Top and Bottom anchor constraints.
            labelsStackView.topAnchor.constraint(equalTo: guide.topAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            textField.topAnchor.constraint(equalTo: guide.topAnchor),
            textField.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            // Leading and Trailing anchor constraints.
            labelsStackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            // Give 5 spacing between the title and text field.
            labelsStackView.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 5),
            // Make the text field 20% the width of the cell.
            textField.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.20)
        ])
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createTextField() -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.keyboardType = .numberPad
        tf.placeholder = "0"
        tf.textAlignment = .right
        tf.delegate = self
        return tf
    }
    
    private func createLabelsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    private func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = label.font.withSize(10)
        return label
    }
}
