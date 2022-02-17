//
//  TextEntryCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/10/22.
//

import UIKit

protocol TextEntryCellUpdatedDelegate: AnyObject {
    func textUpdated(withText text: String, cellTag: Int, parentId: Int?)
}

class TextEntryCollectionViewCell: UICollectionViewListCell, UITextFieldDelegate {
    static let identifier = String(describing: TextEntryCollectionViewCell.self)
}

struct TextEntryContentConfiguration: UIContentConfiguration, Equatable {
    var title: String?
    var tag: Int?
    var textValue: String?
    var parentId: Int?
    var isSelectable: Bool = true
    weak var textChangedDelegate: TextEntryCellUpdatedDelegate?
    
    func makeContentView() -> UIView & UIContentView {
        return TextEntryContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> TextEntryContentConfiguration {
        return self
    }
    
    static func == (lhs: TextEntryContentConfiguration, rhs: TextEntryContentConfiguration) -> Bool {
        return lhs.textValue == rhs.textValue && lhs.parentId == rhs.parentId && lhs.tag == rhs.tag && lhs.title == rhs.title
    }
}


class TextEntryContentView: UIView, UIContentView, UITextFieldDelegate {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? TextEntryContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: TextEntryContentConfiguration!
    
    lazy var titleLabel = createLabel()
    lazy var textField = createTextField()
    weak var textUpdatedDelegate: TextEntryCellUpdatedDelegate?
    
    init(config: TextEntryContentConfiguration) {
        super.init(frame: .zero)
        self.initializeViews()
        apply(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var text = textField.text else { return }
        text = text.replacingOccurrences(of: "\u{00a0}", with: " ")
        currentConfig.textChangedDelegate?.textUpdated(withText: text, cellTag: currentConfig.tag ?? 0, parentId: currentConfig.parentId)
    }
    
    private func apply(configuration: TextEntryContentConfiguration) {
        guard currentConfig != configuration else { return }
        
        currentConfig = configuration
        titleLabel.text = configuration.title
        textField.text = configuration.textValue
        textField.isUserInteractionEnabled = currentConfig.isSelectable
    }
    
    private func initializeViews() {
        addSubview(titleLabel)
        addSubview(textField)
        
        preservesSuperviewLayoutMargins = true
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([
            // Top and Bottom anchor constraints.
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            textField.topAnchor.constraint(equalTo: guide.topAnchor),
            textField.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            // Leading and Trailing anchor constraints.
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            // Give 5 spacing between the title and text field.
            titleLabel.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 5),
            // Make the text field 45% the width of the cell.
            textField.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.45)
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
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.borderStyle = .none
        tf.placeholder = "required"
        tf.textAlignment = .left
        tf.delegate = self
        return tf
    }
}
