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
import Firebase


/// A singleton instance used to handle Game Center authentication and leaderboard management
final internal class LeaderboardManager {
    
    /// The singleton instance
    public static let shared = LeaderboardManager()
    
    /// The leaderboard id
    public static let leaderboardID = "score_leaderboard"
    
    
    /// Where the leaderboard and login window should present itself
    private var presentingViewController:UIViewController!
    /// The local player
    private let localPlayer:GKLocalPlayer
    
    /// Use this to know whether or not we can display the leaderboard
    public var localPlayerAuthenticated: Bool {
        return GKLocalPlayer.localPlayer().isAuthenticated
    }
    
    private init() {
        localPlayer = GKLocalPlayer.localPlayer()
        self.setAuthenticateHandler()
    }
    
    public func set(presentingViewController:UIViewController) {
        self.presentingViewController = presentingViewController
    }

    
    private func setAuthenticateHandler() {
        localPlayer.authenticateHandler = { [unowned self] (viewController:UIViewController?, error:Error?) in
            // TODO: handle any potential errors
            if let err = error {
                print("Error Authenticating GKLocal Player: \(err.localizedDescription)")
                Analytics.logEvent("error_auth_gc", parameters: nil)
            }
            // get the viewController that we would use for authentication
            guard let vc = viewController else {
                print("GKLocalPlayer is authenticated: \(GKLocalPlayer.localPlayer().isAuthenticated)")
                Analytics.logEvent("auth_gc", parameters: nil)
                return
            }
            // present the authentication view controller
            self.presentingViewController.present(vc, animated: true, completion: nil)
        }
    }
    
    public func showLeaderboard() {
        let leaderboardViewController = GKGameCenterViewController()
        leaderboardViewController.delegate = presentingViewController as? UINavigationControllerDelegate
        leaderboardViewController.viewState = .leaderboards
        leaderboardViewController.leaderboardIdentifier = LeaderboardManager.leaderboardID
        
        presentingViewController.show(leaderboardViewController, sender: presentingViewController)
        presentingViewController.navigationController?.pushViewController(leaderboardViewController, animated: true)
    }
    
    public func submit(score scoreVal:UInt) {
        let score = GKScore(leaderboardIdentifier: LeaderboardManager.leaderboardID)
        score.value = Int64(scoreVal)
        GKScore.report([score]) { [scoreVal] (error) in
            if let err = error {
                Analytics.logEvent("error_report_score", parameters: nil)
                print("error reporting score to leaderboard: \(err.localizedDescription)")
            } else {
                Analytics.logEvent("submitted_score", parameters: ["score":scoreVal])
            }
        }
    }
    
    
}
