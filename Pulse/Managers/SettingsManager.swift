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
        if NetworkManager.shared.isReachable {
            PulseProvider.shared.deviceInfo { [weak self] deviceInfo in
                guard let deviceInfo else { return }
                
                self?.deviceModel = deviceInfo.model
            }
        }
    }
    
    func initRealmVariables() {
        DispatchQueue.main.async { [weak self] in
            if let model = RealmManager<LocalFeaturesModel>().read().first {
                self?.settings.localFeatures = model
            } else {
                let model = LocalFeaturesModel()
                self?.settings.localFeatures = model
                RealmManager<LocalFeaturesModel>().write(object: model)
            }
        }
    }
    
    var settings = SettingsModel()
    var pulse = PulseModel()
    var soundcloud = SoundcloudModel()
    var yandexMusic = YandexMusicModel()
    
    var color: ColorType {
        get {
            return ColorType(rawValue: UserDefaults.standard.value(forKey: .colorType) as? String ?? "") ?? .purple
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: .colorType)
            
            MainCoordinator.shared.mainTabBarController.viewControllers?.forEach({
                ($0 as? UINavigationController)?.navigationBar.tintColor = newValue.color
            })
        }
    }
    
    var lastTabBarIndex: Int {
        get {
            return UserDefaults.standard.value(forKey: .lastTabBarIndex) as? Int ?? 1
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .lastTabBarIndex)
        }
    }
    
    // MARK: Realm configuration
    var realmConfiguration: Realm.Configuration {
        let configuration = Realm.Configuration(schemaVersion: 18) { migration, oldSchemaVersion in
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
            
            if oldSchemaVersion < 11 {
                migration.enumerateObjects(ofType: LocalFeaturesModel.className()) { _, newObject in
                    newObject?["muffonYandex"] = LocalFeatureModel(prod: false, debug: false)
                }
            }
            
            if oldSchemaVersion < 12 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["subtitle"] = ""
                }
            }
            
            if oldSchemaVersion < 13 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { _, newObject in
                    newObject?["isExplicit"] = false
                    newObject?["labels"]     = List<String>()
                }
            }
            
            if oldSchemaVersion < 14 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { oldObject, newObject in
                    if let id = oldObject?["id"] {
                        newObject?["id"] = "\(id)"
                    } else {
                        newObject?["id"] = ""
                    }
                }
                
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { oldObject, newObject in
                    if let id = oldObject?["id"] {
                        newObject?["id"] = "\(id)"
                    } else {
                        newObject?["id"] = ""
                    }
                }
            }
            
            if oldSchemaVersion < 18 {
                migration.enumerateObjects(ofType: LocalFeaturesModel.className()) { _, newObject in
                    newObject?["emptyFeatureObj"] = LocalFeatureModel()
                }
            }
        }
        
        return configuration
    }
    
    // MARK: General settings
    var isAdultContentEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: .isAdultContentEnabled) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .isAdultContentEnabled)
        }
    }
    
    var isCanvasesEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: .isCanvasesEnabled) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .isCanvasesEnabled)
        }
    }
    
    var autoDownload: Bool {
        get {
            return UserDefaults.standard.value(forKey: .autoDownload) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .autoDownload)
            
            guard newValue else { return }
            
            RealmManager<LibraryTrackModel>().read().map({ TrackModel($0) }).forEach({ DownloadManager.shared.addTrackToQueue($0) })
        }
    }
    
    var appearance: ApplicationStyle {
        get {
            return ApplicationStyle(rawValue: UserDefaults.standard.value(forKey: .appearance) as? String ?? "") ?? .system
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: .appearance)
            guard let window = MainCoordinator.shared.window else { return }
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve) {
                window.overrideUserInterfaceStyle = newValue.userIntefaceStyle
            }
        }
    }
    
    // MARK: - Soundcloud settings
    var soundcloudLike: Bool {
        get {
            return UserDefaults.standard.value(forKey: .soundcloudLike) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .soundcloudLike)
        }
    }
    
    // MARK: - Yandex Music settings
    var yandexMusicLike: Bool {
        get {
            return UserDefaults.standard.value(forKey: .yandexMusicLike) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .yandexMusicLike)
        }
    }
    
    // MARK: - Features
    func updateFeatures(completion: @escaping(() -> ())) {
        guard self.settings.shouldUpdateFeatures else {
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
        self.settings.featuresLastUpdate = Int(Date().timeIntervalSince1970)
        DispatchQueue.main.async {
            RealmManager<LocalFeatureModel>().read().forEach { obj in
                RealmManager<LocalFeatureModel>().delete(object: obj)
            }
            
            RealmManager<LocalFeaturesModel>().update { realm in
                try? realm.write {
                    // Write fetched features to realm if needed
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
        isCanvasesEnabled = true
        soundcloudLike = false
        yandexMusicLike = false
        color = .purple
        appearance = .system
        lastTabBarIndex = MainTabBarController.ViewController.library.rawValue
        
        pulse.signOut()
        soundcloud.signOut()
        yandexMusic.signOut()
        
        LibraryManager.shared.cleanLibrary()
        LibraryManager.shared.removeTemporaryCache()
        
        return true
    }
}

// MARK: -
// MARK: Device Info
extension SettingsManager {
    var udid: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    var deviceModel: String {
        get {
            return UserDefaults.standard.value(forKey: .deviceModel) as? String ?? UIDevice.current.deviceIdentifier
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .deviceModel)
        }
    }
}
