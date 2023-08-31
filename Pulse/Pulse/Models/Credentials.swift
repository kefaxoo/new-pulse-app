//
//  Credentials.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

struct Credentials {
    let username: String
    let password: String?
    
    init(username: String, password: String?) {
        self.username = username
        self.password = password
    }
    
    init(email: String, password: String?) {
        self.username = email
        self.password = password
    }
    
    func saveToKeychain(accountName: String) {
        
    }
}
