//
//  MediaPlayerBar.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct MediaPlayerBar: View {
    let recording: Recording
    @Binding var isPlaying: Bool
    let onPlayPause: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Play/Pause Button
            Button(action: {
                onPlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Recording Title
            Text(recording.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Close Button
            Button(action: {
                onClose()
            }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color(red: 0.1, green: 0.2, blue: 0.6))
        )
    }
}

