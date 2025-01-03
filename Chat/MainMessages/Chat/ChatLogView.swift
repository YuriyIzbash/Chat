//
//  ChatLogView.swift
//  Chat
//
//  Created by YURIY IZBASH on 3. 1. 25.
//

import SwiftUI
import Firebase

@Observable public final class ChatLogViewModel {
    
    var chatText: String = ""
    var errorMessage: String = ""
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
        
        let messageData = ["fromId": fromId, "toId": toId, "text": self.chatText, "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            if let error {
                self.errorMessage = "Failed to send message, error: \(error.localizedDescription)"
                return
            }
            print("Successfully saved current message")
            self.chatText = ""
        }
        
        let recipientMessageDociment = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        recipientMessageDociment.setData(messageData) { error in
            if let error {
                self.errorMessage = "Failed to send message, error: \(error.localizedDescription)"
                return
            }
            print("Successfully saved recipient message")
        }
    }
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.viewModel = .init(chatUser: chatUser)
    }
    
    @State private var viewModel: ChatLogViewModel
    
    var body: some View {
        VStack {
            messagesView
            
            chatBottomBar
                
        }
        .environment(viewModel)
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Very interesting message \(num)")
                            .foregroundStyle(Color.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
            //                TextField("Description", text: $chatText)
            //                    .font(.title3)
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
        ChatLogView(chatUser: .init(data: ["email": "test@test.com", "uid": "test"]))
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
