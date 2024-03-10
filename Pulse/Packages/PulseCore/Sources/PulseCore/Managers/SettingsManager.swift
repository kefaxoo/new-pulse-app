//
//  SettingsManager.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation
import RealmSwift

public final class SettingsManager {
    public static let shared = SettingsManager()
    
    public var localFeatures: LocalFeaturesModel?
    
    // MARK: - Services
    public let soundcloud = SoundcloudAccountModel()
    
    fileprivate init() {
        debugPrint("Realm DB Location:", Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
    }
    
    public func appStarting() {
        self.initRealmVariables()
    }
}

// MARK: -
// MARK: Realm
extension SettingsManager {
    var realmConfiguration: Realm.Configuration {
        let configuration = Realm.Configuration(schemaVersion: 14) { migration, oldSchemaVersion in }
        return configuration
    }
    
    public func initRealmVariables() {
        DispatchQueue.main.async { [weak self] in
            if let model = RealmManager<LocalFeaturesModel>().read().first {
                self?.localFeatures = model
            } else {
                let model = LocalFeaturesModel()
                self?.localFeatures = model
                RealmManager<LocalFeaturesModel>().write(object: model)
            }
        }
    }
}
