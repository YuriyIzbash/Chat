//
//  ContentView.swift
//  Chat
//
//  Created by YURIY IZBASH on 27. 12. 24.
//

import SwiftUI
import FirebaseAuth
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email: String = ""
    @State var password: String = ""
    @State private var avatarImage: UIImage?
    @State private var photosPickerItems: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Picker", selection: $isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if !isLoginMode {
                        PhotosPicker(selection: $photosPickerItems, matching: .images) {
                            Image(uiImage: avatarImage ?? UIImage(resource: .defaultAvatar))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .clipShape(.circle)
                                .padding()
                        }
                    }
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        Text(isLoginMode ? "Log in" : "Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundStyle(.black)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log in" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: photosPickerItems) { _, _ in
            Task {
                if let photosPickerItems,
                   let data = try? await photosPickerItems.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        avatarImage = image
                    }
                }
                photosPickerItems = nil
            }
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to log in: \(error.localizedDescription)")
                self.loginStatusMessage = "Failed to log in: \(error.localizedDescription)"
                return
            }
            
            print("Succeeded logging in: \(result?.user.uid ?? "" )")
            self.loginStatusMessage = "Succeeded logging in: \(result?.user.uid ?? "" )"
        }
    }
    
    
    @State var loginStatusMessage: String = ""
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: \(error.localizedDescription)")
                self.loginStatusMessage = "Failed to create user: \(error.localizedDescription)"
                return
            }
            
            print("Succeeded creating user: \(result?.user.uid ?? "" )")
            self.loginStatusMessage = "Succeeded creating user: \(result?.user.uid ?? "" )"
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
//        _ = UUID().uuidString
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.avatarImage?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metada, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                self.loginStatusMessage = "Failed to upload image: \(error.localizedDescription)"
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to download image: \(error.localizedDescription)")
                    self.loginStatusMessage = "Failed to download image: \(error.localizedDescription)"
                    return
                }
                
                self.loginStatusMessage = "Image uploaded successfully with URL: \(url?.absoluteString ?? "")"
                print(url!.absoluteString)
                
                guard let url = url else { return }
                self.storeUserInfo(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInfo(imageProfileUrl: URL) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["uid": uid, "email": self.email, "profileImageUrl": imageProfileUrl.absoluteString]
        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error {
                print("Error storing user data: \(error.localizedDescription)")
                self.loginStatusMessage = "\(error.localizedDescription)"
                return
            }
            print("Successfully stored user data")
        }
    }
}

#Preview {
    LoginView()
}
