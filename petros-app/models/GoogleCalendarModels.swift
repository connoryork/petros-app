//
//  GoogleCalendarModels.swift
//  petros-app
//
//  Created by GPT-5 Codex on 11/9/25.
//

import Foundation

struct GoogleCalendarEventsResponse: Decodable {
    let items: [GoogleCalendarEvent]
    let nextPageToken: String?

    private enum CodingKeys: String, CodingKey {
        case items
        case nextPageToken
    }
}

struct GoogleCalendarEvent: Decodable {
    let id: String
    let status: String?
    let summary: String?
    let description: String?
    let location: String?
    let start: GoogleCalendarDateTime
    let end: GoogleCalendarDateTime?
    let htmlLink: URL?
    let updated: Date?

    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case summary
        case description
        case location
        case start
        case end
        case htmlLink = "htmlLink"
        case updated
    }
}

struct GoogleCalendarDateTime: Decodable {
    let dateTime: Date?
    let date: Date?
    let timeZone: String?

    var effectiveDate: Date? {
        dateTime ?? date
    }

    private enum CodingKeys: String, CodingKey {
        case dateTime
        case date
        case timeZone
    }

    init(dateTime: Date?, date: Date?, timeZone: String?) {
        self.dateTime = dateTime
        self.date = date
        self.timeZone = timeZone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateTimeString = try container.decodeIfPresent(String.self, forKey: .dateTime)
        let dateString = try container.decodeIfPresent(String.self, forKey: .date)
        timeZone = try container.decodeIfPresent(String.self, forKey: .timeZone)

        if let dateTimeString = dateTimeString {
            let parsed =
                GoogleCalendarDateTimeFormatters.dateTimeFormatter.date(from: dateTimeString) ??
                GoogleCalendarDateTimeFormatters.backupDateTimeFormatter.date(from: dateTimeString)
            dateTime = parsed
        } else {
            dateTime = nil
        }

        if let dateString = dateString {
            date = GoogleCalendarDateTimeFormatters.dateFormatter.date(from: dateString)
        } else {
            date = nil
        }
    }
}

enum GoogleCalendarDateTimeFormatters {
    static let dateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let backupDateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

