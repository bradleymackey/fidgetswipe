//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import GameKit

final class ViewController: UIViewController, GKGameCenterControllerDelegate {
    
    
    /// Manages the whole game.
    private var game = Game()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Setup the Game Center ready for posting leaderboard scores.
        LeaderboardManager.shared.set(presentingViewController: self)
        
        
        /* Game class reference example */
        
        // Get the first turn
        let first = game.nextMove()
        let firstAction = first.action
        let timeAllowedForFirstAction = first.timeAllowed
        let updatedScore = first.newScore
        
        // Take a turn
        let successful = game.take(move: .swipeDown)
        if successful {
            // get the second turn
            let secondTurn = game.nextMove()
        } else {
            // WRONG! the game has ended (you should also report game center score at this point)
            let setupReadyForNextGame = game.nextMove()
        }
        
        // NB: the flow is THE SAME no matter is the go is wrong or right
        // this is because we don't have a 'Play Again' screen, they just start swiping again to keep playing
        
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
        typealias D = UISwipeGestureRecognizerDirection
        switch swipeGestureRecognser.direction {
        case D.right: break
        case D.left: break
        case D.up: break
        case D.down: break
        default:
            fatalError("Invalid swipe direction")
        }
    }
}

