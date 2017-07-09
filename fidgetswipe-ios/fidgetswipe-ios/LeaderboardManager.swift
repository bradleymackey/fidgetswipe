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
public final class LeaderboardManager {
    
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
        
        Analytics.logEvent("show_leaderboard", parameters: nil)
        
        let leaderboardViewController = GKGameCenterViewController()
        leaderboardViewController.gameCenterDelegate = presentingViewController as? GKGameCenterControllerDelegate
        leaderboardViewController.viewState = .leaderboards
        leaderboardViewController.leaderboardIdentifier = LeaderboardManager.leaderboardID
		
		presentingViewController.present(leaderboardViewController, animated: true, completion: nil)
    }
	
	/// Will submit and save score only if it is a highscore
    public func submit(score scoreVal:UInt) {
		// bail if score is not a highscore
		if scoreVal < deviceHighscore { return }
		// set the local highscore
        deviceHighscore = scoreVal
		// submit highscore to game center
        let score = GKScore(leaderboardIdentifier: LeaderboardManager.leaderboardID)
        score.value = Int64(scoreVal)
        GKScore.report([score]) { [scoreVal] (error) in
            if let err = error {
                Analytics.logEvent("error_report_score", parameters: ["score":scoreVal])
                print("error reporting score to leaderboard: \(err.localizedDescription)")
            } else {
                Analytics.logEvent("report_score", parameters: ["score":scoreVal])
            }
        }
    }
    
    public var deviceHighscore:UInt {
        get {
            let defaults = UserDefaults.standard
            let scoreToCheck = defaults.integer(forKey: "hs")
            let scoreAsString = "\(scoreToCheck)h3A!g2J$W*1VNPIRzFqB*DhJ4#M&N7BWciSDAofEcj$wL9UVa"
            guard let scorePreviousHash = defaults.string(forKey: "hsh") else {
                return 0
            }
            if scoreAsString.MD5 == scorePreviousHash {
                return UInt(scoreToCheck)
            } else {
                return 0
            }
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "hs")
            let toHash = "\(newValue)h3A!g2J$W*1VNPIRzFqB*DhJ4#M&N7BWciSDAofEcj$wL9UVa"
            defaults.set(toHash.MD5, forKey: "hsh")
        }
    }
    
}
