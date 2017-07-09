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
    
    /// The action that this turn requires from the user.
    public let action:Action
    
    /// The user's score as it stands at the moment.
    public let newScore:UInt
    
    /// The time allowed for this move
    public let timeForMove:TimeInterval
    
    private static func image(forName name:String) -> UIImage {
        if let image = UIImage(named: name) {
            return image.withRenderingMode(.alwaysTemplate)
        } else {
            fatalError("Invalid image name!")
        }
    }
    
    /// The image that should instruct ther user what to do.
    public var image:UIImage {
        switch action {
        case .tap:
            return TurnData.image(forName: "tap")
        case .swipeUp:
            return TurnData.image(forName: "swipe_up")
        case .swipeLeft:
            return TurnData.image(forName: "swipe_left")
        case .swipeDown:
            return TurnData.image(forName: "swipe_down")
        case .swipeRight:
            return TurnData.image(forName: "swipe_right")
        case .shake:
            return TurnData.image(forName: "shake")
        case .upsideDown:
            return TurnData.image(forName: "upside_down")
        case .volumeUp:
            return TurnData.image(forName: "volume_up")
        case .volumeDown:
            return TurnData.image(forName: "volume_down")
        case .faceUp:
            return TurnData.image(forName: "face_up")
        case .faceDown:
			// just flip the face_up image for the face down image.
            let upImage = TurnData.image(forName: "face_up")
			return UIImage(cgImage: upImage.cgImage!, scale: 1, orientation: .downMirrored).withRenderingMode(.alwaysTemplate)
        }
    }
}
