//
//  Credentials.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import Foundation

public struct Credentials {
    public let username: String
    public let password: String?
    
    public init(username: String, password: String?) {
        self.username = username
        self.password = password
    }
    
    public init(email: String, password: String?) {
        self.init(username: email, password: password)
    }
    
    public init(email: String, accessToken: String?) {
        self.init(username: email, password: accessToken)
    }
    
    public init(userId: Int, accessToken: String?) {
        self.init(username: String(userId), password: accessToken)
    }
    
    public init(service: String, accessToken: String?) {
        self.init(username: service, password: accessToken)
    }
}
