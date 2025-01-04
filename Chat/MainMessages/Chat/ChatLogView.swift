//
//  ChatLogView.swift
//  Chat
//
//  Created by YURIY IZBASH on 3. 1. 25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
}

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let fromId, toId, text: String
    let documentId: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

@Observable public final class ChatLogViewModel {
    
    var chatText: String = ""
    var errorMessage: String = ""
    var chatMessages = [ChatMessage]()
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
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
                    print("Failed to fetch messages: \(error.localizedDescription)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
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
                    "timestamp": Timestamp()
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
                self.chatText = ""
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
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.viewModel = .init(chatUser: chatUser)
    }
    
    @Bindable var viewModel: ChatLogViewModel
    
    var body: some View {
        VStack {
            messagesView
            Text(viewModel.errorMessage)
            
            chatBottomBar
            
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(viewModel.chatMessages) { message in
                VStack {
                    if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                        HStack {
                            Spacer()
                            HStack {
                                Text(message.text)
                                    .foregroundStyle(Color.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    } else {
                        HStack {
                            HStack {
                                Text(message.text)
                                    .foregroundStyle(Color.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.8, alpha: 1)))
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.chatText)
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text("Type here").fontWeight(.light).foregroundColor(.black.opacity(0.25)).padding(8).hidden(!viewModel.chatText.isEmpty)
            }
            Button {
                viewModel.handleSend()
            } label: {
                Text("Send")
                    .font(.headline)
                    .frame(width: 100,height: 40)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: ["uid": "LGbh4z5iMsSwFoG3LjSsxSrDSA62","email": "test7@test.com"]))
    }
}

extension View {
    @ViewBuilder public func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
