//
//  LocalFeatureModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation
import RealmSwift

final class LocalFeatureModel: Object {
    @Persisted dynamic var prod  = false
    @Persisted dynamic var debug = false
    
    convenience init(prod: Bool, debug: Bool) {
        self.init()
        self.prod = prod
        self.debug = debug
    }
}
