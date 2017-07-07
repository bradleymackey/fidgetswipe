//
//  Action.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

public enum Action: Int {
    case tap        = 0
    case swipeUp    = 1
    case swipeDown  = 2
    case swipeRight = 3
    case swipeLeft  = 4
    
    static let totalActions:UInt32 = 5
}
