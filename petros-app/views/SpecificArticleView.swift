//
//  SpecificArticleView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

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

