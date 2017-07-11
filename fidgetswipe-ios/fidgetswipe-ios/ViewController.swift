//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import CoreMotion
import MediaPlayer
import GameKit
import FirebaseAnalytics
import FBAudienceNetwork

public typealias SwipeDirection = UISwipeGestureRecognizerDirection

public final class ViewController: UIViewController, GKGameCenterControllerDelegate, FBAdViewDelegate {
    
    // MARK: - Static Properties
    
    // MARK: Colours
    public static let greenColor = UIColor(colorLiteralRed: 0x4c/0xff, green: 0xd9/0xff, blue: 0x64/0xff, alpha: 1)
    public static let redColor = UIColor(colorLiteralRed: 0xff/0xff, green: 0x3b/0xff, blue: 0x30/0xff, alpha: 1)
    
    // MARK: Animation Times
    public static let greenFlashAnimationTime:TimeInterval = 0.2
    public static let redFlashAnimationTime:TimeInterval = 0.5
    public static let nextMoveAnimationTime:TimeInterval = 0.25
    public static let restoreProgressBarAnimationTime:TimeInterval = 0.1
	
	// MARK: - Instance Properties
	
	// MARK: Game Management
    
    /// Manages the whole game.
    private var game = Game()
	
	/// The current turn that we expect from the user.
	/// This is used so we know which challenge this is, so we can do custom ignoring of some events for some challenges.
    private var currentTurn:TurnData!
    
    /// Variable so we know when we should accept user input (spam prevention)
    private var acceptInput = false
    
    /// Motion manager to read accelerometer events.
    private var motionManager = CMMotionManager()
    
    /// The previous level of volume.
    private var previousVolumeLevel:Float = -1 // -1 initially
    
    /// Whether the game has ended or not
    private var gameEnded = false
    
    /// The timer that keeps track of when we have run out of time
    private var turnTimer:Timer?
	
