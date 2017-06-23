//
//  dateConverter.swift
//  dwyl
//
//  Created by Sohil Pandya on 22/06/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation

func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    return formatter.string(from: date)
}

func stringToDate(string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    return formatter.date(from: string)!
}
