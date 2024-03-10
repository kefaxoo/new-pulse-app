//
//  KeychainModel+Ext.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import Foundation
import PulseBaseItems

extension KeychainModel {
    convenience init(service: Constants.KeychainServices) {
        self.init(service: service.rawValue)
    }
}
