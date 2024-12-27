//
//  ContentView.swift
//  Chat
//
//  Created by YURIY IZBASH on 27. 12. 24.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email: String = ""
    @State var password: String = ""
    
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
                        Button {
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 65))
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
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log in" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
            
        }
    }
    private func handleAction() {
        if isLoginMode {
            print("Log in...")
        } else {
            print("Create account...")
        }
    }
}

#Preview {
    LoginView()
}
