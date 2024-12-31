//
//  MainMessagesView.swift
//  Chat
//
//  Created by YURIY IZBASH on 29. 12. 24.
//

import SwiftUI
import Observation

@Observable public final class MainMessagesViewModel {
    var errorMessage = ""
    var chatUser: ChatUser?
    var isUserCurrentlyLoggedOut = false
    
    init () {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser () {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "\nCould not find firebase uid"
            return }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
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
    @Bindable var viewModel: MainMessagesViewModel
    
    var body: some View {
        if viewModel.isUserCurrentlyLoggedOut {
            LoginView(didCompleteLogin: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
            })
        } else {
            NavigationStack {
                VStack {
                    //                Text("Current User id: \(viewModel.errorMessage)")
                    CustomNavBar(shouldShowLogOutOptions: $shouldShowLogOutOptions, viewModel: viewModel)
                    
                    Divider()
                    
                    ScrollView {
                        ForEach(0...10, id: \.self) { chat in
                            CellChatView(viewModel: viewModel)
                            
                            Divider()
                        }
                    }
                    .padding()
                }
                .overlay(
                    NewMessageButton()
                    , alignment: .bottom)
                .toolbar(.hidden)
                //            .navigationTitle("Messages")
            }
        }
    }
}

struct NewMessageButton: View {
    
    @State var showNewMessageScreen: Bool = false
    
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
            NewMessageView()
        }
    }
}

struct CellChatView: View {
    
    @Bindable var viewModel: MainMessagesViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.label), lineWidth: 1))
            
            VStack(alignment: .leading) {
                Text("UserName")
                    .font(.headline)
                
                Text("Message")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("Date")
                .font(.headline)
            
        }
        .padding()
    }
}

struct CustomNavBar: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var shouldShowLogOutOptions: Bool
    @Bindable var viewModel: MainMessagesViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            ChatUserImageView(imageUrl: viewModel.chatUser?.profileImageUrl)
            
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
    MainMessagesView(viewModel: MainMessagesViewModel())
}
