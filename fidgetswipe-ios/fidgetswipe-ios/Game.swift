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
    
    /// The time allowed for each move
    public static let tapTime        = 1.5
    public static let swipeTime      = 1.5
    public static let shakeTime      = 1.5
    public static let upsideDownTime = 1.5
    public static let faceTime       = 1.5
    public static let volumeTime     = 1.5
    
    /// Gives a notion of state to the `Game` class.
    private enum State {
        case playing
        case notPlaying
    }
    
    /// The current state of the game.
    private var currentState:State {
        didSet {
            // reset the game score when we restart the game
            if currentState == .playing && oldValue == .notPlaying {
                gameScore = 0
            }
        }
    }
    
    /// The current game score.
    private var gameScore:UInt
    
    /// Keep track of the last action, so we dont do 2 of the same actions in a row.
    private var previousAction:Action = .volumeDown // just set it default to anything
    
    /// The expected next move of the player.
    /// - note: `nil` if game is not currently playing.
    private var expectedPlayerMove:Action
    
    private var motionChallengesEnabled = true
    
    /// Keep track of when we have the first turn, because the first one should not be a motion one.
    private var hasHadFirstTurn = false
    
    public init() {
        gameScore = 0
        currentState = .notPlaying
        expectedPlayerMove = .tap // doesn't matter, this is randomly set on the first turn
    }
    
    
    /// Calling this tells the game it should progress to a new move.
    public func getNextMove() -> TurnData {
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
    
    private func time(forAction action:Action) -> TimeInterval {
        switch action {
        case .swipeDown, .swipeUp, .swipeLeft, .swipeRight:
            return Game.swipeTime
        case .tap:
            return Game.tapTime
        case .volumeUp, .volumeDown:
            return Game.volumeTime
        case .faceDown, .faceUp:
            return Game.faceTime
        case .upsideDown:
            return Game.upsideDownTime
        case .shake:
            return Game.shakeTime
        }
    }
    
    /// Player calls this when they take a move.
    /// - returns: true if this was a vaild action, false if this was not, the game has now ended.
    public func take(move:Action) -> Bool {
        
        // we have taken a move, so we are now playing
        currentState = .playing
        
        // evaluate this move we have just taken
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
    
    /// Disables motion challenges for the game. They cannot be re-enabled.
    public func disableMotionChallenges() {
        motionChallengesEnabled = false
    }
    
}
