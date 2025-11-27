//
//  GoogleSheetsAPIClient.swift
//  petros-app
//
//  Created by Auto on 1/15/25.
//

import Foundation

enum GoogleSheetsAPIError: LocalizedError {
    case invalidSpreadsheetID
    case invalidURL
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidSpreadsheetID:
            return "The configured Google Sheet ID is invalid."
        case .invalidURL:
            return "Failed to build Google Sheets API URL."
        case .requestFailed(let statusCode, let message):
            if let message = message {
                return "Google Sheets API request failed with status \(statusCode): \(message)"
            } else {
                return "Google Sheets API request failed with status \(statusCode)."
            }
        case .decodingFailed:
            return "Failed to decode Google Sheets API response."
        }
    }
}

struct GoogleSheetsAppendResponse: Decodable {
    let spreadsheetId: String
    let tableRange: String
    let updates: GoogleSheetsUpdateResponse
    
    private enum CodingKeys: String, CodingKey {
        case spreadsheetId
        case tableRange
        case updates
    }
}

struct GoogleSheetsUpdateResponse: Decodable {
    let spreadsheetId: String
    let updatedRange: String
    let updatedRows: Int
    let updatedColumns: Int
    let updatedCells: Int
    
    private enum CodingKeys: String, CodingKey {
        case spreadsheetId
        case updatedRange
        case updatedRows
        case updatedColumns
        case updatedCells
    }
}

actor GoogleSheetsAPIClient {
    static let shared = GoogleSheetsAPIClient()
    
    private let authService: GoogleCalendarAuthService
    private let urlSession: URLSession
    
    init(
        authService: GoogleCalendarAuthService = .shared,
        urlSession: URLSession = .shared
    ) {
        self.authService = authService
        self.urlSession = urlSession
    }
    
    func appendRow(spreadsheetID: String, range: String, values: [String]) async throws -> GoogleSheetsAppendResponse {
        print("[GoogleSheetsAPIClient] appendRow called with spreadsheetID=\(spreadsheetID) range=\(range)")
        
        // Encode spreadsheet ID for URL path
        guard let encodedSpreadsheetID = spreadsheetID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            print("[GoogleSheetsAPIClient] Failed to percent-encode spreadsheet ID: \(spreadsheetID)")
            throw GoogleSheetsAPIError.invalidSpreadsheetID
        }
        
        // For the range, we need to preserve the colon (:) as it's part of the range syntax
        // The Google Sheets API expects ranges like "Sheet1!A:D" with the colon unencoded
        var rangeAllowed = CharacterSet.urlPathAllowed
        rangeAllowed.insert(charactersIn: ":!") // Allow colon and exclamation mark in range
        
        guard let encodedRange = range.addingPercentEncoding(withAllowedCharacters: rangeAllowed) else {
            print("[GoogleSheetsAPIClient] Failed to percent-encode range: \(range)")
            throw GoogleSheetsAPIError.invalidURL
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "sheets.googleapis.com"
        components.path = "/v4/spreadsheets/\(encodedSpreadsheetID)/values/\(encodedRange):append"
        
        components.queryItems = [
            URLQueryItem(name: "valueInputOption", value: "RAW")
        ]
        
        guard let url = components.url else {
            print("[GoogleSheetsAPIClient] URLComponents failed to build URL")
            throw GoogleSheetsAPIError.invalidURL
        }
        
        print("[GoogleSheetsAPIClient] Built request URL: \(url.absoluteString)")
        print("[GoogleSheetsAPIClient] Requesting access token with scopes: \(Self.requiredScopes.joined(separator: ", "))")
        
        let accessToken = try await authService.accessToken(scopes: Self.requiredScopes)
        
        print("[GoogleSheetsAPIClient] Successfully retrieved access token")
        
        let requestBody: [String: Any] = [
            "values": [values]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("[GoogleSheetsAPIClient] Failed to serialize request body")
            throw GoogleSheetsAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        print("[GoogleSheetsAPIClient] Executing request to Google Sheets API")
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[GoogleSheetsAPIClient] Response was not an HTTPURLResponse")
            throw GoogleSheetsAPIError.requestFailed(statusCode: -1, message: nil)
        }
        
        print("[GoogleSheetsAPIClient] Received response with status=\(httpResponse.statusCode) dataLength=\(data.count)B")
        
        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            if let message = message {
                print("[GoogleSheetsAPIClient] Request failed with status \(httpResponse.statusCode). Body: \(message)")
            } else {
                print("[GoogleSheetsAPIClient] Request failed with status \(httpResponse.statusCode). Unable to decode body.")
            }
            throw GoogleSheetsAPIError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }
        
        let decoder = JSONDecoder()
        
        do {
            let decoded = try decoder.decode(GoogleSheetsAppendResponse.self, from: data)
            print("[GoogleSheetsAPIClient] Successfully appended row to sheet")
            return decoded
        } catch {
            if let body = String(data: data, encoding: .utf8) {
                print("[GoogleSheetsAPIClient] Decoding failed. Raw response body: \(body)")
            } else {
                print("[GoogleSheetsAPIClient] Decoding failed and response body could not be converted to string (length \(data.count)B)")
            }
            throw GoogleSheetsAPIError.decodingFailed
        }
    }
}

private extension GoogleSheetsAPIClient {
    static var requiredScopes: [String] {
        ["https://www.googleapis.com/auth/spreadsheets"]
    }
}

