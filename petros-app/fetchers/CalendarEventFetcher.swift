//
//  CalendarEventFetcher.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import Foundation

class CalendarEventFetcher {
    static func fetchUpcomingEvents() -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Generate First Friday Adoration events (every first Friday)
        let firstFridayDates = [
            "2025-11-07", // November 2025
            "2025-12-05", // December 2025
            "2026-01-02", // January 2026
            "2026-02-06", // February 2026
            "2026-03-06", // March 2026
            "2026-04-03", // April 2026
            "2026-05-01"  // May 2026
        ]
        
        for dateString in firstFridayDates {
            if let date = dateFormatter.date(from: dateString) {
                events.append(CalendarEvent(
                    name: "First Friday Adoration",
                    date: date,
                    address: "St. Peter the Apostle Parish"
                ))
            }
        }
        
        // Generate Foundation Night events (every third Tuesday)
        let foundationNightDates = [
            "2025-11-18", // November 2025
            "2025-12-16", // December 2025
            "2026-01-20", // January 2026
            "2026-02-17", // February 2026
            "2026-03-17", // March 2026
            "2026-04-21", // April 2026
            "2026-05-19"  // May 2026
        ]
        
        for dateString in foundationNightDates {
            if let date = dateFormatter.date(from: dateString) {
                events.append(CalendarEvent(
                    name: "Foundation Night",
                    date: date,
                    address: "St. Peter's Parish Hall"
                ))
            }
        }
        
        // Sort events by date (nearest upcoming first)
        events.sort { $0.date < $1.date }
        
        return events
    }
}

