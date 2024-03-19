//
//  LocalFeaturesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation
import RealmSwift

final class LocalFeaturesModel: Object {
    @Persisted dynamic var emptyFeatureObj: LocalFeatureModel?
}
