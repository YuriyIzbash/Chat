//
//  MainMessagesView.swift
//  Chat
//
//  Created by YURIY IZBASH on 29. 12. 24.
//

import SwiftUI

struct MainMessagesView: View {
    @State var shouldShowLogOutOptions: Bool = false
    @State var shouldNavigateToChatLogView: Bool = false
    @State var selectedChatUser: ChatUser? = nil
    @Environment(MainMessagesViewModel.self) private var viewModel
    var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    var body: some View {
        if viewModel.isUserCurrentlyLoggedOut {
            LoginView(didCompleteLogin: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
                self.viewModel.fetchRecentMessages()
            })
        } else {
            NavigationStack {
                VStack {
                    CustomNavBar(shouldShowLogOutOptions: $shouldShowLogOutOptions, viewModel: viewModel)
                    
                    Divider()
                    
                    ScrollView {
                        ForEach(viewModel.recentMessages) { recentMessage in
                            Button {
                                let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                                self.selectedChatUser = .init(data: [
                                    FirebaseConstants.email: recentMessage.email,
                                    FirebaseConstants.profileImageUrl: recentMessage.profileImageUrl,
                                    "uid": uid,
                                ])
                                self.chatLogViewModel.chatUser = self.selectedChatUser
                                self.chatLogViewModel.fetchMessages()
                                self.shouldNavigateToChatLogView.toggle()
                            } label: {
                                CellChatView(username: recentMessage.username, profileImageUrl: recentMessage.profileImageUrl, text: recentMessage.text, timeAgo: recentMessage.timeAgo)
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
                        ChatLogView(viewModel: chatLogViewModel)
                    } else {
                        Text("No chat user selected")
                    }
                }
            }
        }
    }
}

#Preview {
    MainMessagesView()
        .environment(MainMessagesViewModel())
}
