//
//  DateConverter.swift
//  Log
//
//  Created by Andrei Villasana on 10/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

enum DateFormats: String {
    case server = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case timeOfDay = "hh:mm a" // e.g, 12:21 pm
    case dayOfWeek = "EEE"  // e.g, Mon, Tue, Wed,
    case monthAndDay =  "MMM d" // e.g, Sep 15, Oct 3
}

struct DateConverter {

    private static let minute: TimeInterval = 60.0
    private static let hour: TimeInterval = 60.0 * minute
    private static let day: TimeInterval = 24 * hour
    private static let week: TimeInterval = 7 * day

    static func handle(date: String?) -> String? {
        let formatter = DateFormatter()
            formatter.dateFormat = DateFormats.server.rawValue
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"

        if let date = date {
            guard let dateObj = formatter.date(from: date) else { return nil }
            // timeIntervalSinceNow returns a negative value, multiply it by negative 1 to make it positive
            let timeDifference = dateObj.timeIntervalSinceNow * -1

            if timeDifference < day {
                // Message was sent in the last 24 hours
                return convert(date: dateObj, format: .timeOfDay)
            } else if timeDifference > day && timeDifference < week {
                // Message was sent in the last week
                return convert(date: dateObj, format: .dayOfWeek)
            } else if timeDifference > week {
                // Message was sent over a week ago
                return convert(date: dateObj, format: .monthAndDay)
            }
        }
        return nil
    }

    static func convert(date: Date, format: DateFormats) -> String {
        let formatter = DateFormatter()
            formatter.dateFormat = format.rawValue

        return formatter.string(from: date)
    }

}
