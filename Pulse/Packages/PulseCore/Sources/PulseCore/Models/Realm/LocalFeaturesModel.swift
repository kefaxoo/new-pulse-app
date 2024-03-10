//
//  LocalFeaturesModel.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation
import RealmSwift

public final class LocalFeaturesModel: Object {
    @Persisted dynamic var defaultModel: LocalFeatureModel?
}
