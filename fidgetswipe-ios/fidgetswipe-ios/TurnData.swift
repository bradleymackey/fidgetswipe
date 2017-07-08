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
    
    /// A simple structure to store information about the image that should be displayed to instruct the user what to do.
    public struct ImageInfo {
        
        /// The name of the image in the asset catalogue.
        public let imageName:String
        
        /// The rotation that the image should be presented at.
        public let imageRotationAngle:Double
    }
    
    /// The action that this turn requires from the user.
    public let action:Action
    
    /// The user's score as it stands at the moment.
    public let newScore:UInt
    
    /// Information about the image that should instruct ther user what to do.
    public var imageInfo:TurnData.ImageInfo {
        switch action {
        case .tap:
            return ImageInfo(imageName: "tap", imageRotationAngle: 0)
        case .swipeUp:
            return ImageInfo(imageName: "swipe_arrow", imageRotationAngle: 0)
        case .swipeLeft:
            return ImageInfo(imageName: "swipe_arrow", imageRotationAngle: .pi/2)
        case .swipeDown:
            return ImageInfo(imageName: "swipe_arrow", imageRotationAngle: .pi)
        case .swipeRight:
            return ImageInfo(imageName: "swipe_arrow", imageRotationAngle: (.pi/2)*3)
        }
    }
}
