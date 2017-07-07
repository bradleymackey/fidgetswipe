//
//  GameManager.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation

/// Manages the overall flow of the game
public final class Game {
    
    /// The current state of the game
    private var currentState:GameState {
        didSet {
            // reset the game score when we restart the game
            if currentState == .playing && oldValue == .notPlaying {
                gameScore = 0
            }
        }
    }
    
    /// The current game score
    private var gameScore:UInt
    
    /// The expected next move of the player
    /// - note: `nil` if game is not currently playing
    private var expectedPlayerMove:Action
    
    public init() {
        gameScore = 0
        currentState = .notPlaying
        expectedPlayerMove = .tap // doesn't matter, this is randomly set on the first turn
    }
    
    /// Calculates the time allowed for the current turn based on the user's current store.
    private static func timeAllowedForMove(forScore score:UInt) -> TimeInterval {
        let time = GameConstants.shared.getTime(forCurrentScore: score)
        return TimeInterval(time)
    }
    
    /// Calling this tells the game it should progress to a new move.
    public func nextMove() -> (turnData:TurnData,newScore:UInt) {
        expectedPlayerMove = Action.random()
        let timeForNext = GameManager.timeAllowedForMove(forScore: gameScore)
        let turnData = TurnData(action: expectedPlayerMove, timeAllowed: timeForNext)
        return (turnData,gameScore)
    }
    
    /// Player calls this when they take a move.
    /// - returns: true if this was a vaild action, false if this was not, the game has now ended.
    public func take(move:Action) -> Bool {
        
        // we have taken a move, so we are now playing
        currentState = .playing
        
        // evaluate this move we have just taken
        if move != expectedPlayerMove {
            currentState = .notPlaying
            gameScore = 0
            return false
        } else {
            currentState = .playing
            gameScore += 1
            return true
        }
    }
    
}
