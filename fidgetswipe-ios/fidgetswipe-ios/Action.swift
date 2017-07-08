//
//  Action.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation

/// A simple enum to represent the type of actions that the game accepts.
public enum Action: Int {
    
    case tap        = 0
    case swipeUp    = 1
    case swipeDown  = 2
    case swipeRight = 3
    case swipeLeft  = 4
    
    /// The total number of actions in the enum.
    public static let totalActions:UInt32 = 5
    
    public static func random() -> Action {
        let randomNumber = arc4random_uniform(Action.totalActions)
        if let action = Action(rawValue: Int(randomNumber)) {
            return action
        } else {
            fatalError("This rawValue (\(randomNumber)) does not equate to a vaild 'Action'.")
        }
    }
}
