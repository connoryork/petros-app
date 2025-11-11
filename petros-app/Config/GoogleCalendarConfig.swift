//
//  GoogleCalendarConfig.swift
//  petros-app
//
//  Created by GPT-5 Codex on 11/9/25.
//

import Foundation

struct GoogleCalendarConfig {
    static let shared = GoogleCalendarConfig()

    let calendarID: String
    let serviceAccountFileName: String
    let serviceAccountFileExtension: String
    let maxResults: Int
    let lookaheadDays: Int?

    private init(
        calendarID: String = GoogleCalendarConfig.resolveCalendarID(),
        serviceAccountFileName: String = "google-calendar-service-account",
        serviceAccountFileExtension: String = "json",
        maxResults: Int = 25,
        lookaheadDays: Int? = 180
    ) {
        self.calendarID = calendarID
        self.serviceAccountFileName = serviceAccountFileName
        self.serviceAccountFileExtension = serviceAccountFileExtension
        self.maxResults = maxResults
        self.lookaheadDays = lookaheadDays
    }

    func timeMaxDate(from date: Date) -> Date? {
        guard let lookaheadDays = lookaheadDays else { return nil }
        return Calendar.current.date(byAdding: .day, value: lookaheadDays, to: date)
    }

    private static func resolveCalendarID() -> String {
        if let environmentID = ProcessInfo.processInfo.environment["GOOGLE_CALENDAR_ID"], !environmentID.isEmpty {
            return environmentID
        }

        if let bundleID = readCalendarIDFromBundle() {
            return bundleID
        }

        return "primary"
    }

    private static func readCalendarIDFromBundle() -> String? {
        let potentialResources = [
            (name: "calendar", extension: "id", subdirectory: nil),
            (name: "calendar", extension: "txt", subdirectory: "Secrets"),
            (name: "calendar", extension: "id", subdirectory: "Secrets")
        ]

        for resource in potentialResources {
            if let url = Bundle.main.url(
                forResource: resource.name,
                withExtension: resource.extension,
                subdirectory: resource.subdirectory
            ) {
                if let contents = try? String(contentsOf: url, encoding: .utf8) {
                    let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        return trimmed
                    }
                }
            }
        }

        return nil
    }
}
