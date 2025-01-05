//
//  ChatUser.swift
//  Chat
//
//  Created by YURIY IZBASH on 29. 12. 24.
//

import Foundation

struct ChatUser: Identifiable, Hashable {
    
    var id: String { uid }
    let uid, email, profileImageUrl: String
    
    var username: String {
            email.components(separatedBy: "@").first ?? email
        }
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
