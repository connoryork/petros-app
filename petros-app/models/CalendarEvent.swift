//
//  CalendarEvent.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import Foundation

struct CalendarEvent: Identifiable {
    let id: String
    let name: String
    let date: Date
    let endDate: Date?
    let address: String
    let details: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        date: Date,
        endDate: Date? = nil,
        address: String,
        details: String? = nil
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.endDate = endDate
        self.address = address
        self.details = details
    }
}
