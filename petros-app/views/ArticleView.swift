//
//  ArticleView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

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

