//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import GameKit

public typealias SwipeDir = UISwipeGestureRecognizerDirection

final class ViewController: UIViewController, GKGameCenterControllerDelegate {
    
    
    /// Manages the whole game.
    private var game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Setup the Game Center ready for posting leaderboard scores.
        LeaderboardManager.shared.set(presentingViewController: self)
        
        
    }
    
    
    private func setupGestureRecognisers() {
        // setup the tap recogniser
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.gestureTapped(tapGestureRecogniser:)))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        // setup the swipe recogniser
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.gestureSwiped(swipeGestureRecognser:)))
        self.view.addGestureRecognizer(swipe)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func gestureTapped(tapGestureRecogniser: UITapGestureRecognizer) {
        
    }
    
    @objc
    func gestureSwiped(swipeGestureRecognser: UISwipeGestureRecognizer) {
        
        switch swipeGestureRecognser.direction {
        case SwipeDir.right: break
        case SwipeDir.left: break
        case SwipeDir.up: break
        case SwipeDir.down: break
        default:
            fatalError("Invalid swipe direction")
        }
    }
}

