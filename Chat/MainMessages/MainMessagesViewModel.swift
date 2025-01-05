//
//  MainMessagesViewModel.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Observation
import Firebase

@Observable public final class MainMessagesViewModel {
    var errorMessage = ""
    var chatUser: ChatUser?
    var isUserCurrentlyLoggedOut = false
    var recentMessages = [RecentMessage]()
    
    init () {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    private func fetchRecentMessages () {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
//        guard let toId = chatUser?.uid else { return }
//        guard let chatUser = chatUser else { return }
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(fromId)
            .collection("messages")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen to recent message, error: \(error.localizedDescription)"
                    print("Failed to listen to recent message, error: \(error.localizedDescription)")
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        let recentMessage = try change.document.data(as: RecentMessage.self)
                        self.recentMessages.insert(recentMessage, at: 0)
                    } catch {
                        print("Error decoding RecentMessage: \(error.localizedDescription)")
                    }
                })
            }
    }
    
    func fetchCurrentUser () {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "\nCould not find firebase uid"
            return }
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error.localizedDescription)"
                print("Failed to fetch current user: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return }

//            self.errorMessage = "Data: \(data)"
            
            self.chatUser = .init(data: data)
            
//            self.errorMessage = chatUser.profileImageUrl
        }
}
    func handleSignOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            isUserCurrentlyLoggedOut = true
            } catch let signOutError as NSError {
                errorMessage = "Failed to sign out: \(signOutError.localizedDescription)"
                print("Error signing out: \(signOutError.localizedDescription)")
            }
    }
}
