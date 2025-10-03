//
//  ContentView.swift
//  petros-app
//
//  Created by Connor York on 9/20/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedArticle: Article? = nil
    
    private let tabs = [
        (title: "Home", image: "house"),
        (title: "Listen", image: "waveform"),
        (title: "Calendar", image: "calendar"),
        (title: "Files", image: "folder"),
        (title: "Something", image: "ellipsis")
    ]
    
    
    private let foundationArticles = ArticleFetcher.fetchFoundationNightArticles()
    private let latestRecordings = RecordingsFetcher.fetchLatestRecordings()
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(selectedArticle: $selectedArticle)
            
            if let article = selectedArticle {
                SpecificArticleView(article: article, selectedArticle: $selectedArticle)
            } else if selectedTab == 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        RecordingsSection(recordings: latestRecordings)
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
            } else {
                // change
                // Placeholder for other tabs
                VStack {
                    Spacer()
                    Text("\(tabs[selectedTab].title) Page")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("Coming Soon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            BottomNavigation(selectedTab: $selectedTab, tabs: tabs)
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .all)
    }
}

struct LineBreak: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .frame(height: 1)
            .padding(.all, 16)
    }
}

struct TopBar: View {
    @Binding var selectedArticle: Article?
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                if selectedArticle != nil {
                    Button(action: {
                        selectedArticle = nil
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 8)
                }
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text("Petros")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.leading, 16)
            .padding(.vertical, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Color(red: 0.7, green: 0.85, blue: 1.0))
        .ignoresSafeArea(.all, edges: .top)
    }
}


struct ArticleView: View {
    let article: Article
    @Binding var selectedArticle: Article?
    
    var body: some View {
        Button(action: {
            selectedArticle = article
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(article.subtitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text(article.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
                
                Text("Listen to the recording")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// When you're ready to add real images, you can simply replace the Image(systemName: "play.circle.fill") with Image("your-image-name") and the layout will remain the same.
struct RecordingsSection: View {
    let recordings: [Recording]
    
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
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack {
                                Image(recording.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 120)
                                    .clipped()
                                    .cornerRadius(8)
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 50, height: 50)
                                    )
                            }
                            
                            Text(recording.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
    }
}

struct BottomNavigation: View {
    @Binding var selectedTab: Int
    var tabs: [(title: String, image: String)]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0.0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].image)
                            .font(.system(size: 16))
                            .foregroundColor(selectedTab == index ? .white : .primary)
                            .frame(height: 16)
                        
                        Text(tabs[index].title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == index ? .white : .primary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(
                        Rectangle()
                            .fill(selectedTab == index ? Color(red: 0.1, green: 0.2, blue: 0.6) : Color(red: 0.7, green: 0.85, blue: 1.0))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 0)
        .padding(.bottom, 0)
        .background(
            Rectangle()
                .fill(Color(red: 0.7, green: 0.85, blue: 1.0))
        )
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct SpecificArticleView: View {
    let article: Article
    @Binding var selectedArticle: Article?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(article.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                
                // Subtitle
                Text(article.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                LineBreak()
                
                // Body content
                Text(article.body)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                
                // Listen section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.6))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Listen to Recording")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Tap to play the audio recording")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            }
        }
        .background(Color.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.portrait)
    }
}

