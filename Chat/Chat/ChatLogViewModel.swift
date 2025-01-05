//
//  ChatLogViewModel.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Firebase
import FirebaseFirestore

@Observable public final class ChatLogViewModel {
    
    var chatText: String = ""
    var errorMessage: String = ""
    var chatMessages = [ChatMessage]()
    var count = 0
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
                    print("Failed to fetch messages: \(error.localizedDescription)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let chatMessage = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(chatMessage)
                        } catch {
                            print("Error decoding ChatMessage: \(error.localizedDescription)")
                        }
                    }
                })
            }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        let messageData = [
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.timestamp: Date()
        ] as [String: Any]
        
        // Write the message for the sender, in case it's not empty
        if !chatText.isEmpty {
            let senderDocument = FirebaseManager.shared.firestore
                .collection("messages")
                .document(fromId)
                .collection(toId)
                .document()
            
            senderDocument.setData(messageData) { error in
                if let error = error {
                    self.errorMessage = "Failed to send message, error: \(error.localizedDescription)"
                    return
                }
                //            print("Successfully saved message for sender")
                
                self.persistRecentMessage()
                
                self.chatText = ""
                self.count += 1
            }
        }
        
        // If the sender and recipient are the same, avoid duplicate writes
        if fromId != toId {
            let recipientDocument = FirebaseManager.shared.firestore
                .collection("messages")
                .document(toId)
                .collection(fromId)
                .document()
            
            recipientDocument.setData(messageData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save message for recipient, error: \(error.localizedDescription)"
                    return
                }
                //                print("Successfully saved message for recipient")
            }
        }
    }
    
    //Show recent message on the top of newMessageView screen
    private func persistRecentMessage() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        guard let chatUser = chatUser else { return }
        
        let recentDocument =  FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(fromId)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.timestamp: Date(),
            FirebaseConstants.email: chatUser.email,
        ] as [String : Any]
        
        recentDocument.setData(data) {error in
            if let error = error {
                self.errorMessage = "Failed to save recent message, error: \(error.localizedDescription)"
                print("Failed to save recent message, error: \(error.localizedDescription)")
                return
            }
        }
    }
}
