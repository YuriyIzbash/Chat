//
//  ChatLogViewModel.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import Foundation
import Firebase
import FirebaseFirestore

@Observable class ChatLogViewModel {
    
    var chatText: String = ""
    var errorMessage: String = ""
    var chatMessages = [ChatMessage]()
    var count = 0
    var chatUser: ChatUser?
    var firestoreListener: ListenerRegistration?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    func fetchMessages() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
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
                            if let chatMessage = try? change.document.data(as: ChatMessage.self) {
                                self.chatMessages.append(chatMessage)
                            }
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
    func persistRecentMessage() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        guard let chatUser = chatUser else { return }

        // Data for the sender's recent messages
        let senderData = [
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.timestamp: Date(),
            FirebaseConstants.email: chatUser.email
        ] as [String: Any]

        // Update the sender's recent messages
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(fromId)
            .collection("messages")
            .document(toId)
            .setData(senderData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recent message for sender: \(error.localizedDescription)"
                    print("Failed to save recent message for sender: \(error.localizedDescription)")
                    return
                }
            }

        // Fetch the sender's profile image URL from Firestore
        FirebaseManager.shared.firestore
            .collection("users")
            .document(fromId)
            .getDocument { document, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch sender's profile image URL: \(error.localizedDescription)"
                    print("Failed to fetch sender's profile image URL: \(error.localizedDescription)")
                    return
                }
                
                guard let data = document?.data(),
                      let senderProfileImageUrl = data["profileImageUrl"] as? String,
                      let senderEmail = data["email"] as? String else {
                    print("Sender's data is incomplete.")
                    return
                }
                
                // Data for the recipient's recent messages
                let recipientData = [
                    FirebaseConstants.text: self.chatText,
                    FirebaseConstants.fromId: fromId,
                    FirebaseConstants.toId: toId,
                    FirebaseConstants.profileImageUrl: senderProfileImageUrl,
                    FirebaseConstants.timestamp: Date(),
                    FirebaseConstants.email: senderEmail
                ] as [String: Any]

                // Update the recipient's recent messages
                FirebaseManager.shared.firestore
                    .collection("recent_messages")
                    .document(toId)
                    .collection("messages")
                    .document(fromId)
                    .setData(recipientData) { error in
                        if let error = error {
                            self.errorMessage = "Failed to save recent message for recipient: \(error.localizedDescription)"
                            print("Failed to save recent message for recipient: \(error.localizedDescription)")
                            return
                        }
                    }
            }
    }
}
