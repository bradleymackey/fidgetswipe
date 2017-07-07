//
//  LeaderboardManager.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation
import UIKit
import GameKit


/// A singleton instance used to handle Game Center authentication and leaderboard management
final internal class LeaderboardManager {
    
    /// The singleton instance
    static let shared = LeaderboardManager()
   
    /// Where the leaderboard and login window should present itself
    private var presentingViewController:UIViewController!
    /// The local player
    private let localPlayer:GKLocalPlayer
    
    
    private init() {
        localPlayer = GKLocalPlayer.localPlayer()
    }
    
    func set(presentingViewController:UIViewController) {
        self.presentingViewController = presentingViewController
    }

    
    func authenticate() {
        localPlayer.authenticateHandler = { [unowned self] (viewController:UIViewController?, error:Error?) in
            // TODO: handle any potential errors
            if let err = error {
                print("Error Authenticating GKLocal Player: \(err.localizedDescription)")
            }
            // get the viewController that we would use for authentication
            guard let vc = viewController else {
                print(GKLocalPlayer.localPlayer().isAuthenticated)
                return
            }
            // present the authentication view controller
            self.presentingViewController.present(vc, animated: true, completion: nil)
        }
    }
    
    func showLeaderboard() {
        let leaderboardViewController = GKGameCenterViewController()
        leaderboardViewController.delegate = presentingViewController as? UINavigationControllerDelegate
        leaderboardViewController.viewState = .leaderboards
        leaderboardViewController.leaderboardIdentifier = "score_leaderboard"
        
        presentingViewController.show(leaderboardViewController, sender: presentingViewController)
        presentingViewController.navigationController?.pushViewController(leaderboardViewController, animated: true)
    }
    
    
    
}
