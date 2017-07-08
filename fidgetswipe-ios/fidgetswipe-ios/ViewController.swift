//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import GameKit
import CoreMotion
import FirebaseAnalytics

public typealias SwipeDirection = UISwipeGestureRecognizerDirection

final class ViewController: UIViewController, GKGameCenterControllerDelegate {
    
    // MARK: - Static Properties
    
    public static let greenColor = UIColor(colorLiteralRed: 0x4c/0xff, green: 0xd9/0xff, blue: 0x64/0xff, alpha: 1)
    public static let redColor = UIColor(colorLiteralRed: 0xff/0xff, green: 0x3b/0xff, blue: 0x30/0xff, alpha: 1)
    
    public static let greenFlashAnimationTime:TimeInterval = 0.2
    public static let redFlashAnimationTime:TimeInterval = 0.5
    public static let nextMoveAnimationTime:TimeInterval = 0.25
    public static let restoreProgressBarAnimationTime:TimeInterval = 0.1
    
    
    /// Manages the whole game.
    private var game = Game()
    private var currentTurn:TurnData!
    
    /// Variable so we know when we should accept user input (spam prevention)
    private var acceptInput = true
    
    /// Motion manager to read accelerometer events.
    private var motionManager:CMMotionManager!
    
    private lazy var actionImageView:UIImageView = {
        let imageView = UIImageView(frame: .zero)
        let thirdWidth:CGFloat = self.view.frame.width/3
        imageView.frame.size = CGSize(width: thirdWidth, height: thirdWidth)
        imageView.center = self.view.center
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var promptLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: 1)
        label.textColor = .lightGray
        let thirdWidth:CGFloat = self.view.frame.width/3
        label.center = CGPoint(x: self.view.center.x, y: self.view.center.y+(thirdWidth/2)+10)
        return label
    }()
    
    private lazy var scoreLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 53, weight: 0.8)
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
        let thirdWidth:CGFloat = self.view.frame.width/3
        let halfWidth:CGFloat = self.view.frame.width/2
        label.center = CGPoint(x: halfWidth, y: thirdWidth)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressBar:UIProgressView = {
        let progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)) // height is auto-set
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
        
        // Setup the motion manager
        setupMotionManager()
        
        // Add the views for the game
        self.view.addSubview(actionImageView)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(promptLabel)
        self.view.addSubview(progressBar)
        
        // setup the game
        progressGame(previousTurnValid: false)
        
    }
    
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        
        if !motionManager.isAccelerometerAvailable {
            Analytics.logEvent("accelerometer_not_ava", parameters: nil)
            print("Accelerometer not avaiable, motion challenges are disabled.")
            game.disableMotionChallenges()
            return
        }
            
        Analytics.logEvent("accelerometer_ava", parameters: nil)
        motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { (accelerometerData, error) in
            if let err = error {
                print("Accelerometer update error: \(err.localizedDescription)")
            } else if let accData = accelerometerData {
                print("accel: x:\(accData.acceleration.x) y:\(accData.acceleration.y) z:\(accData.acceleration.z)")
            }
        })

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
        if !acceptInput { return }
        Analytics.logEvent("tap", parameters: nil)
        progressGame(previousTurnValid: game.take(move: .tap))
    }

    
    @objc
    func gestureSwiped(swipeGestureRecognser: UISwipeGestureRecognizer) {
        if !acceptInput { return }
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
    
    /// Progress the state of the game to the next turn.
    private func progressGame(previousTurnValid: Bool) {
        
        // prevent spamming
        acceptInput = false
        
        // submit score if the game is over
        if !previousTurnValid && currentTurn != nil {
            LeaderboardManager.shared.submit(score: currentTurn.newScore)
        }
        
        // get the next turn from the game
        currentTurn = game.getNextMove()
        // animate the colour change of the icon

        let animationDuration:TimeInterval = previousTurnValid ? ViewController.greenFlashAnimationTime : ViewController.redFlashAnimationTime
        self.progressBar.layer.removeAllAnimations()
        self.progressBar.progress = 1
        UIView.animate(withDuration: animationDuration, animations: {
            self.actionImageView.tintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
            self.progressBar.layoutIfNeeded()
            self.progressBar.progressTintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
        }) { (_) in
            self.updateScoreLabel()
            self.actionImageView.tintColor = .white
            self.progressBar.progressTintColor = .white
            UIView.transition(with: self.actionImageView, duration: ViewController.nextMoveAnimationTime, options: [.transitionFlipFromTop], animations: {
                 self.actionImageView.image = self.currentTurn.image
            }, completion: { _ in
                // on the image changing...
                // accept input again
                self.acceptInput = true
                // restart the progress bar animation if turn was success
                if previousTurnValid {
                    self.startProgressBarAnimating()
                }
            })
            UIView.transition(with: self.promptLabel, duration: ViewController.nextMoveAnimationTime, options: [.transitionCrossDissolve], animations: {
                let prevCenterPrompt = self.promptLabel.center
                self.promptLabel.text = self.currentTurn.action.description
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
        // force the progress to be 1 before we start if it is not already at 1
        self.progressBar.progress = 1
        self.progressBar.layoutIfNeeded()
        self.progressBar.progress = 0
        UIView.animate(withDuration: currentTurn.timeForMove) {
            self.progressBar.layoutIfNeeded()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

