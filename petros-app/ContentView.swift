//
//  ContentView.swift
//  petros-app
//
//  Created by Connor York on 9/20/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    private let foundationArticles = ArticleFetcher.fetchFoundationNightArticles()
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            
            if selectedTab == 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        RecordingsSection()
                        LineBreak()
                        
                        ForEach(Array(foundationArticles.enumerated()), id: \.offset) { index, article in
                            VStack(spacing: 0) {
                                FoundationNightSection(title: article.title, description: article.description)
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
                    Text("\(tabTitles[selectedTab]) Page")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("Coming Soon")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            BottomNavigation(selectedTab: $selectedTab)
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .all)
    }
    
    private var tabTitles: [String] {
        ["Home", "Recordings", "Calendar", "Files", "Something"]
    }
}

struct LineBreak: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
}

struct TopBar: View {
    var body: some View {
        HStack(alignment: .top) {
            Text("Petros")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.leading, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Color(red: 0.7, green: 0.85, blue: 1.0))
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct FoundationNightSection: View {
    let title: String
    let description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IN THE WORLD BUT NOT OF THE WORLD")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(5)
            Text("Listen to the recording")
                .font(.footnote)
                .foregroundColor(.secondary)
        
        }
        .padding([.leading, .bottom, .trailing], 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// When you're ready to add real images, you can simply replace the Image(systemName: "play.circle.fill") with Image("your-image-name") and the layout will remain the same.
struct RecordingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LATEST RECORDINGS")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // October Foundation Night Card
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.7, green: 0.85, blue: 1.0))
                                .frame(width: 200, height: 120)
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("October Foundation Night")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    // September Card
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.7, green: 0.85, blue: 1.0))
                                .frame(width: 200, height: 120)
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("September Foundation Night")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    // August Card
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.7, green: 0.85, blue: 1.0))
                                .frame(width: 200, height: 120)
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("August Foundation Night")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
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
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Text(tabTitles[index])
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == index ? .white : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        Rectangle()
                            .fill(selectedTab == index ? Color(red: 0.1, green: 0.2, blue: 0.6) : Color(red: 0.7, green: 0.85, blue: 1.0))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 0)
        .padding(.bottom, 0)
        .background(
            Rectangle()
                .fill(Color(red: 0.7, green: 0.85, blue: 1.0))
        )
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private var tabTitles: [String] {
        ["Home", "Recordings", "Calendar", "Files", "Something"]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

