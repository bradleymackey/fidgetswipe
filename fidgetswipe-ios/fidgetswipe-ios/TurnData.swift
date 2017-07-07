//
//  TurnData.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation

/// A nice packaged structure that contains all the information we need when we start a new turn
public struct TurnData {
    let action:Action
    let timeAllowed:TimeInterval
    let newScore:UInt
}
