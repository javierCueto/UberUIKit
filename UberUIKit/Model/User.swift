//
//  User.swift
//  UberUIKit
//
//  Created by Javier Cueto on 12/11/20.
//

import CoreLocation
struct User {
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    let uid: String
    
    init(uid: String, dictionary: [String: Any]){
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountTyoe"] as? Int ?? 0
    }
}
