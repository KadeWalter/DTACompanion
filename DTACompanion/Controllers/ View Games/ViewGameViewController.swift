//
//  ViewGameViewController.swift
//  DTACompanion
//
//  Created by Kade Walter on 2/18/22.
//

import UIKit

class ViewGameViewController: UIViewController {
    
    private var game: Game

    init(withGame game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
