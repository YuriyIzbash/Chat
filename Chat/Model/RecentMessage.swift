//
//  RecentMessage.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    let fromId, toId, text, profileImageUrl, email: String
    let timestamp: Date
    
    var username: String {
            email.components(separatedBy: "@").first ?? email
        }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
