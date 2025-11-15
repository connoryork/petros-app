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

    @State private var calendarEvents: [CalendarEvent] = []
    @State private var isCalendarLoading = false
    @State private var calendarErrorMessage: String? = nil
    @State private var usedFallbackEvents = false

    private let tabs = [
        (title: "Home", image: "house"),
        (title: "Calendar", image: "calendar"),
        (title: "TBD", image: "ellipsis"),
        (title: "TBD", image: "ellipsis"),
        (title: "TBD", image: "ellipsis")
    ]

    private let foundationArticles = ArticleFetcher.fetchFoundationNightArticles()
    private let latestRecordings = RecordingsFetcher.fetchLatestRecordings()

    private func setupAudioPlayer(for recording: Recording) {
        if selectedRecording?.recordingId == recording.recordingId, let player = audioPlayer {
            player.currentTime = 0
            playAudio()
            return
        }

        audioPlayer?.stop()
        audioPlayer = nil

        guard let url = Bundle.main.url(
            forResource: recording.recordingId.replacingOccurrences(of: ".m4a", with: ""),
            withExtension: "m4a"
        ) else {
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

    private func loadCalendarEvents(force: Bool = false) async {
        let shouldProceed = await MainActor.run { () -> Bool in
            if isCalendarLoading && !force {
                return false
            }

            isCalendarLoading = true
            if force {
                calendarErrorMessage = nil
            }
            return true
        }

        guard shouldProceed else { return }

        let result = await CalendarEventFetcher.fetchUpcomingEvents()

        await MainActor.run {
            calendarEvents = result.events
            usedFallbackEvents = result.usedFallback
            isCalendarLoading = false

            if let error = result.error, result.usedFallback {
                calendarErrorMessage = error.localizedDescription
            } else if result.events.isEmpty {
                calendarErrorMessage = "No upcoming events found."
            } else {
                calendarErrorMessage = nil
            }
        }
    }

    private func refreshCalendarEvents() {
        Task {
            await loadCalendarEvents(force: true)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(selectedArticle: $selectedArticle)

            if let article = selectedArticle {
                SpecificArticleView(article: article, selectedArticle: $selectedArticle)
            } else if selectedTab == 0 {
                HomeView(
                    recordings: latestRecordings,
                    foundationArticles: foundationArticles,
                    selectedRecording: $selectedRecording,
                    isPlaying: $isPlaying,
                    selectedArticle: $selectedArticle
                )
            } else if selectedTab == 1 {
                CalendarView(
                    events: calendarEvents,
                    isLoading: isCalendarLoading,
                    errorMessage: calendarErrorMessage,
                    usedFallback: usedFallbackEvents,
                    onRetry: refreshCalendarEvents
                )
            } else {
                TBDView(title: tabs[selectedTab].title)
            }

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
        .ignoresSafeArea(.all, edges: .bottom)
        .task {
            await loadCalendarEvents()
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 && calendarEvents.isEmpty && !isCalendarLoading {
                Task {
                    await loadCalendarEvents()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
