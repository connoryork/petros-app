//
//  GoogleCalendarAPIClient.swift
//  petros-app
//
//  Created by GPT-5 Codex on 11/9/25.
//

import Foundation

enum GoogleCalendarAPIError: LocalizedError {
    case invalidCalendarID
    case invalidURL
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidCalendarID:
            return "The configured Google Calendar ID is invalid."
        case .invalidURL:
            return "Failed to build Google Calendar API URL."
        case .requestFailed(let statusCode, let message):
            if let message = message {
                return "Google Calendar API request failed with status \(statusCode): \(message)"
            } else {
                return "Google Calendar API request failed with status \(statusCode)."
            }
        case .decodingFailed:
            return "Failed to decode Google Calendar API response."
        }
    }
}

struct GoogleCalendarListEventsOptions {
    let calendarID: String
    let timeMin: Date
    let timeMax: Date?
    let maxResults: Int
    let singleEvents: Bool
    let orderBy: String
    let pageToken: String?

    init(
        calendarID: String,
        timeMin: Date = Date(),
        timeMax: Date? = nil,
        maxResults: Int = 50,
        singleEvents: Bool = true,
        orderBy: String = "startTime",
        pageToken: String? = nil
    ) {
        self.calendarID = calendarID
        self.timeMin = timeMin
        self.timeMax = timeMax
        self.maxResults = maxResults
        self.singleEvents = singleEvents
        self.orderBy = orderBy
        self.pageToken = pageToken
    }
}

actor GoogleCalendarAPIClient {
    static let shared = GoogleCalendarAPIClient()

    private let authService: GoogleCalendarAuthService
    private let urlSession: URLSession
    private let iso8601Formatter: ISO8601DateFormatter

    init(
        authService: GoogleCalendarAuthService = .shared,
        urlSession: URLSession = .shared,
        iso8601Formatter: ISO8601DateFormatter = GoogleCalendarDateTimeFormatters.dateTimeFormatter
    ) {
        self.authService = authService
        self.urlSession = urlSession
        self.iso8601Formatter = iso8601Formatter
    }

    func listEvents(options: GoogleCalendarListEventsOptions) async throws -> GoogleCalendarEventsResponse {
        print("[GoogleCalendarAPIClient] listEvents called with calendarID=\(options.calendarID) timeMin=\(iso8601Formatter.string(from: options.timeMin)) timeMax=\(options.timeMax.map { iso8601Formatter.string(from: $0) } ?? "nil") maxResults=\(options.maxResults) singleEvents=\(options.singleEvents) orderBy=\(options.orderBy) pageToken=\(options.pageToken ?? "nil")")

        guard let encodedCalendarID = options.calendarID.addingPercentEncoding(withAllowedCharacters: Self.calendarIDAllowedCharacters) else {
            print("[GoogleCalendarAPIClient] Failed to percent-encode calendar ID: \(options.calendarID)")
            throw GoogleCalendarAPIError.invalidCalendarID
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.path = "/calendar/v3/calendars/\(encodedCalendarID)/events"

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "maxResults", value: "\(options.maxResults)"),
            URLQueryItem(name: "singleEvents", value: options.singleEvents ? "true" : "false"),
            URLQueryItem(name: "orderBy", value: options.orderBy),
            URLQueryItem(name: "timeMin", value: iso8601Formatter.string(from: options.timeMin))
        ]

        if let timeMax = options.timeMax {
            queryItems.append(URLQueryItem(name: "timeMax", value: iso8601Formatter.string(from: timeMax)))
        }

        if let pageToken = options.pageToken {
            queryItems.append(URLQueryItem(name: "pageToken", value: pageToken))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            print("[GoogleCalendarAPIClient] URLComponents failed to build URL for calendarID=\(options.calendarID)")
            throw GoogleCalendarAPIError.invalidURL
        }

        print("[GoogleCalendarAPIClient] Built request URL: \(url.absoluteString)")
        print("[GoogleCalendarAPIClient] Requesting access token with scopes: \(Self.requiredScopes.joined(separator: ", "))")

        let accessToken = try await authService.accessToken(scopes: Self.requiredScopes)

        print("[GoogleCalendarAPIClient] Successfully retrieved access token")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        print("[GoogleCalendarAPIClient] Executing request to Google Calendar API")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[GoogleCalendarAPIClient] Response was not an HTTPURLResponse")
            throw GoogleCalendarAPIError.requestFailed(statusCode: -1, message: nil)
        }

        print("[GoogleCalendarAPIClient] Received response with status=\(httpResponse.statusCode) dataLength=\(data.count)B")

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            if let message = message {
                print("[GoogleCalendarAPIClient] Request failed with status \(httpResponse.statusCode). Body: \(message)")
            } else {
                print("[GoogleCalendarAPIClient] Request failed with status \(httpResponse.statusCode). Unable to decode body.")
            }
            throw GoogleCalendarAPIError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let decoder = JSONDecoder.googleCalendarDecoder

        do {
            let decoded = try decoder.decode(GoogleCalendarEventsResponse.self, from: data)
            print("[GoogleCalendarAPIClient] Successfully decoded \(decoded.items.count) events from API response")
            return decoded
        } catch {
            if let body = String(data: data, encoding: .utf8) {
                print("[GoogleCalendarAPIClient] Decoding failed. Raw response body: \(body)")
            } else {
                print("[GoogleCalendarAPIClient] Decoding failed and response body could not be converted to string (length \(data.count)B)")
            }
            throw GoogleCalendarAPIError.decodingFailed
        }
    }
}

private extension GoogleCalendarAPIClient {
    static var requiredScopes: [String] {
        ["https://www.googleapis.com/auth/calendar.readonly"]
    }

    static var calendarIDAllowedCharacters: CharacterSet {
        var set = CharacterSet.urlPathAllowed
        set.insert(charactersIn: "@.")
        return set
    }
}

private extension JSONDecoder {
    static var googleCalendarDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            if let date = GoogleCalendarDateTimeFormatters.dateTimeFormatter.date(from: string) ??
                GoogleCalendarDateTimeFormatters.backupDateTimeFormatter.date(from: string) {
                return date
            }

            if let date = GoogleCalendarDateTimeFormatters.dateFormatter.date(from: string) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Google Calendar date value \(string)")
        }
        return decoder
    }
}

