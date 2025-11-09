//
//  TBDView.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import SwiftUI

struct TBDView: View {
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(.title)
                .foregroundColor(.secondary)
            Text("Coming Soon")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

