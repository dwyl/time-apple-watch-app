//
//  stringToHash.swift
//  dwyl
//
//  Created by Sohil Pandya on 22/06/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation

func sha256(_ data: Data) -> Data? {
    guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
    CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
    return res as Data
}

func StringToHash(_ str: String) -> String? {
    guard
        let data = str.data(using: String.Encoding.utf8),
        let shaData = sha256(data)
        else { return nil }
    let rc = shaData.base64EncodedString(options: [])
    return rc
}
