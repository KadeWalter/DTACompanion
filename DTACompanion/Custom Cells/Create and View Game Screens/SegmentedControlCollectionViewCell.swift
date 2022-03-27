//
//  SegmentedControlCollectionViewCell.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/10/22.
//

import UIKit

protocol SegmentedControlCellUpdatedDelegate: AnyObject {
    func segmentedControlIndexChanged(itemAtIndex item: String, cellTag: Int)
}

class SegmentedControlCollectionViewCell: UICollectionViewListCell {
    static let identifier = String(describing: SegmentedControlCollectionViewCell.self)
}

struct SegmentedControlContentConfiguration: UIContentConfiguration, Equatable {
    var title: String?
    var items: [String]?
    var tag: Int?
    var selectedIndex: Int?
    weak var segmentedControlUpdateDelegate: SegmentedControlCellUpdatedDelegate?
    
    func makeContentView() -> UIView & UIContentView {
        return SegmentedControlContentView(config: self)
    }
    
    func updated(for state: UIConfigurationState) -> SegmentedControlContentConfiguration {
        return self
    }
    
    static func == (lhs: SegmentedControlContentConfiguration, rhs: SegmentedControlContentConfiguration) -> Bool {
        return lhs.title == rhs.title && lhs.selectedIndex == rhs.selectedIndex && lhs.items == rhs.items
    }
}

class SegmentedControlContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        get {
            currentConfig
        }
        set {
            guard let newConfig = newValue as? SegmentedControlContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    private var currentConfig: SegmentedControlContentConfiguration!
    
    lazy var titleLabel = createLabel()
    lazy var segmentedControl = createSegmentedControl()
    
    init(config: SegmentedControlContentConfiguration) {
        super.init(frame: .zero)
        self.initializeViews()
        apply(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        currentConfig.segmentedControlUpdateDelegate?.segmentedControlIndexChanged(itemAtIndex: currentConfig.items?[index] ?? "", cellTag: currentConfig.tag ?? 0)
    }
    
    private func apply(configuration: SegmentedControlContentConfiguration) {
        guard currentConfig != configuration else { return }
        
        currentConfig = configuration
        titleLabel.text = configuration.title
        
        segmentedControl.removeAllSegments()
        for item in (configuration.items ?? []).reversed() {
            segmentedControl.insertSegment(withTitle: item, at: 0, animated: false)
        }
        if let selectedIndex = configuration.selectedIndex {
            segmentedControl.selectedSegmentIndex = selectedIndex
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    
    private func initializeViews() {
        addSubview(titleLabel)
        addSubview(segmentedControl)
        
        preservesSuperviewLayoutMargins = true
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([
            // Top and Bottom anchor constraints.
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            segmentedControl.topAnchor.constraint(equalTo: guide.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            // Leading and Trailing anchor constraints.
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 5),
            // Give 5 spacing between the title and text field.
            titleLabel.trailingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: 5),
            // Make the text field 47% the width of the cell. -> 47% makes it line up with the textfield better.
            segmentedControl.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.47)
        ])
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createSegmentedControl() -> UISegmentedControl {
        let seg = UISegmentedControl()
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return seg
    }
}
