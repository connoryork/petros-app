//
//  CalendarView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct CalendarView: View {
    let events: [CalendarEvent]
    
    var body: some View {
        ScrollView {
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
            .background(Color.white)
        }
        .background(Color.white)
    }
}

