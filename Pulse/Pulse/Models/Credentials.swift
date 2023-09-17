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
    
    var withEncryptedPassword: Credentials {
        return Credentials(email: username, password: password?.encode)
    }
    
    init(username: String, password: String?) {
        self.username = username
        self.password = password
    }
    
    init(email: String, password: String?) {
        self.init(username: email, password: password)
    }
    
    init(email: String, accessToken: String?) {
        self.init(email: email, password: accessToken)
    }
    
    init(userId: Int, accessToken: String?) {
        self.init(email: String(userId), password: accessToken)
    }
}
