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
            return ColorType(rawValue: UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.colorType) as? String ?? "") ?? .purple
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKey.colorType)
        }
    }
    
    // MARK: Realm configuration
    var realmConfiguration: Realm.Configuration {
        let configuration = Realm.Configuration(schemaVersion: 5) { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { oldObject, newObject in
                    newObject?["shareLink"] = ""
                }
            }
            
            if oldSchemaVersion < 3 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { oldObject, newObject in
                    newObject?["extension"] = ""
                }
            }
            
            if oldSchemaVersion < 4 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { oldObject, newObject in
                    newObject?["source"] = "muffon"
                }
            }
            
            if oldSchemaVersion < 5 {
                migration.enumerateObjects(ofType: LibraryTrackModel.className()) { oldObject, newObject in
                    newObject?["trackFilename"] = ""
                }
            }
        }
        
        return configuration
    }
    
    // MARK: General settings
    var isAdultContentEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.isAdultContentEnabled) as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.isAdultContentEnabled)
        }
    }
    
    var isCanvasesEnabled: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.isCanvasesEnabled) as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.isCanvasesEnabled)
        }
    }
    
    var autoDownload: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.autoDownload) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.autoDownload)
        }
    }
    
    func signOut() -> Bool {
        return pulse.signOut()
    }
}
