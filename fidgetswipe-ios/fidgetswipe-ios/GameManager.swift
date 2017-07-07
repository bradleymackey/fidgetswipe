//
//  GameManager.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation

/// Manages the overall flow of the game
public final class GameManager {
    
    /// The current state of the game
    private var currentState:GameState = .notYetBegan
    
    /// The current game score
    private var gameScore:UInt = 0
    
    /// The expected next move of the player
    /// - note: `nil` if game is not currently playing
    private var expectedPlayerMove:Action?
    
    public init() {
        
    }
    
    /// Selects a random move.
    private func randomMove() -> Action {
        let randomNumber = arc4random_uniform(Action.totalActions)
        if let action = Action(rawValue: Int(randomNumber)) {
            return action
        } else {
            fatalError("This rawValue (\(randomNumber)) does not equate to a vaild action.")
        }
    }
    
    /// A simple variable that calculates the time allowed for the current turn based on the user's current store.
    private var timeForMove:Float {
        let time = GameConstants.shared.getTime(forCurrentScore: gameScore)
        return Float(time)
    }
    
    public func newGame() {
    
    }
    
    public func nextMove() {
        
    }
    
    /// Player calls this when they take a move
    /// - returns: true if this was a vaild action, false if this was not, the game has now ended. Also the player's new score.
    public func take(move:Action) -> (valid:Bool,newScore:UInt) {
        if move != expectedPlayerMove {
            return (false, gameScore)
        } else {
            gameScore += 1
            return (true, gameScore)
        }
    }
    
}
