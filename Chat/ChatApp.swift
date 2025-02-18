//
//  ChatApp.swift
//  Chat
//
//  Created by YURIY IZBASH on 27. 12. 24.
//

import SwiftUI

@main
struct ChatApp: App {
    
    @State private var viewModel = MainMessagesViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainMessagesView()
                .environment(viewModel)
        }
    }
}
