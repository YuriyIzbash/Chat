//
//  NewMessageButton.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import SwiftUI

struct NewMessageButton: View {
    @State var showNewMessageScreen: Bool = false
    @Binding var shouldNavigateToChatLogView: Bool
    @Binding var selectedChatUser: ChatUser?
    var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    

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
                self.selectedChatUser = user
                self.shouldNavigateToChatLogView.toggle()
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            }, viewModel: NawMessageViewModel())
        }
    }
}
