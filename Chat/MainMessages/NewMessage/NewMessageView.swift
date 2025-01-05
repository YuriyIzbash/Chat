//
//  NewMessageView.swift
//  Chat
//
//  Created by YURIY IZBASH on 31. 12. 24.
//

import SwiftUI
import Observation

@Observable
class NawMessageViewModel {
    
    var users = [ChatUser]()
    var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection("users")
            .getDocuments { documentsSnapshot, error in
            if let error {
                self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                self.users.append(.init(data: data))
            })
            
        }
    }
}

struct NewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: NawMessageViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    
                    Button {
                        dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 20) {
                           
                            ChatUserImageView(imageUrl: user.profileImageUrl, size: 50)
                            Text(user.email)
                                .foregroundStyle(Color(.label))
                            Spacer()
                        }
                        .padding()
                    }
                    Divider()
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup (placement: .topBarLeading) {
                    Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                }
            }
        }
    }
}

#Preview {
//   NewMessageView()
    MainMessagesView()
        .environment(MainMessagesViewModel())
}
