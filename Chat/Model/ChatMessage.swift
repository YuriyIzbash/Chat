//
//  ChatMessage.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
