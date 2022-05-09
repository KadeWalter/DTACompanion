//
//  UITextFieldExtension.swift
//  DTACompanion
//
//  Created by Kade Walter on 5/9/22.
//

import UIKit

extension UITextField {
    func addDoneToToolBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 35))
        toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        toolbar.tintColor = .systemBlue
        toolbar.items = [space, doneButton]
        self.inputAccessoryView = toolbar
    }
}
