//
//  ContentView.swift
//  petros-app
//
//  Created by Connor York on 9/20/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedArticle: Article? = nil
    @State private var selectedRecording: Recording? = nil
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    private let tabs = [
        (title: "Home", image: "house"),
        (title: "Calendar", image: "calendar"),
        (title: "TBD", image: "ellipsis"),
        (title: "TBD", image: "ellipsis"),
        (title: "TBD", image: "ellipsis")
    ]
    
    
    private let foundationArticles = ArticleFetcher.fetchFoundationNightArticles()
    private let latestRecordings = RecordingsFetcher.fetchLatestRecordings()
    private let calendarEvents = CalendarEventFetcher.fetchUpcomingEvents()
    
    private func setupAudioPlayer(for recording: Recording) {
        // If we're already playing this recording, no need to recreate the player
        if selectedRecording?.recordingId == recording.recordingId, let player = audioPlayer {
            // Same recording - just restart from beginning if needed
            player.currentTime = 0
            playAudio()
            return
        }
        
        // Different recording - stop and recreate the player
        audioPlayer?.stop()
        audioPlayer = nil
        
        guard let url = Bundle.main.url(forResource: recording.recordingId.replacingOccurrences(of: ".m4a", with: ""), withExtension: "m4a") else {
            print("Could not find audio file: \(recording.recordingId)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            playAudio()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func playAudio() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    private func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        selectedRecording = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(selectedArticle: $selectedArticle)
            
            if let article = selectedArticle {
                SpecificArticleView(article: article, selectedArticle: $selectedArticle)
            } else if selectedTab == 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        RecordingsSection(recordings: latestRecordings, selectedRecording: $selectedRecording, isPlaying: $isPlaying)
                        LineBreak()
                        
                        ForEach(Array(foundationArticles.enumerated()), id: \.offset) { index, article in
                            VStack(spacing: 0) {
                                ArticleView(article: article, selectedArticle: $selectedArticle)
                                if index < foundationArticles.count - 1 {
                                    LineBreak()
                                }
                            }
                        }
                    }
                    .background(Color.white)
                }
                .background(Color.white)
            } else if selectedTab == 1 {
                CalendarView(events: calendarEvents)
            } else {
                // Placeholder for other tabs
                VStack {
                    Spacer()
                    Text("\(tabs[selectedTab].title)")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("Coming Soon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            // Media Player Bar (shown when a recording is selected)
            if let recording = selectedRecording {
                MediaPlayerBar(
                    recording: recording,
                    isPlaying: $isPlaying,
                    onPlayPause: {
                        if isPlaying {
                            pauseAudio()
                        } else {
                            playAudio()
                        }
                    },
                    onClose: {
                        stopAudio()
                    }
                )
                .onAppear {
                    setupAudioPlayer(for: recording)
                }
                .onChange(of: selectedRecording) { newRecording in
                    guard let recording = newRecording else { return }
                    setupAudioPlayer(for: recording)
                }
            }
            
            BottomNavigation(selectedTab: $selectedTab, tabs: tabs)
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}

