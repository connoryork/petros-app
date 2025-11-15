//
//  CalendarView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct CalendarView: View {
    let events: [CalendarEvent]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading && events.isEmpty {
                    ProgressView("Loading events…")
                        .progressViewStyle(.circular)
                        .padding(.vertical, 48)
                } else if let errorMessage = errorMessage, events.isEmpty {
                    CalendarStateMessage(
                        title: "Couldn't load events",
                        message: errorMessage,
                        buttonTitle: "Try Again",
                        action: onRetry
                    )
                    .padding(.top, 32)
                } else if events.isEmpty {
                    CalendarStateMessage(
                        title: "No upcoming events",
                        message: "Check back soon for new events and activities.",
                        buttonTitle: nil,
                        action: {}
                    )
                    .padding(.top, 32)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            VStack(spacing: 0) {
                                CalendarEventView(event: event)
                                if index < events.count - 1 {
                                    LineBreak(verticalPadding: 0)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .background(Color.white)
    }
}

private struct CalendarStateMessage: View {
    let title: String
    let message: String
    let buttonTitle: String?
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let buttonTitle = buttonTitle {
                Button(action: action) {
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
}

