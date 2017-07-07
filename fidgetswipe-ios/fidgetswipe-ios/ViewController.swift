//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupLeaderboardManager()
    }

    private func setupLeaderboardManager() {
        LeaderboardManager.shared.set(presentingViewController: self)
        LeaderboardManager.shared.authenticate()
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

}

