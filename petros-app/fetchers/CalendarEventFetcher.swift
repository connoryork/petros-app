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

    static func success(_ events: [CalendarEvent]) -> CalendarEventsFetchResult {
        CalendarEventsFetchResult(events: events, error: nil)
    }

    static func failure(error: Error) -> CalendarEventsFetchResult {
        CalendarEventsFetchResult(events: [], error: error)
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
            print("[CalendarEventFetcher] Failed to fetch Google Calendar events: \(error.localizedDescription)")
            return .failure(error: error)
        }
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
