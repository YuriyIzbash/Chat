//
//  ChatLogView.swift
//  Chat
//
//  Created by YURIY IZBASH on 3. 1. 25.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    @State var chatText: String = ""
    
    var body: some View {
        VStack {
            messagesView
            
            chatBottomBar
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Very interesting message \(num)")
                            .foregroundStyle(Color.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
            //                TextField("Description", text: $chatText)
            //                    .font(.title3)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $chatText)
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text("Type here").fontWeight(.light).foregroundColor(.black.opacity(0.25)).padding(8).hidden(!chatText.isEmpty)
            }
            Button {
                
            } label: {
                Text("Send")
                    .font(.headline)
                    .frame(width: 100,height: 40)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: ["uid": "LGbh4z5iMsSwFoG3LjSsxSrDSA62","email": "test7@test.com"]))
    }
}

extension View {
    @ViewBuilder public func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
