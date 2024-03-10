//
//  LocalFeatureModel.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation
import RealmSwift

public final class LocalFeatureModel: Object {
    @Persisted public dynamic var prod = false
    @Persisted public dynamic var debug = false
    
    public convenience init(prod: Bool, debug: Bool) {
        self.init()
        self.prod = prod
        self.debug = debug
    }
}
