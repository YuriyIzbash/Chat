//
//  NewMessageViewModel.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Observation

@Observable
class NawMessageViewModel {
    
    var users = [ChatUser]()
    var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection("users")
            .getDocuments { documentsSnapshot, error in
            if let error {
                self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                self.users.append(.init(data: data))
            })
            
        }
    }
}
