//
//  ChatUserImageView.swift
//  Chat
//
//  Created by YURIY IZBASH on 31. 12. 24.
//

import SwiftUI

struct ChatUserImageView: View {
    let imageUrl: String?
    
    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
        } else {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
        }
    }
}
