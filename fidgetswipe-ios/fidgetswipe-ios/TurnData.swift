//
//  TurnData.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation
import UIKit

/// A nice packaged structure that contains all the information we need when we start a new turn
public struct TurnData {
    
    private struct Images {
        fileprivate static let tap = UIImage(named: "tap")!.withRenderingMode(.alwaysTemplate)
        fileprivate static let swipeUp = UIImage(named: "swipe_up")!.withRenderingMode(.alwaysTemplate)
        fileprivate static let swipeLeft = UIImage(named: "swipe_left")!.withRenderingMode(.alwaysTemplate)
        fileprivate static let swipeDown = UIImage(named: "swipe_down")!.withRenderingMode(.alwaysTemplate)
        fileprivate static let swipeRight = UIImage(named: "swipe_right")!.withRenderingMode(.alwaysTemplate)
    }
    
    /// The action that this turn requires from the user.
    public let action:Action
    
    /// The user's score as it stands at the moment.
    public let newScore:UInt
    
    /// The time allowed for this move
    public let timeForMove:TimeInterval
    
    /// The image that should instruct ther user what to do.
    public var image:UIImage {
        switch action {
        case .tap:
            return TurnData.Images.tap
        case .swipeUp:
            return TurnData.Images.swipeUp
        case .swipeLeft:
            return TurnData.Images.swipeLeft
        case .swipeDown:
            return TurnData.Images.swipeDown
        case .swipeRight:
            return TurnData.Images.swipeRight
        }
    }
}
