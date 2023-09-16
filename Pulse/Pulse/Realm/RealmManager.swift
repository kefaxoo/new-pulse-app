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
        // swiftlint:disable force_try
        return try! Realm(configuration: SettingsManager.shared.realmConfiguration)
        // swiftlint:enable force_try
    }()
    
    func write(object: T) {
        try? realm.write { [weak self] in
            self?.realm.add(object)
        }
    }
    
    func read() -> [T] {
        return Array(realm.objects(T.self))
    }
    
    func update(realmBlock: @escaping((Realm) -> Void)) {
        realmBlock(self.realm)
    }
    
    func delete(object: T) {
        try? realm.write { [weak self] in
            self?.realm.delete(object)
        }
    }
}

extension RealmManager {
    func removeAll() {
        self.read().forEach({ self.delete(object: $0) })
    }
    
    var count: Int {
        return self.read().count
    }
}
