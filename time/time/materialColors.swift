//
//  materialColors.swift
//  time
//
//  Created by Sohil Pandya on 24/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit

class materialColors: NSObject {
    
    var red: Double!
    var green: Double!
    var blue: Double!
    var alpha: Double!
    
    init(red: Double, green: Double, blue: Double, alpha: Double) {
    super.init()
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
}
