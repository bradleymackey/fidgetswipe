//
//  String+Hash.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 09/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import Foundation

extension String {
	
	/// An MD5 encoding of the current String.
    public var MD5: String {
        return self.MD5_RAW.map { String(format: "%02hhx", $0) }.joined()
    }
	
	/// Raw MD5 digest data for the current String.
    private var MD5_RAW:Data {
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
		}
        return digestData
    }
    
}
