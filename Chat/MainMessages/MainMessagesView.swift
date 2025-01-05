//
//  MainMessagesView.swift
//  Chat
//
//  Created by YURIY IZBASH on 29. 12. 24.
//

import SwiftUI
import Observation
import Firebase

struct RecentMessage: Identifiable {
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
                        return recentMessage.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
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
    
   

struct MainMessagesView: View {
    @State var shouldShowLogOutOptions: Bool = false
    @State var shouldNavigateToChatLogView: Bool = false
    @State var selectedChatUser: ChatUser? = nil
    @Environment(MainMessagesViewModel.self) private var viewModel
    
    var body: some View {
        if viewModel.isUserCurrentlyLoggedOut {
            LoginView(didCompleteLogin: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
            })
        } else {
            NavigationStack {
                VStack {
                    CustomNavBar(shouldShowLogOutOptions: $shouldShowLogOutOptions, viewModel: viewModel)
                    
                    Divider()
                    
                    ScrollView {
                        ForEach(viewModel.recentMessages) { recentMessage in
                            NavigationLink {
                                Text("Destination")
                            } label: {
                                CellChatView(email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl, text: recentMessage.text, timestamp: recentMessage.timestamp)
                            }
                            
                            Divider()
                        }
                    }
                    .padding()
                }
                .overlay(
                    NewMessageButton(
                        shouldNavigateToChatLogView: $shouldNavigateToChatLogView,
                        selectedChatUser: $selectedChatUser
                    ),
                    alignment: .bottom
                )
                .toolbar(.hidden)
                .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                    if let chatUser = selectedChatUser {
                        ChatLogView(chatUser: chatUser)
                    } else {
                        Text("No chat user selected")
                    }
                }
            }
        }
    }
}

struct NewMessageButton: View {
    @State var showNewMessageScreen: Bool = false
    @Binding var shouldNavigateToChatLogView: Bool
    @Binding var selectedChatUser: ChatUser?

    var body: some View {
        Button {
            showNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                
                Text("+  New Message")
                    .font(.headline)
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.vertical)
            .background(Color.blue)
            .clipShape(Capsule())
            .padding(.horizontal)
            .shadow(radius: 12)
        }
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            NewMessageView(didSelectNewUser: { user in
//                print(user.email)
                self.selectedChatUser = user
                self.shouldNavigateToChatLogView = true
            }, viewModel: NawMessageViewModel())
        }
    }
}

struct CellChatView: View {
    
    let email, profileImageUrl, text: String
    let timestamp: Timestamp

    @Environment(MainMessagesViewModel.self) var viewModel
    
    var body: some View {
        HStack(spacing: 20) {
            ChatUserImageView(imageUrl: profileImageUrl, size: 70)
            
            VStack(alignment: .leading) {
                Text(email)
                    .font(.headline)
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(text)
                    .font(.body)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            Text(timeAgo(from: timestamp))
                .font(.headline)
                .foregroundStyle(Color(.secondaryLabel))
            
        }
        .padding(.vertical, 12)
    }
    func timeAgo(from timestamp: Timestamp) -> String {
        let messageDate = timestamp.dateValue()
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(messageDate)

        if timeInterval < 60 {
            return "\(Int(timeInterval)) s"
        } else if timeInterval < 3600 {
            return "\(Int(timeInterval / 60)) m"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval / 3600)) h"
        } else if timeInterval < 604800 {
            return "\(Int(timeInterval / 86400)) d"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: messageDate)
        }
    }
}

struct CustomNavBar: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var shouldShowLogOutOptions: Bool
    @Bindable var viewModel: MainMessagesViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            ChatUserImageView(imageUrl: viewModel.chatUser?.profileImageUrl, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.chatUser?.email ?? "")")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Circle()
                        .foregroundStyle(.green)
                        .frame(width: 12, height: 12)
                    
                    Text("online")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(.label))
            }
        }
        .padding()
        .confirmationDialog(
                    "Settings",
                    isPresented: $shouldShowLogOutOptions,
                    titleVisibility: .visible
                ) {
                    Button("Sign Out", role: .destructive) {
                        viewModel.handleSignOut()
                    }
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                } message: {
                    Text("What do you want to do?")
                }
    }
}

#Preview {
    MainMessagesView()
        .environment(MainMessagesViewModel())
}
