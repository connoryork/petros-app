//
//  CalendarEventFetcher.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import Foundation

struct CalendarEventsFetchResult {
    let events: [CalendarEvent]
    let error: Error?
    let usedFallback: Bool

    static func success(_ events: [CalendarEvent]) -> CalendarEventsFetchResult {
        CalendarEventsFetchResult(events: events, error: nil, usedFallback: false)
    }

    static func fallback(events: [CalendarEvent], error: Error?) -> CalendarEventsFetchResult {
        CalendarEventsFetchResult(events: events, error: error, usedFallback: true)
    }
}

class CalendarEventFetcher {
    static let shared = CalendarEventFetcher()

    private let apiClient: GoogleCalendarAPIClient
    private let calendarConfig: GoogleCalendarConfig

    init(
        apiClient: GoogleCalendarAPIClient = .shared,
        calendarConfig: GoogleCalendarConfig = .shared
    ) {
        self.apiClient = apiClient
        self.calendarConfig = calendarConfig
    }

    static func fetchUpcomingEvents() async -> CalendarEventsFetchResult {
        await CalendarEventFetcher.shared.fetchUpcomingEvents()
    }

    func fetchUpcomingEvents() async -> CalendarEventsFetchResult {
        print("[CalendarEventFetcher] Starting fetchUpcomingEvents at \(Date())")

        do {
            let options = GoogleCalendarListEventsOptions(
                calendarID: GoogleCalendarConfig.calendarID,
                timeMin: Date(),
                timeMax: calendarConfig.timeMaxDate(from: Date()),
                maxResults: calendarConfig.maxResults,
                singleEvents: true,
                orderBy: "startTime",
                pageToken: nil
            )

            print("[CalendarEventFetcher] Prepared options for calendarID=\(options.calendarID) maxResults=\(options.maxResults)")

            let response = try await apiClient.listEvents(options: options)
            let events = response.items.compactMap { CalendarEvent(googleEvent: $0) }
            let sorted = events.sorted { $0.date < $1.date }
            print("[CalendarEventFetcher] Received \(events.count) events from API; \(sorted.count) remain after sorting/filtering")
            return .success(sorted)
        } catch {
            let fallback = fallbackEvents()
            print("[CalendarEventFetcher] Failed to fetch Google Calendar events: \(error.localizedDescription)")
            print("[CalendarEventFetcher] Using fallback events count=\(fallback.count)")
            return .fallback(events: fallback, error: error)
        }
    }

    private func fallbackEvents() -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let firstFridayDates = [
            "2025-11-07",
            "2025-12-05",
            "2026-01-02",
            "2026-02-06",
            "2026-03-06",
            "2026-04-03",
            "2026-05-01"
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

        let foundationNightDates = [
            "2025-11-18",
            "2025-12-16",
            "2026-01-20",
            "2026-02-17",
            "2026-03-17",
            "2026-04-21",
            "2026-05-19"
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

        events.sort { $0.date < $1.date }
        print("[CalendarEventFetcher] Generated \(events.count) fallback events")
        return events
    }
}

private extension CalendarEvent {
    init?(googleEvent: GoogleCalendarEvent) {
        guard let startDate = googleEvent.start.effectiveDate else {
            return nil
        }

        let location = googleEvent.location?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        self = CalendarEvent(
            id: googleEvent.id,
            name: googleEvent.summary ?? "Untitled Event",
            date: startDate,
            endDate: googleEvent.end?.effectiveDate,
            address: (location?.isEmpty == false ? location! : "Location TBA"),
            details: googleEvent.description
        )
    }
}
