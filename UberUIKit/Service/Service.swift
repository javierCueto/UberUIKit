//
//  Service.swift
//  UberUIKit
//
//  Created by Javier Cueto on 12/11/20.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")


struct Service {
    
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid
    private init() { }
    
    func fetchUserData(){
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let fullname = dictionary["fullname"] as? String else  { return }
            print(fullname)
        }
    }
}
