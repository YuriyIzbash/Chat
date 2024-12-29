//
//  ChatApp.swift
//  Chat
//
//  Created by YURIY IZBASH on 27. 12. 24.
//

import SwiftUI

@main
struct ChatApp: App {
    @State var viewModel = MainMessagesViewModel()
    var body: some Scene {
        WindowGroup {
            MainMessagesView(viewModel: viewModel)
        }
    }
}
