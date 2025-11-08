//
//  BottomNavigation.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

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

