//
//  FeedbackService.swift
//  petros-app
//
//  Created by Auto on 1/15/25.
//

import Foundation

struct FeedbackSubmissionResult {
    let success: Bool
    let error: Error?
}

actor FeedbackService {
    static let shared = FeedbackService()
    
    private let sheetsClient: GoogleSheetsAPIClient
    
    init(sheetsClient: GoogleSheetsAPIClient = .shared) {
        self.sheetsClient = sheetsClient
    }
    
    func submitFeedback(_ feedback: Feedback) async -> FeedbackSubmissionResult {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let timestampString = dateFormatter.string(from: feedback.timestamp)
        
        let values = [
            timestampString,
            feedback.name,
            feedback.email,
            feedback.message
        ]
        
        do {
            _ = try await sheetsClient.appendRow(
                spreadsheetID: GoogleSheetsConfig.spreadsheetID,
                range: GoogleSheetsConfig.range,
                values: values
            )
            print("[FeedbackService] Successfully submitted feedback")
            return FeedbackSubmissionResult(success: true, error: nil)
        } catch {
            print("[FeedbackService] Failed to submit feedback: \(error.localizedDescription)")
            return FeedbackSubmissionResult(success: false, error: error)
        }
    }
}

