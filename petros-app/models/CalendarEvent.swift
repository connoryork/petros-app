//
//  CalendarEvent.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import Foundation

struct CalendarEvent: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let address: String
}

