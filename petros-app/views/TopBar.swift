//
//  TopBar.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

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

