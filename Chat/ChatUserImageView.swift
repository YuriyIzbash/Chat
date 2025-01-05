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
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
            } placeholder: {
                ProgressView()
                    .frame(width: size, height: size)
            }
        } else {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
        }
    }
}
