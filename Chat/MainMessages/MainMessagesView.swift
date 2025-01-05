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
                        ChatLogView(chatUser: chatUser)
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
