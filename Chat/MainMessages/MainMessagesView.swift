//
//  MainMessagesView.swift
//  Chat
//
//  Created by YURIY IZBASH on 29. 12. 24.
//

import SwiftUI
import Firebase
import FirebaseAuth

class MainMessagesViewModel: ObservableObject {
    
    init () {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser () {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomNavBar(shouldShowLogOutOptions: $shouldShowLogOutOptions)
                
                Divider()
                
                ScrollView {
                    ForEach(0...10, id: \.self) { chat in
                        CellChatView()
                        
                        Divider()
                    }
                }
                .padding()
            }
            .overlay(
                Button {
                    
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
                }, alignment: .bottom)
            .toolbar(.hidden)
//            .navigationTitle("Messages")
        }
    }
}

struct CellChatView: View {
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
    
    var body: some View {
        HStack(spacing: 20) {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("UserName")
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
                        print("Handle sign out")
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
}
