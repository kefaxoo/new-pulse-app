//
//  SettingsManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import RealmSwift

final class SettingsManager {
    static let shared = SettingsManager()
    
    fileprivate init() {
        debugLog("Realm DB Location:", Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
    }
    
    func initRealmVariables() {
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
    
    var pulse = PulseModel()
    var soundcloud = SoundcloudModel()
    
    var color: ColorType {
        get {
            return ColorType(
                rawValue: UserDefaults.standard.value(
                    forKey: Constants.UserDefaultsKeys.colorType.rawValue
                ) as? String ?? ""
            ) ?? .purple
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKeys.colorType.rawValue)
            
            MainCoordinator.shared.mainTabBarController.viewControllers?.forEach({
                ($0 as? UINavigationController)?.navigationBar.tintColor = newValue.color
            })
        }
    }
    
    // MARK: Realm configuration
    var realmConfiguration: Realm.Configuration {
        let configuration = Realm.Configuration(schemaVersion: 10) { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["shareLink"] = ""
                }
            }
            
            if oldSchemaVersion < 3 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["extension"] = ""
                }
            }
            
            if oldSchemaVersion < 4 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["source"] = "muffon"
                }
            }
            
            if oldSchemaVersion < 5 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["trackFilename"] = ""
                }
            }
            
            if oldSchemaVersion < 6 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["isSynced"] = false
                }
            }
            
            if oldSchemaVersion < 7 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["dateAdded"] = 0
                }
            }
            
            if oldSchemaVersion < 8 {
                migration.enumerateObjects(ofType: LocalFeaturesModel.className()) { _, newObject in
                    newObject?["newLibrary"] = LocalFeatureModel(prod: false, debug: false)
                }
            }
            
            if oldSchemaVersion < 9 {
                migration.enumerateObjects(ofType: LocalFeaturesModel.className()) { _, newObject in
                    newObject?["newSoundcloud"] = LocalFeatureModel(prod: false, debug: false)
                }
            }
            
            if oldSchemaVersion < 10 {
                migration.enumerateObjects(ofType: LocalFeaturesModel.className()) { _, newObject in
                    newObject?["searchSoundcloudPlaylists"] = LocalFeatureModel(prod: false, debug: false)
                }
            }
        }
        
        return configuration
    }
    
    // MARK: General settings
    var isAdultContentEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.isAdultContentEnabled.rawValue) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.isAdultContentEnabled.rawValue)
        }
    }
    
    var isCanvasesEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.isCanvasesEnabled.rawValue) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.isCanvasesEnabled.rawValue)
        }
    }
    
    var autoDownload: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.autoDownload.rawValue) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.autoDownload.rawValue)
            
            guard newValue else { return }
            
            RealmManager<LibraryTrackModel>().read().map({ TrackModel($0) }).forEach({ DownloadManager.shared.addTrackToQueue($0) })
        }
    }
    
    // MARK: Soundcloud settings
    var soundcloudLike: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.soundcloudLike.rawValue) as? Bool ?? false
        } set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.soundcloudLike.rawValue)
        }
    }
    
    let featuresKeys = ["newSign", "newLibrary", "newSoundcloud", "nowPlayingVC", "searchSoundcloudPlaylists"]
    var localFeatures = LocalFeaturesModel()
    var featuresLastUpdate: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.featuresLastUpdate.rawValue) as? Int ?? 0
        } set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.featuresLastUpdate.rawValue)
        }
    }
    
    var shouldUpdateFeatures: Bool {
        guard AppEnvironment.current.isRelease else { return true }
        
        return Int(Date().timeIntervalSince1970) - self.featuresLastUpdate >= 86400
    }
    
    func updateFeatures(completion: @escaping(() -> ())) {
        guard self.shouldUpdateFeatures else {
            completion()
            return
        }
        
        PulseProvider.shared.features { [weak self] features in
            guard let features else {
                completion()
                return
            }
            
            self?.updateFeatures(features: features)
            completion()
        }
    }
    
    private func updateFeatures(features: PulseFeatures) {
        self.featuresLastUpdate = Int(Date().timeIntervalSince1970)
        DispatchQueue.main.async {
            RealmManager<LocalFeatureModel>().read().forEach { obj in
                RealmManager<LocalFeatureModel>().delete(object: obj)
            }
            
            RealmManager<LocalFeaturesModel>().update { realm in
                try? realm.write {
                    self.localFeatures.newSign                   = features.newSign?.toRealmModel
                    self.localFeatures.newLibrary                = features.newLibrary?.toRealmModel
                    self.localFeatures.newSoundcloud             = features.newSoundcloud?.toRealmModel
                    self.localFeatures.nowPlayingVC              = features.nowPlayingVC?.toRealmModel
                    self.localFeatures.searchSoundcloudPlaylists = features.searchSoundcloudPlaylists?.toRealmModel
                }
            }
        }
    }
}

// MARK: -
// MARK: Sign out
extension SettingsManager {
    func signOut() -> Bool {
        autoDownload = false
        isAdultContentEnabled = false
        isCanvasesEnabled = false
        soundcloudLike = false
        
        _ = pulse.signOut()
        _ = soundcloud.signOut()
        
        return true
    }
}
