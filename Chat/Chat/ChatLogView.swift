//
//  ChatLogView.swift
//  Chat
//
//  Created by YURIY IZBASH on 3. 1. 25.
//

import SwiftUI

struct ChatLogView: View {
    
    @State private var isUserScrolledUp: Bool = false
    @State private var isAtBottom: Bool = true
    @Bindable var viewModel: ChatLogViewModel
    
    var body: some View {
        VStack {
            messagesView
            
            chatBottomBar
        }
        .navigationTitle(viewModel.chatUser?.username ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.firestoreListener?.remove()
        }
    }
    
    private var messagesView: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                    }
                    .frame(height: 0) // Invisible spacer for tracking scroll position

                    VStack {
                        ForEach(viewModel.chatMessages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                        HStack { Spacer() }
                            .id("BottomAnchor")
                    }
                }
                .background(Color(.init(white: 0.8, alpha: 1)))
                                .overlay(
                    scrollToBottomButton(proxy: proxy)
                        .padding(.bottom, 20),
                    alignment: .bottomTrailing
                )
                .onAppear {
                    // Scroll to the bottom when the view appears
                    if let lastMessageID = viewModel.chatMessages.last?.id {
                        proxy.scrollTo(lastMessageID, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.chatMessages.count) {
                    // Scroll to the latest message when the count changes
                    if isAtBottom {
                        withAnimation {
                            proxy.scrollTo("BottomAnchor", anchor: .bottom)
                        }
                    }
                }
            }
        }

    @ViewBuilder
        private func scrollToBottomButton(proxy: ScrollViewProxy) -> some View {
            Button(action: {
                withAnimation {
                    proxy.scrollTo("BottomAnchor", anchor: .bottom)
                }
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    .padding(4)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            .opacity(isUserScrolledUp ? 0 : 1)
            .animation(.easeInOut, value: isUserScrolledUp)
        }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.chatText)
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text("Type here").fontWeight(.light).foregroundColor(.black.opacity(0.25)).padding(8).hidden(!viewModel.chatText.isEmpty)
            }
            Button {
                viewModel.handleSend()
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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
