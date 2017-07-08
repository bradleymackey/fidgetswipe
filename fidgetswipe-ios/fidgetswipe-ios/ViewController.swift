//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import GameKit
import FirebaseAnalytics

public typealias SwipeDirection = UISwipeGestureRecognizerDirection

final class ViewController: UIViewController, GKGameCenterControllerDelegate {
    
    /// Manages the whole game.
    private var game = Game()
    private var currentTurn:TurnData!
    
    private lazy var actionImageView:UIImageView = {
        let imageView = UIImageView(frame: .zero)
        let thirdWidth:CGFloat = self.view.frame.width/3
        let halfWidth:CGFloat = self.view.frame.width/2
        imageView.frame.size = CGSize(width: thirdWidth, height: thirdWidth)
        imageView.center = CGPoint(x: halfWidth, y: thirdWidth)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var promptLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        let thirdWidth:CGFloat = self.view.frame.width/3
        let halfWidth:CGFloat = self.view.frame.width/2
        label.center = CGPoint(x: halfWidth, y: thirdWidth+(thirdWidth/2)+10)
        return label
    }()
    
    private lazy var scoreLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 60)
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
        label.center = self.view.center
        label.textAlignment = .center
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background colour
        self.view.backgroundColor = .black
        
        // setup gestures
        setupGestureRecognisers()
       
        // Setup the Game Center ready for posting leaderboard scores.
        LeaderboardManager.shared.set(presentingViewController: self)
        
        // Add the views for the game
        self.view.addSubview(actionImageView)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(promptLabel)
        
        // setup the game
        progressGame(previousTurnValid: true)
    }
    

    
    private func setupGestureRecognisers() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.gestureTapped(tapGestureRecogniser:)))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.gestureSwiped(swipeGestureRecognser:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.gestureSwiped(swipeGestureRecognser:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.gestureSwiped(swipeGestureRecognser:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.gestureSwiped(swipeGestureRecognser:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func gestureTapped(tapGestureRecogniser: UITapGestureRecognizer) {
        Analytics.logEvent("tap", parameters: nil)
        progressGame(previousTurnValid: game.take(move: .tap))
    }

    
    @objc
    func gestureSwiped(swipeGestureRecognser: UISwipeGestureRecognizer) {
        
        switch swipeGestureRecognser.direction {
        case SwipeDirection.right:
            Analytics.logEvent("swipe_right", parameters: nil)
            progressGame(previousTurnValid: game.take(move: .swipeRight))
        case SwipeDirection.left:
            Analytics.logEvent("swipe_left", parameters: nil)
            progressGame(previousTurnValid: game.take(move: .swipeLeft))
        case SwipeDirection.up:
            Analytics.logEvent("swipe_up", parameters: nil)
            progressGame(previousTurnValid: game.take(move: .swipeUp))
        case SwipeDirection.down:
            Analytics.logEvent("swipe_down", parameters: nil)
            progressGame(previousTurnValid: game.take(move: .swipeDown))
        default:
            fatalError("Invalid swipe direction")
        }
    }
    
    private func progressGame(previousTurnValid: Bool) {
        
        if previousTurnValid {
            // go to next game
            prepareNextTurn()
        } else {
            endGame()
        }
    }
    
    private func prepareNextTurn() {
        currentTurn = game.getNextMove()
        UIView.transition(with: actionImageView, duration: 0.1, options: [.transitionCurlDown], animations: { [currentTurn] in
            guard let turn = currentTurn else { fatalError("No turn found in animation block for image.") }
            self.actionImageView.image = turn.image
        }, completion: nil)
        UIView.transition(with: promptLabel, duration: 0.05, options: [.transitionCrossDissolve], animations: { [currentTurn] in
            guard let turn = currentTurn else { fatalError("No turn found in animation block for prompt label.") }
            let prevCenter = self.promptLabel.center
            self.promptLabel.text = turn.action == .tap ? "TAP" : "SWIPE"
            self.promptLabel.sizeToFit()
            self.promptLabel.center = prevCenter
        }, completion: nil)
        UIView.transition(with: scoreLabel, duration: 0.05, options: [.transitionCrossDissolve], animations: { [currentTurn] in
            guard let turn = currentTurn else { fatalError("No turn found in animation block for score label.") }
            self.scoreLabel.text = "\(turn.newScore)"
            let prevCenter = self.scoreLabel.center
            self.scoreLabel.sizeToFit()
            self.scoreLabel.center = prevCenter
        }, completion: nil)
    }
    
    private func endGame() {
        LeaderboardManager.shared.submit(score: currentTurn.newScore)
        prepareNextTurn()
        // TODO: show leaderboard button
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

