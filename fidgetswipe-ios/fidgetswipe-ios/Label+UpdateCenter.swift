//
//  Label+UpdateCenter.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 09/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
	
	/// Updates the text while maintaining the current center position.
    public func updateTextMaintainCenter(text:String) {
        let previousCenter = self.center
        self.text = text
        self.sizeToFit()
        self.center = previousCenter
    }
	
}
