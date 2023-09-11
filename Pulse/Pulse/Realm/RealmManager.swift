//
//  RealmManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation
import RealmSwift

final class RealmManager<T> where T: Object {
    private lazy var realm: Realm = {
        return try! Realm(configuration: SettingsManager.shared.realmConfiguration)
    }()
    
    func write(object: T) {
        try? realm.write {
            realm.add(object)
        }
    }
    
    func read() -> [T] {
        return Array(realm.objects(T.self))
    }
    
    func update(realmBlock: @escaping((Realm) -> Void)) {
        realmBlock(self.realm)
    }
    
    func delete(object: T) {
        try? realm.write {
            realm.delete(object)
        }
    }
}
