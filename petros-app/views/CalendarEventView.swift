//
//  CalendarEventView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct CalendarEventView: View {
    let event: CalendarEvent
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left side: Name and address
            VStack(alignment: .leading, spacing: 2) {
                Text(event.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(event.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right side: Date
            Text(dateFormatter.string(from: event.date))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

