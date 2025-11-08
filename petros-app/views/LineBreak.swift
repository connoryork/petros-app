//
//  LineBreak.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct LineBreak: View {
    static let DEFAULT_PADDING: CGFloat = 16
    
    var verticalPadding: CGFloat = DEFAULT_PADDING
    
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .frame(height: 1)
            .padding(.horizontal, LineBreak.DEFAULT_PADDING)
            .padding(.vertical, verticalPadding)
    }
}

