//
//  FirebaseManager.swift
//  Chat
//
//  Created by YURIY IZBASH on 29. 12. 24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    private override init() {
        FirebaseApp.configure()
        
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        super.init()
    }
}
