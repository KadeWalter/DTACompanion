//
//  UINavigationControllerExtension.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/15/22.
//

import Foundation
import UIKit

extension UINavigationController {
    func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default)
            alert.addAction(okay)
            self.present(alert, animated: true)
            return
        }
    }
}
