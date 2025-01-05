//
//  ChatMessage.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Firebase

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let fromId, toId, text, profileImageUrl, email: String
    let timestamp: Timestamp
    let documentId: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp(date: Date())
        self.email = data[FirebaseConstants.email] as? String ?? ""
    }
}
