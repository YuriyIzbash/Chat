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

    @Environment(MainMessagesViewModel.self) var viewModel
    
    var body: some View {
        HStack(spacing: 20) {
            ChatUserImageView(imageUrl: profileImageUrl, size: 70)
            
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
//    func timeAgo(from timestamp: Timestamp) -> String {
//        let messageDate = timestamp.dateValue()
//        let currentDate = Date()
//        let timeInterval = currentDate.timeIntervalSince(messageDate)
//
//        if timeInterval < 60 {
//            return "\(Int(timeInterval)) s"
//        } else if timeInterval < 3600 {
//            return "\(Int(timeInterval / 60)) m"
//        } else if timeInterval < 86400 {
//            return "\(Int(timeInterval / 3600)) h"
//        } else if timeInterval < 604800 {
//            return "\(Int(timeInterval / 86400)) d"
//        } else {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .short
//            return formatter.string(from: messageDate)
//        }
//    }
}

