//
//  GameManager.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation


/* Game reference example

// Create the game
let game = Game()
 
// Get the first turn
let first = game.getNextMove()
let firstAction = first.action
let timeAllowedForFirstAction = first.timeAllowed
let updatedScore = first.newScore

// Take a turn
let successful = game.take(move: .swipeDown)
if successful {
    // get the second turn
    let secondTurn = game.getNextMove()
} else {
    // WRONG! the game has ended (you should also report game center score at this point)
    let setupReadyForNextGame = game.getNextMove()
}

// NB: the flow is THE SAME no matter is the go is wrong or right
// this is because we don't have a 'Play Again' screen, they just start swiping again to keep playing
 
*/


/// Manages a game of Fidget Swipe
public final class Game {
    
    // MARK: Move Times
    public static let TAP_TIME        = 1.7
    public static let SWIPE_TIME      = 1.7
    public static let SHAKE_TIME      = 2.0
    public static let UPSIDE_DOWN_TIME = 2.1
    public static let FACE_TIME       = 2.1
    public static let VOLUME_TIME     = 2.1
    
    /// Gives a notion of state to the `Game` class.
    private enum State {
        case playing
        case notPlaying
    }
    
    /// The current state of the game.
    private var currentState:State = .notPlaying {
        didSet {
            // reset the game score when we restart the game
            if currentState == .playing && oldValue == .notPlaying {
                gameScore = 0
            }
        }
    }
    
    /// The current game score.
    private var gameScore:UInt = 0
    
    /// Keep track of the last action, so we don't do 2 of the same actions in a row.
    private var previousAction:Action = .volumeDown // just set it default to anything
    
    /// The expected next move of the player.
    /// - note: `nil` if game is not currently playing.
    private var expectedPlayerMove:Action = .tap
	
	/// Whether or not motion challenges should be selected.
    public var motionChallengesEnabled = true
    
    /// Keep track of when we have the first turn, because the first one should not be a motion one.
    private var hasHadFirstTurn = false
    
    // nothing needed in here, all properties are already initalised
    public init() { }
    
    /// Calling this tells the game it should progress to a new move.
    public func nextMove() -> TurnData {
        expectedPlayerMove = Action.random()
        // if motion challenges are not enabled, do not choose motion challenges (also do not perform a motion challenge for the first turn AND we cannot have 2 motion challenges in a row).
        // make sure not to repeat the same action 2 times in a row
        if !motionChallengesEnabled || !hasHadFirstTurn || previousAction.isMotionChallenge {
            hasHadFirstTurn = true
            while expectedPlayerMove.isMotionChallenge || expectedPlayerMove == previousAction {
                expectedPlayerMove = Action.random()
            }
        } else {
            while expectedPlayerMove == previousAction {
                expectedPlayerMove = Action.random()
            }
        }
        previousAction = expectedPlayerMove
        return TurnData(action: expectedPlayerMove, newScore: gameScore, timeForMove: time(forAction: expectedPlayerMove))
    }
    
    /// The time allowed for each given move.
    private func time(forAction action:Action) -> TimeInterval {
        switch action {
        case .swipeDown, .swipeUp, .swipeLeft, .swipeRight:
            return Game.SWIPE_TIME
        case .tap:
            return Game.TAP_TIME
        case .volumeUp, .volumeDown:
            return Game.VOLUME_TIME
        case .faceDown, .faceUp:
            return Game.FACE_TIME
        case .upsideDown:
            return Game.UPSIDE_DOWN_TIME
        case .shake:
            return Game.SHAKE_TIME
        case .timeRanOut:
            fatalError("time ran out is not an action that does not have a time")
        }
    }
    
    /// Player calls this when they take a move.
    /// - returns: true if this was a vaild action, false if this was not, the game has now ended.
    public func take(move:Action) -> Bool {
        
        // we have taken a move, so we are now playing
        currentState = .playing
        
        // evaluate this move we have just taken, ending the game if we need to
        if move != expectedPlayerMove {
            currentState = .notPlaying
            hasHadFirstTurn = false
            return false
        } else {
            currentState = .playing
            gameScore += 1
            return true
        }
    }


}
