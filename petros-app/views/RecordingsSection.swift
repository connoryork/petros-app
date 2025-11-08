//
//  RecordingsSection.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct RecordingsSection: View {
    let recordings: [Recording]
    @Binding var selectedRecording: Recording?
    @Binding var isPlaying: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LATEST RECORDINGS")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recordings, id: \.title) { recording in
                        let isSelected = selectedRecording == recording
                        
                        Button(action: {
                            // Only allow action if not selected
                            if !isSelected {
                                selectedRecording = recording
                                isPlaying = true
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack {
                                    Image(recording.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                        .grayscale(isSelected ? 0.8 : 0)
                                        .opacity(isSelected ? 0.6 : 1.0)
                                    
                                    if isSelected {
                                        // Show "Playing" text when selected
                                        VStack {
                                            Image(systemName: "waveform")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                            Text("Playing")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.black.opacity(0.6))
                                        )
                                    } else {
                                        // Show play button when not selected
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .fill(Color.black.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                            )
                                    }
                                }
                                
                                Text(recording.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .opacity(isSelected ? 0.6 : 1.0)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isSelected)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
    }
}

