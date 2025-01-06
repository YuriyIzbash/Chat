//
//  CellChatView.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import SwiftUI
import Firebase


struct CellChatView: View {
    
    let username, profileImageUrl, text: String
    let timeAgo: String

    @Environment(MainMessagesViewModel.self) private var viewModel
    
    private var shouldBustCache: Bool {
            // Add logic to determine if cache-busting is required
            // For example, check if profile image updates frequently
            true // or false depending on your app's requirements
        }
    
    var body: some View {
        HStack(spacing: 20) {
            // Cache-busting applied only if needed
            let finalImageUrl = profileImageUrl + (shouldBustCache ? "?t=\(Date().timeIntervalSince1970)" : "")
                        ChatUserImageView(imageUrl: finalImageUrl, size: 70)
            
            VStack(alignment: .leading) {
                Text(username)
                    .font(.headline)
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(text)
                    .font(.body)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            Text(timeAgo)
                .font(.headline)
                .foregroundStyle(Color(.secondaryLabel))
            
        }
        .padding(.vertical, 12)
    }
}

