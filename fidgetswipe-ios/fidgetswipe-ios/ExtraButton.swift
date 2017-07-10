//
//  ExtraButton.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 10/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit

/// The extra buttons (leaderboard and share button for example)
public final class ExtraButton: UIButton {
    
    public static let sideLength: CGFloat = 48
    
    public enum Category : Int {
        case leaderboard = 0
        case share = 1
    }
    
    public init(imageName:String, category:Category) {
        let frame = CGRect(x: 0, y: 0, width: ExtraButton.sideLength, height: ExtraButton.sideLength)
        super.init(frame: frame)
        self.setImage(UIImage(named: imageName), for: .normal)
        self.tag = category.rawValue
    }
    
    // can only be called from code
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
