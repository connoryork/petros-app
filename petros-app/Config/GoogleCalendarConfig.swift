//
//  GoogleCalendarConfig.swift
//  petros-app
//
//  Created by GPT-5 Codex on 11/9/25.
//

import Foundation

struct GoogleCalendarConfig {
    static let shared = GoogleCalendarConfig()
    
    static let calendarID = "f50d3b233295c6e3a9940b83706a1e564905a6db7f17eaca488ec4c50d4dd7d0@group.calendar.google.com"

    let serviceAccountFileName: String
    let serviceAccountFileExtension: String
    let maxResults: Int
    let lookaheadDays: Int?

    private init(
        serviceAccountFileName: String = "google-calendar-service-account",
        serviceAccountFileExtension: String = "json",
        maxResults: Int = 25,
        lookaheadDays: Int? = 180
    ) {
        self.serviceAccountFileName = serviceAccountFileName
        self.serviceAccountFileExtension = serviceAccountFileExtension
        self.maxResults = maxResults
        self.lookaheadDays = lookaheadDays
    }

    func timeMaxDate(from date: Date) -> Date? {
        guard let lookaheadDays = lookaheadDays else { return nil }
        return Calendar.current.date(byAdding: .day, value: lookaheadDays, to: date)
    }
}
