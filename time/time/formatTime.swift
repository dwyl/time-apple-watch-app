//
//  formatTime.swift
//  time
//
//  Created by Sohil Pandya on 10/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit


func timeToText(s: Int) -> String {
    return s < 10 ? "0\(s)" : "\(s)"
}

func secondsToHsMsSs(seconds : Int, result: @escaping (Int, Int, Int)->()) {
    result(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
