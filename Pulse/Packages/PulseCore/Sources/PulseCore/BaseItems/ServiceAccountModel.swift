//
//  ServiceAccountModel.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import Foundation

public protocol ServiceAccountModel {
    var accessToken: String? { get set }
    var accessTokenKeychainModel: KeychainModel { get set }
    var isSigned: Bool { get }
    
    @discardableResult func signOut() -> Bool
}
