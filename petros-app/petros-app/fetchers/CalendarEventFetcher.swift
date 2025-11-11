import Foundation

class CalendarEventFetcher {
    static let shared = CalendarEventFetcher()

    private let apiClient: GoogleCalendarAPIClient

    init(apiClient: GoogleCalendarAPIClient = .shared) {
        self.apiClient = apiClient
    }

    static func fetchUpcomingEvents() async -> [CalendarEvent] {
        await CalendarEventFetcher.shared.fetchUpcomingEvents()
    }

    func fetchUpcomingEvents() async -> CalendarEventsFetchResult {
        do {
            let config = GoogleCalendarConfig.shared
            let options = GoogleCalendarListEventsOptions(
                calendarID: config.calendarID,
                timeMin: Date(),
                timeMax: config.timeMaxDate(from: Date()),
                maxResults: config.maxResults,
                singleEvents: true,
                orderBy: "startTime",
                pageToken: nil
            )

            print("[CalendarEventFetcher] Fetching events", options)

            let response = try await apiClient.listEvents(options: options)
            let events = response.items.compactMap { CalendarEvent(googleEvent: $0) }
            print("[CalendarEventFetcher] Received \(events.count) events from Google Calendar")
            return .success(events.sorted { $0.date < $1.date })
        } catch {
            print("[CalendarEventFetcher] Failed to fetch Google Calendar events: \(error)")
            return .failure(error: error)
        }
    }
}

private extension CalendarEvent {
    init?(googleEvent: GoogleCalendarEvent) {
        guard let startDate = googleEvent.start.effectiveDate else {
            return nil
        }

        let cleanLocation = googleEvent.location?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        self = CalendarEvent(
            name: googleEvent.summary ?? "Untitled Event",
            date: startDate,
            address: (cleanLocation?.isEmpty == false ? cleanLocation! : "Location TBA")
        )
    }
}
