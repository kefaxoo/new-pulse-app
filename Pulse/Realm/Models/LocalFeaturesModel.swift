//
//  LocalFeaturesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation
import RealmSwift

final class LocalFeaturesModel: Object {
    @Persisted dynamic var newSign      : LocalFeatureModel?
    @Persisted dynamic var newLibrary   : LocalFeatureModel?
    @Persisted dynamic var newSoundcloud: LocalFeatureModel?
    
    convenience init(newSign: LocalFeatureModel) {
        self.init()
        self.newSign = newSign
    }
}
