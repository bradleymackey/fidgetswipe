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
    
    public static let nextMoveAnimationTime:TimeInterval = 0.25
    public static let restoreProgressBarAnimationTime:TimeInterval = 0.1
    
    
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
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: 1)
        label.textColor = .lightGray
        let thirdWidth:CGFloat = self.view.frame.width/3
        let halfWidth:CGFloat = self.view.frame.width/2
        label.center = CGPoint(x: halfWidth, y: thirdWidth+(thirdWidth/2)+10)
        return label
    }()
    
    private lazy var scoreLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 53, weight: 1)
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
        label.center = self.view.center
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressBar:UIProgressView = {
        let progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        progress.progressViewStyle = .bar
        progress.setProgress(1, animated:false)
        progress.trackTintColor = .clear
        progress.progressTintColor = .white
        return progress
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
        self.view.addSubview(progressBar)
        
        // setup the game
        progressGame(previousTurnValid: false)
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
        if !previousTurnValid && currentTurn != nil {
            LeaderboardManager.shared.submit(score: currentTurn.newScore)
        }
        
        // get the next turn from the game
        currentTurn = game.getNextMove()
        // animate the colour change of the icon

        let animationDuration:TimeInterval = previousTurnValid ? ViewController.nextMoveAnimationTime : 1
        self.progressBar.layer.removeAllAnimations()
        self.progressBar.progress = 1
        UIView.animate(withDuration: animationDuration, animations: {
            self.actionImageView.tintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
            self.progressBar.layoutIfNeeded()
            self.progressBar.progressTintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
        }) { (_) in
            self.actionImageView.tintColor = .white
            self.progressBar.progressTintColor = .white
            UIView.transition(with: self.actionImageView, duration: ViewController.nextMoveAnimationTime, options: [.transitionFlipFromTop], animations: {
                 self.actionImageView.image = self.currentTurn.image
                self.progressBar.layer.removeAllAnimations()
                
            }, completion: { _ in
                // on the image changing...
                // update the score label
                self.updateScoreLabel()
                // restart the progress bar animation if turn was success, or restore to full if we lost.
                if previousTurnValid {
                    self.startProgressBarAnimating()
                }
            })
            UIView.transition(with: self.promptLabel, duration: ViewController.nextMoveAnimationTime, options: [.transitionCrossDissolve], animations: {
                let prevCenterPrompt = self.promptLabel.center
                self.promptLabel.text = self.currentTurn.action == .tap ? "TAP" : "SWIPE"
                self.promptLabel.sizeToFit()
                self.promptLabel.center = prevCenterPrompt
            }, completion: nil)
        }
        
    }
    
    private func updateScoreLabel() {
        self.scoreLabel.text = "\(self.currentTurn.newScore)"
        let prevCenterScore = self.scoreLabel.center
        self.scoreLabel.sizeToFit()
        self.scoreLabel.center = prevCenterScore
    }
    
    private func startProgressBarAnimating() {
        self.progressBar.layer.removeAllAnimations()
        self.progressBar.progress = 1
        UIView.animate(withDuration: 0, animations: {
            self.progressBar.layoutIfNeeded()
        }, completion: { (success) in
            self.progressBar.progress = 0
            UIView.animate(withDuration: Game.moveTime) {
                self.progressBar.layoutIfNeeded()
            }
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

