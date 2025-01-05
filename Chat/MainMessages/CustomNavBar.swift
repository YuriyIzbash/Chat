//
//  CustomNavBar.swift
//  Chat
//
//  Created by YURIY IZBASH on 5. 1. 25.
//

import SwiftUI

struct CustomNavBar: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var shouldShowLogOutOptions: Bool
    @Bindable var viewModel: MainMessagesViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            ChatUserImageView(imageUrl: viewModel.chatUser?.profileImageUrl, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.chatUser?.username ?? "")")
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

