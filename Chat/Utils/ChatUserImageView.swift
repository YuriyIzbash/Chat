//
//  ChatUserImageView.swift
//  Chat
//
//  Created by YURIY IZBASH on 31. 12. 24.
//

import SwiftUI

struct ChatUserImageView: View {
    let imageUrl: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    PlaceholderView(size: size)
                }
            } else {
                PlaceholderView(size: size)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.black, lineWidth: 1))
    }
}

struct PlaceholderView: View {
    let size: CGFloat

    var body: some View {
        Image("defaultAvatar")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
    }
}