	// MARK: View
	
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
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: 1)
        label.textColor = .lightGray
        let thirdWidth:CGFloat = self.view.frame.width/3
        label.center = CGPoint(x: self.view.center.x, y: self.view.center.y+(thirdWidth/1.8)+20)
        return label
    }()
    
    private lazy var scoreLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 53, weight: 0.8)
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
		let quarterHeight:CGFloat = self.view.frame.height/5
		let halfWidth:CGFloat = self.view.frame.width/2
        label.center = CGPoint(x: halfWidth, y: quarterHeight)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var highscoreLabel:UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: 1)
        label.textColor = UIColor(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        label.text = ""
        label.sizeToFit()
        let quarterHeight:CGFloat = self.view.frame.height/5
        let halfWidth:CGFloat = self.view.frame.width/2
        label.center = CGPoint(x: halfWidth, y: quarterHeight+55)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressBar:UIProgressView = {
        let progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)) // height is auto-set
        progress.progressViewStyle = .bar
        progress.progress = 1
        progress.trackTintColor = .clear
        progress.progressTintColor = .white
        return progress
    }()
	
	private lazy var leaderboardButton: ExtraButton = {
        let button = ExtraButton(imageName: "leader", category: ExtraButton.Category.leaderboard)
		let thirdWidth:CGFloat = self.view.frame.width/3
		let quarterHeight:CGFloat = self.view.frame.height/5
		button.center = CGPoint(x: thirdWidth, y: 4*quarterHeight)
		button.addTarget(self, action: #selector(ViewController.extraButtonPressed(sender:)), for: .touchUpInside)
        button.alpha = 0 // initially hidden
		return button
	}()
	
	private lazy var shareButton: ExtraButton = {
        let button = ExtraButton(imageName: "share", category: ExtraButton.Category.share)
		let thirdWidth:CGFloat = self.view.frame.width/3
		let quarterHeight:CGFloat = self.view.frame.height/5
		button.center = CGPoint(x: 2*thirdWidth, y: 4*quarterHeight)
		button.addTarget(self, action: #selector(ViewController.extraButtonPressed(sender:)), for: .touchUpInside)
        button.alpha = 0 // initially hidden
		return button
	}()
	
	private var adViewAdded = false
	
	private lazy var adView:FBAdView = {
		#if DEBUG
			FBAdSettings.setLogLevel(.log)
			FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
		#endif
		let ad = FBAdView(placementID: AdvertManager.shared.placementID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
		ad.frame = CGRect(x: 0, y: self.view.frame.height-ad.bounds.size.height, width: ad.bounds.size.width, height: ad.bounds.size.height)
		ad.delegate = self
		ad.backgroundColor = .white
		return ad
	}()
	
	// MARK: Configuration
	
	// Become the first responder for shake events.
	override public var canBecomeFirstResponder: Bool {
		return true
	}
	
	// Prefer the status bar hidden.
	override public var prefersStatusBarHidden: Bool {
		return true
	}
	
	// MARK: - Methods
	
	// MARK: Lifecycle
	
    override public func viewDidLoad() {
        super.viewDidLoad()
		
		// add the necessary views to the screen
		addViewsToScreen()
        
        // hide volume indicator
        hideVolumeIndicator()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        // Become the first responder (for shake events).
        self.becomeFirstResponder()
        
        // Set the background colour
        self.view.backgroundColor = .black
        
        // setup gestures
        setupGestureRecognisers()
       
        // Setup the Game Center ready for posting leaderboard scores.
        LeaderboardManager.shared.set(presentingViewController: self)
        
        // if we have no accelerometer avalible, disable the motion challenges for the game.
        disableMotionChallengesIfNeeded()
        
        // setup the game's first action
        progressGame(previousTurnValid: false, isFirstLaunch: true)
		
    }
	
	// MARK: Setup
	
	/// Adds all the extra views/game elements to the view
	private func addViewsToScreen() {
		self.view.addSubview(actionImageView)
		self.view.addSubview(scoreLabel)
		self.view.addSubview(promptLabel)
		self.view.addSubview(progressBar)
		self.view.addSubview(highscoreLabel)
		self.view.addSubview(leaderboardButton)
		self.view.addSubview(shareButton)
		addAdviewToViewIfAllowed()
	}
	
	private func addAdviewToViewIfAllowed() {
		if (AdvertManager.shared.adsEnabled && !adViewAdded) {
			self.view.addSubview(adView)
			adView.loadAd()
		}
	}
	
	/// When called, the system volume indicator will no longer be displayed (given that we have the right AVAudioSessionCategory set).
    /// - note: this a bit 'hacky' but I think it's the only way.
    private func hideVolumeIndicator() {
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.center = CGPoint(x: -150, y: -150) // place it at a point where it will not be visible.
        volumeView.showsRouteButton = false
        volumeView.showsVolumeSlider = true // ensure we take over volume control
        volumeView.isHidden = false
        self.view.addSubview(volumeView)
    }
	
	private func setupGestureRecognisers() {
		
		// TAP
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.gestureTapped(tapGestureRecogniser:)))
		tap.numberOfTapsRequired = 1
		self.view.addGestureRecognizer(tap)
	
		// SWIPE
		
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
	
	/// Creates a motion manager and deactivates accelerometer challenges if we have no accelerometer avaliable.
	private func disableMotionChallengesIfNeeded() {
		// only enable motion challenges if we have an accelerometer accessable.
		if !motionManager.isAccelerometerAvailable {
			Analytics.logEvent("accelerometer_not_ava", parameters: nil)
			print("Accelerometer not avaiable, motion challenges are disabled.")
			game.motionChallengesEnabled = false
			return
		} else {
			Analytics.logEvent("accelerometer_ava", parameters: nil)
		}
	}
	
	// MARK: Interaction Handling


	/// Called when the system volume level has changed.
    @objc private func volumeChanged(notification:Notification) {
        let vol = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        defer { previousVolumeLevel = vol }
        print("volume! \(vol)")
        if !acceptInput { return }
        // previous volume level is initially -1
        if previousVolumeLevel == -1 {
            if currentTurn.action == .volumeUp {
                progressGame(previousTurnValid: game.take(move: .volumeUp))
            } else {
                progressGame(previousTurnValid: game.take(move: .volumeDown))
            }
        }
		// this block called when we know the previous volume level
		else {
            if vol == 0 || vol < previousVolumeLevel {
                progressGame(previousTurnValid: game.take(move: .volumeDown))
            } else {
                progressGame(previousTurnValid: game.take(move: .volumeUp))
            }
        }
     }
	
	@objc func gestureTapped(tapGestureRecogniser: UITapGestureRecognizer) {
		if !acceptInput { return }
		Analytics.logEvent("tap", parameters: nil)
		progressGame(previousTurnValid: game.take(move: .tap))
	}
	
	@objc func gestureSwiped(swipeGestureRecognser: UISwipeGestureRecognizer) {
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
	
	override public func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
		if !acceptInput { return }
		if event?.subtype == UIEventSubtype.motionShake {
			print("Device shake")
			guard let turn = currentTurn else { return }
			if turn.action.isMotionChallenge && turn.action != .shake { return } // ignore shakes if we are currently on a different motion challenge
			Analytics.logEvent("shake", parameters: nil)
			progressGame(previousTurnValid: game.take(move: .shake))
		}
	}
	
	private func handleMotionActionVerification(accelerometerData:CMAccelerometerData, action:Action) {
		// get component values
		let x = accelerometerData.acceleration.x
		let y = accelerometerData.acceleration.y
		let z = accelerometerData.acceleration.z
		// determine current device position
		switch action {
		case .faceDown:
			if x < 0.25 && x > -0.25 && y < 0.25 && y > -0.25 && z < 1.25 && z > 0.75 {
				Analytics.logEvent("face_down", parameters: nil)
				progressGame(previousTurnValid: game.take(move: .faceDown))
			}
		case .faceUp:
			if x < 0.25 && x > -0.25 && y < 0.25 && y > -0.25 && z > -1.25 && z < -0.75 {
				Analytics.logEvent("face_up", parameters: nil)
				progressGame(previousTurnValid: game.take(move: .faceUp))
			}
		case .upsideDown:
			if y > 0.75 && y < 1.25 {
				Analytics.logEvent("upside_down", parameters: nil)
				progressGame(previousTurnValid: game.take(move: .upsideDown))
			}
		default:
			print("[WARN] Attemping to verify device position even though this is not a motion challenge!")
		}
	}
	
	@objc private func extraButtonPressed(sender:UIButton) {
		guard let button = ExtraButton.Category(rawValue: sender.tag) else { fatalError("Invalid button tag trying to be handled!") }
		switch button {
		case .leaderboard:
			LeaderboardManager.shared.showLeaderboard()
		case .share:
			let textToShare = "Now you can fidget on your phone, let's play."
			let urlToShare = URL(string: "https://itunes.apple.com/app/id769938884")!
			let activity = UIActivityViewController(activityItems: [textToShare, urlToShare], applicationActivities: nil)
			activity.excludedActivityTypes = [.print,.postToVimeo]
			self.present(activity, animated: true, completion: nil)
		}
	}
	
	// MARK: Game State / Animations
	
    /// Progress the state of the game to the next turn.
    private func progressGame(previousTurnValid: Bool, isFirstLaunch: Bool = false) {
		
        // prevent spamming
        acceptInput = false
        
        // submit score if the game is over and update size of the score label
        if !previousTurnValid && currentTurn != nil {
            gameEnded = true
            // submit game center score
            LeaderboardManager.shared.submit(score: currentTurn.newScore)
            // make the score label extra big and show highscore label
            updateScoreLabels(forGameEnded: true)
            // show the extra buttons
            changeExtraButtons(forGameEnded: true)
        } else if gameEnded {
            gameEnded = false
            // return the label to a normal size and hide highscore label
            updateScoreLabels(forGameEnded: false)
            // hide the extra buttons
            changeExtraButtons(forGameEnded: false)
        }
        
        // get the next turn from the game
        currentTurn = game.nextMove()
        
        // start listening for accelerometer updates if needed (and stop if this is a motion challenge)
        startAccelerometerUpdates(ifNeededforAction: currentTurn.action)

        // animate to the next turn
        animateActionRecieved(forPreviousTurnValid: previousTurnValid, isFirstLanuch: isFirstLaunch)
		
		// add adverts to the view if we can (we may have gotten a remote config update during the running of the app, so keep on trying).
		addAdviewToViewIfAllowed()
    }
	
	private func startAccelerometerUpdates(ifNeededforAction action:Action) {
		
		// stop acceleromter updates if this is not a motion challenege (not shake! even though it is a motion challenge, iOS allows a different, simpler way to determine if the device has been shaken!)
		if (!action.isMotionChallenge && motionManager.isAccelerometerAvailable) || action == .shake {
			motionManager.stopAccelerometerUpdates()
			return
		}
		
		// *** START ACCELEROMETER UPDATES ***
		// put all the accelerometer data into an operation queue to handle them
		motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
			if !self.acceptInput { return }
			if let err = error {
				print("Accelerometer update error: \(err.localizedDescription)")
			} else if let accData = accelerometerData {
				print("accel: x:\(accData.acceleration.x) y:\(accData.acceleration.y) z:\(accData.acceleration.z)")
				self.handleMotionActionVerification(accelerometerData: accData, action: action)
			}
		}
		
	}
	
	
    /// Animates for when an action is first received, i.e. we colour the icon and time bar either red or green. We then fire off the `displayNextAction` method on completion of this method.
    private func animateActionRecieved(forPreviousTurnValid previousTurnValid:Bool, isFirstLanuch:Bool=false) {
        let animationDuration:TimeInterval = previousTurnValid ? ViewController.greenFlashAnimationTime : ViewController.redFlashAnimationTime
        self.progressBar.layer.removeAllAnimations()
        self.progressBar.progress = 1
        UIView.animate(withDuration: animationDuration, animations: {
            if isFirstLanuch { return } // no colour flash animation if this is the first launch
            self.actionImageView.tintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
            self.progressBar.layoutIfNeeded()
            self.progressBar.progressTintColor = previousTurnValid ? ViewController.greenColor : ViewController.redColor
        }) { (_) in
			// update the score label with the new score
            self.scoreLabel.updateTextMaintainCenter("\(self.currentTurn.newScore)")
			// set tint colours back to white
            self.actionImageView.tintColor = .white
            self.progressBar.progressTintColor = .white
			// animate to the next activity image with a nice animation
            self.displayNextAction(previousTurnValid: previousTurnValid)
        }
    }
	
    /// Displays the next action with a nice animation, then start the timer system to make sure the user does not take too long.
    private func displayNextAction(previousTurnValid:Bool, isFirstLaunch:Bool=false) {
        turnTimer?.invalidate() // invalidate any existing timer
		// if first lanuch, just show image without animation
        if isFirstLaunch {
            self.actionImageView.image = self.currentTurn.image
            self.promptLabel.updateTextMaintainCenter(self.currentTurn.action.description)
        }
        // show next activity image with a nice animation
		UIView.transition(with: self.actionImageView, duration: ViewController.nextMoveAnimationTime, options: [.transitionFlipFromTop], animations: {
            if isFirstLaunch { return }
			self.actionImageView.image = self.currentTurn.image
		}, completion: { _ in
			// on the image changing...
			// accept input again
			self.acceptInput = true
			// restart the progress bar animation if turn was success
			if previousTurnValid {
				self.startProgressBarAnimating()
                self.startCountdownClock()
			}
		})
		// show next prompt label, also with a nice animation
		UIView.transition(with: self.promptLabel, duration: ViewController.nextMoveAnimationTime, options: [.transitionCrossDissolve], animations: {
            if isFirstLaunch { return }
			self.promptLabel.updateTextMaintainCenter(self.currentTurn.action.description)
		}, completion: nil)
	}
	
    /// Starts the progress bar animating to 0 when we are on a new action for a currently executing game.
    private func startProgressBarAnimating() {
        self.progressBar.layer.removeAllAnimations()
        // force the progress to be 1 before we start if it is not already at 1
        self.progressBar.progress = 1
        self.progressBar.layoutIfNeeded()
		// animate the progress bar crawl to 0
        self.progressBar.progress = 0
        UIView.animate(withDuration: currentTurn.timeForMove) {
            self.progressBar.layoutIfNeeded()
        }
    }
    
    /// Starts the timer to know when a turn has ran out of time.
    private func startCountdownClock() {
        turnTimer?.invalidate()
        turnTimer = Timer.scheduledTimer(timeInterval: currentTurn.timeForMove, target: self, selector: #selector(ViewController.timeRanOut), userInfo: nil, repeats: false)
    }
    
    /// Called by `turnTimer` when time has run out. i.e. this simply calls `progressGame(previousTurnValid: game.take(move: .timeRanOut))`.
    /// - important: this is the only place where the special `.timeRanOut` action should be used.
    @objc private func timeRanOut() {
        // the time has run out, so just act as if we have entered an incorrect move
        self.progressGame(previousTurnValid: game.take(move: .timeRanOut))
    }
	
	/// Animate a change in the appearance of the score labels (if a game has just began or ended)
	/// - parameter gameEnded: whether the game has just began (false) or just ended (true)
	private func updateScoreLabels(forGameEnded:Bool) {
		if gameEnded {
			// increase size of score label
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
				self.scoreLabel.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
			}, completion: nil)
			// show the highscore label
			UIView.transition(with: self.highscoreLabel, duration: 0.25, options: [], animations: {
				self.highscoreLabel.updateTextMaintainCenter("HIGHSCORE \(LeaderboardManager.shared.deviceHighscore)")
			}, completion: nil)
		} else {
			// prevent a brief '0' from glitching
			self.scoreLabel.updateTextMaintainCenter("1")
			// decrease size of score label
			UIView.animate(withDuration: ViewController.nextMoveAnimationTime) {
				self.scoreLabel.transform = CGAffineTransform.identity
			}
			// hide the highscore label
			UIView.transition(with: self.highscoreLabel, duration: ViewController.nextMoveAnimationTime, options: [], animations: {
				self.highscoreLabel.updateTextMaintainCenter("")
			}, completion: nil)
		}
	}
	
    /// Either shows or hides the extra buttons when a game ends or begins
    private func changeExtraButtons(forGameEnded gameEnded:Bool) {
        UIView.animate(withDuration: ViewController.nextMoveAnimationTime) {
            let targetAlpha:CGFloat = gameEnded ? 1.0 : 0.0
            self.leaderboardButton.alpha = targetAlpha
            self.shareButton.alpha = targetAlpha
        }
    }
	
	// MARK: - Game Center
	
	public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Adverts
	
	public func adViewDidClick(_ adView: FBAdView) {
		Analytics.logEvent("ad_click", parameters: nil)
	}
	
	public func adViewWillLogImpression(_ adView: FBAdView) {
		Analytics.logEvent("ad_impression", parameters: nil)
	}
	
}

