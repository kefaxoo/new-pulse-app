//
//  SettingsManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation
import RealmSwift

final class SettingsManager {
    static let shared = SettingsManager()
    
    fileprivate init() {
        debugLog("Realm DB Location:", Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
    }
    
    var pulse = PulseModel()
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
        }
    }
    
    // MARK: Realm configuration
    var realmConfiguration: Realm.Configuration {
        let configuration = Realm.Configuration(schemaVersion: 6) { migration, oldSchemaVersion in
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
        }
        
        return configuration
    }
    
    // MARK: General settings
    var isAdultContentEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.isAdultContentEnabled.rawValue) as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.isAdultContentEnabled.rawValue)
        }
    }
    
    var isCanvasesEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.isCanvasesEnabled.rawValue) as? Bool ?? true
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
        }
    }
    
    func signOut() -> Bool {
        return pulse.signOut()
    }
}
