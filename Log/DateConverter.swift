//
//  DateConverter.swift
//  Log
//
//  Created by Andrei Villasana on 10/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct DateConverter {

    static let minute: TimeInterval = 60.0
    static let hour: TimeInterval = 60.0 * minute
    static let day: TimeInterval = 24 * hour
    static let week: TimeInterval = 7 * day

    static func handleDate(date: String?) -> String? {

        let formatter = DateFormatter()
            formatter.dateFormat = Constants.serverDateFormat
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"

        if let date = date {
            guard let dateObj = formatter.date(from: date) else { return nil }
            // timeIntervalSinceNow returns a negative value, multiply it by negative 1 to make it positive
            let timeDifference = dateObj.timeIntervalSinceNow * -1

            if timeDifference < day {
                // Message was sent in the last 24 hours
                return convert(date: dateObj, format: "hh:mm a")
            } else if timeDifference > day && timeDifference < week {
                // Message was sent in the last week
                return convert(date: dateObj, format: "EEE")
            } else if timeDifference > week {
                // Message was sent over a week ago
                return convert(date: dateObj, format: "MMM d")
            }
        }
        return nil
    }

    static func convert(date: Date, format: String) -> String {
        // let dateFormat = "EEE, MMM d, yyyy, hh:mm a"
        let formatter = DateFormatter()
            formatter.dateFormat = format

        return formatter.string(from: date)
    }

}
