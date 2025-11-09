//
//  HomeView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct HomeView: View {
    let recordings: [Recording]
    let foundationArticles: [Article]
    @Binding var selectedRecording: Recording?
    @Binding var isPlaying: Bool
    @Binding var selectedArticle: Article?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RecordingsSection(recordings: recordings, selectedRecording: $selectedRecording, isPlaying: $isPlaying)
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
    }
}

