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
    
    public static let greenColor = UIColor(colorLiteralRed: 0x4c/0xff, green: 0xd9/0xff, blue: 0x64/0xff, alpha: 1)
    public static let redColor = UIColor(colorLiteralRed: 0xff/0xff, green: 0x3b/0xff, blue: 0x30/0xff, alpha: 1)
    
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
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var promptLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .lightGray
        let thirdWidth:CGFloat = self.view.frame.width/3
        let halfWidth:CGFloat = self.view.frame.width/2
        label.center = CGPoint(x: halfWidth, y: thirdWidth+(thirdWidth/2)+10)
        return label
    }()
    
    private lazy var scoreLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 55)
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
        
        // submit score if the game is over
        if !previousTurnValid {
            LeaderboardManager.shared.submit(score: currentTurn.newScore)
        }
        
        // get the next turn from the game
        currentTurn = game.getNextMove()
        // animate the colour change of the icon
        let animationDuration:TimeInterval = previousTurnValid ? 0.25 : 1
        UIView.animate(withDuration: animationDuration, animations: {
            self.actionImageView.tintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
        }) { (_) in
            self.actionImageView.tintColor = .white
            UIView.transition(with: self.actionImageView, duration: 0.25, options: [.transitionFlipFromTop], animations: {
                 self.actionImageView.image = self.currentTurn.image
            }, completion: nil)
            UIView.transition(with: self.promptLabel, duration: 0.25, options: [.transitionCrossDissolve], animations: { 
                let prevCenterPrompt = self.promptLabel.center
                self.promptLabel.text = self.currentTurn.action == .tap ? "TAP" : "SWIPE"
                self.promptLabel.sizeToFit()
                self.promptLabel.center = prevCenterPrompt
            }, completion: nil)
            UIView.transition(with: self.scoreLabel, duration: 0.25, options: [.transitionCrossDissolve], animations: { 
                self.scoreLabel.text = "\(self.currentTurn.newScore)"
                let prevCenterScore = self.scoreLabel.center
                self.scoreLabel.sizeToFit()
                self.scoreLabel.center = prevCenterScore
            }, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

