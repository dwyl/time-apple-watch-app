//
//  Task.swift
//  time
//
//  Created by Sohil Pandya on 08/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//
//
//import UIKit
//import os.log
//
//class Task: NSObject, NSCoding {
//    var name: String
//    var time: String
//    var red: Double
//    var green: Double
//    var blue: Double
//    
//
//    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
//
//    
//    struct PropertyKey {
//        static let name = "name"
//        static let time = "time"
//        static let red = "red"
//        static let green = "green"
//        static let blue = "blue"
//    }
//    
//    init?(name: String, time: String, red: Double, green: Double, blue: Double) {
//        
//        if name.isEmpty {
//            return nil
//        }
//        
//        self.name = name
//        self.time = time
//        self.red = red
//        self.green = green
//        self.blue = blue
//    }
//    
//
//    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(name, forKey: PropertyKey.name)
//        aCoder.encode(time, forKey: PropertyKey.time)
//        aCoder.encode(red, forKey: PropertyKey.red)
//        aCoder.encode(green, forKey: PropertyKey.green)
//        aCoder.encode(blue, forKey: PropertyKey.blue)
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
//            else {
//                os_log("unable to decode the name for Task Object", log: OSLog.default, type: .debug)
//                return nil
//        }
//        
//        let time = aDecoder.decodeObject(forKey: PropertyKey.time)
//        let red = aDecoder.decodeObject(forKey: PropertyKey.red)
//        let green = aDecoder.decodeObject(forKey: PropertyKey.green)
//        let blue = aDecoder.decodeObject(forKey: PropertyKey.blue)
//        
//        self.init(name: name, time: time as! String, red: red as! Double, green: green as! Double, blue: blue as! Double);
//        
//    }
//    
//    
//
//    
//}

