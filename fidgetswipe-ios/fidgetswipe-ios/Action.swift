//
//  Action.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation

/// A simple enum to represent the type of actions that the game accepts.
public enum Action: Int, CustomStringConvertible {
    
    case tap        = 0
    case swipeUp    = 1
    case swipeDown  = 2
    case swipeRight = 3
    case swipeLeft  = 4
    case shake      = 5
    case upsideDown = 6
    case volumeUp   = 7
    case volumeDown = 8
    case faceUp     = 9
    case faceDown   = 10
    
    case timeRanOut = 999 // special action, only called when the time has run out.
    
    /// The total number of actions in the enum.
    public static let totalActions:UInt32 = 11
    
    public static func random() -> Action {
        let randomNumber = arc4random_uniform(Action.totalActions)
        if let action = Action(rawValue: Int(randomNumber)) {
            return action
        } else {
            fatalError("rawValue (\(randomNumber)) does not equate to a vaild 'Action'.")
        }
    }
    
    public var description:String {
        switch self {
        case .tap:
            return "TAP"
        case .swipeUp, .swipeDown, .swipeLeft, .swipeRight:
            return "SWIPE"
        case .shake:
            return "SHAKE"
        case .upsideDown:
            return "ROTATE"
        case .volumeUp:
            return "VOLUME UP"
        case .volumeDown:
            return "VOLUME DOWN"
        case .faceUp:
            return "FACE UP"
        case .faceDown:
            return "FACE DOWN"
        case .timeRanOut:
            fatalError("Time ran out is not an action that should be displayed")
        }
    }
    
    public var isMotionChallenge:Bool {
        switch self {
        case .upsideDown, .faceUp, .faceDown, .shake:
            return true
        case .tap, .swipeRight, .swipeLeft, .swipeDown, .swipeUp, .volumeUp, .volumeDown, .timeRanOut:
            return false
        }
    }
}
