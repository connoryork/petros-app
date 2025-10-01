//
//  RecordingsFetcher.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import Foundation

class RecordingsFetcher {
    static func fetchLatestRecordings() -> [Recording] {
        return [
            Recording(
                title: "October Foundation Night",
                date: "October 2024",
                description: "Join us for our October Foundation Night gathering as we explore deeper truths and strengthen our community bonds."
            ),
            Recording(
                title: "September Foundation Night",
                date: "September 2024",
                description: "Our September Foundation Night featured inspiring messages and meaningful fellowship with our community."
            ),
            Recording(
                title: "August Foundation Night",
                date: "August 2024",
                description: "August's Foundation Night brought together wisdom, worship, and wonderful community connections."
            ),
            Recording(
                title: "July Foundation Night",
                date: "July 2024",
                description: "Summer Foundation Night with powerful teaching and uplifting worship experiences."
            ),
            Recording(
                title: "June Foundation Night",
                date: "June 2024",
                description: "June's gathering focused on growth, grace, and the foundations of our faith journey."
            )
        ]
    }
}
